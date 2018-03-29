/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.transactions;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import gov.nist.toolkit.toolkitApi.SimulatorBuilder;
import gov.nist.toolkit.toolkitServicesCommon.resource.*;

import edu.wustl.mir.erl.ihe.xdsi.util.*;

/**
 * Simulates IIG sending RAD-75 to RIG
 * 
 * @author Ralph Moulton / MIR WUSTL IHE Development Project
 * <a href="mailto:moultonr@mir.wustl.edu">moultonr@mir.wustl.edu</a>
 * @see "IHE RAD TF-3 Transactions (Continued) Section 4.75"
 */
public class RAD_75_IIG extends ClientTransaction {

   private static Logger log = Utility.getLog();
   private static SimulatorBuilder builder = new SimulatorBuilder(Utility.getXdstools2URL());

   // ***************************************************************************
   // Instance properties
   // ***************************************************************************
   /**
    * Responding Imaging Gateway configuration
    */
   private AEBean rig = null;

   /**
    * File system folder to be used for storing RAD-75 results, either absolute
    * or relative to XDSI root directory. Must exist and have rw permissions.
    * Processing transaction will create two subdirectories in this directory:
    * <ul>
    * <li/>attachments - containing the retrieved files.
    * <li/>response - containing the {@code <RetrieveDocumentSetResponse>} xml
    * in string form, with actual {@code <Document>} element text contents
    * replaced with "..." for brevity.
    * </ul>
    * Any previous contents of this directory will be cleared.
    */
   private String outputFolder = null;

   /**
    * KOSBean. built by initialization methods and used to determine what images
    * will be retrieved.
    */
   private KOSBean kBean = null;
   /**
    * Transfer Syntax UIDs.
    */
   private List <String> xferSyntaxUIDs = null;

   // ***************************************************************************
   // Getters and Setters for instance properties
   // ***************************************************************************

   /**
    * @param idsName Name of Responding Imaging Gateway (RIG). See also
    * {@link AEBean#loadFromConfigurationFile(String)}
    */
   public void setIds(String idsName) {
      rig = AEBean.loadFromConfigurationFile(idsName);
   }

   /**
    * @return the {@link #outputFolder} value.
    */
   public String getOutputFolder() {
      return outputFolder;
   }

   /**
    * @param outputFolder the {@link #outputFolder} to set
    */
   public void setOutputFolder(String outputFolder) {
      this.outputFolder = outputFolder;
   }

   /**
    * @param xferSyntaxPath path absolute or relative to runDirectory, of text
    * file containing acceptable transfer syntax UIDs, one per line. If null,
    * empty, or file cannot be read, "1.2.840.10008.1.2.1" (Explicit VR Little
    * Endian) will be used as the one acceptable syntax.<br/>
    * <b>Note: </b>A "#" character denotes the beginning of a comment, which
    * continues for the rest of the line. Lines are trimmed and blank lines are
    * ignored.
    */
   public void setXferSyntaxUIDs(String xferSyntaxPath) {
      xferSyntaxUIDs = new ArrayList <String>();
      try {
         if (StringUtils.isBlank(xferSyntaxPath)) throw new Exception("");
         String pth = Utility.getRunDirectoryPath().resolve(xferSyntaxPath).toString();
         List <String> lines = Utility.readTextLines(pth);
         for (String line : lines) {
            if (line.contains("#")) line = line.substring(0, line.indexOf("#"));
            line = line.trim();
            if (StringUtils.isBlank(line)) continue;
            xferSyntaxUIDs.add(line);
         }
         if (xferSyntaxUIDs.isEmpty())
            throw new Exception("Transfer Syntax file: " + pth + " containing no valid entries will be ignored");
      } catch (Exception e) {
         if (StringUtils.isNotBlank(e.getMessage())) log.warn(e.getMessage());
         xferSyntaxUIDs.add("1.2.840.10008.1.2.1");
      }
   }

   // ***************************************************************************
   // Initialization routines
   // ***************************************************************************

   private void initializeKos(KOSBean kosBean) throws Exception {
      log.debug("RAD_75_IDC#initializeKos/kos");
      kBean = kosBean;

      Iterator <KOSStudyBean> itStudy = kosBean.getStudyBeanList().iterator();
      while (itStudy.hasNext()) {
         KOSStudyBean study = itStudy.next();
         log.debug(" Study UID: " + study.getStudyUID());
         Iterator <KOSSeriesBean> itSeries = study.getSeriesBeanList().iterator();
         while (itSeries.hasNext()) {
            KOSSeriesBean series = itSeries.next();
            log.debug("  Series UID:  " + series.getSeriesUID());
            log.debug("  Retrieve AE: " + series.getRetrieveAETitle());
            Iterator <KOSInstanceBean> itInstance = series.getInstanceBeanList().iterator();
            while (itInstance.hasNext()) {
               KOSInstanceBean instance = itInstance.next();
               log.debug("   Instance UID: " + instance.getInstanceUID());
            }
         }
      }
      Iterator <String> itXferSyntax = xferSyntaxUIDs.iterator();
      while (itXferSyntax.hasNext()) {
         String xferSyntaxUid = itXferSyntax.next();
         log.debug(" Xfer Syntax UID: " + xferSyntaxUid);
      }
   }

   /**
    * Initialize transaction using DICOM KOS file
    * 
    * @param pathKos path to DICOM KOS file
    * @throws Exception on error
    */
   public void initializeKos(String pathKos) throws Exception {
      log.debug("RAD_75_IDC#initializeKos/path");

      DICOMUtility u = new DICOMUtility();
      KOSBean kos = u.readKOS(pathKos);
      initializeKos(kos);
   }

   public void initializeSingle(String uidComposition) throws Exception {
      log.debug("RAD_75_IDC#initializeSingle");
      DICOMUtility u = new DICOMUtility();
      KOSBean kos = u.manufactureKOSFromCompositeUID(uidComposition, "WUSTL", rig.getRepositoryUniqueId(), "1.2.6");
      initializeKos(kos);
   }

   /**
    * Generates a {@link KOSBean} instance from a file containing: composite
    * ids, that is, studyid:seriesid:instanceid on one line. <br/>
    * An "#" character begins a comment running to the end of the line, which
    * will be ignored. Blank and whitespace only lines will be ignored.
    * 
    * @param pathUidFile path of the file, absolute or relative to runDirectory.
    * @throws Exception on formatting or IO error.
    */
   public void initializeMulti(String pathUidFile) throws Exception {
      Utility.invoked();
      Path path = Utility.getRunDirectoryPath().resolve(pathUidFile);
      Utility.isValidPfn("image composite ids file", path, PfnType.FILE, "r");
      String repositoryUniqueId = rig.getRepositoryUniqueId();
      kBean = null;
      
      List <String> uids = new ArrayList <>();
      for (String line : Files.readAllLines(path)) {
         log.info(line);
         // comments and blank lines.
         if (line.contains("#")) line = line.substring(0, line.indexOf("#")).trim();
         if (line.isEmpty()) continue;
         // composite id lines.
         if (line.contains(":")) {
             String[] tokens = line.split(":");
             if (tokens.length != 3)
                throw new Exception("invalid composite id [" + line + "] has " + tokens.length + " components.");
             for (String token : tokens) {
                if (StringUtils.isBlank(token))
                   throw new Exception("invalid composite id [" + line + "] has empty segment(s)");
             }
             uids.add(line);
             continue;
          }
         // other, assumed to be repository unique id lines.
         kosFromCompositeIds(uids, repositoryUniqueId);
         repositoryUniqueId = line;
      }
      kosFromCompositeIds(uids, repositoryUniqueId);
   }

   private void kosFromCompositeIds(List <String> uids, String repositoryUniqueId) throws Exception {
      if (uids.isEmpty()) return;
      DICOMUtility u = new DICOMUtility();
      kBean = u.manufactureKOSFromUIDs(kBean, uids, "WUSTL", repositoryUniqueId, "1.2.6");
      uids.clear();
   }

   public RetImgDocSetRespResource executeTransaction() throws Exception {
      Path dirOutput = Utility.getXDSIRootPath().resolve(outputFolder);
      if (Files.exists(dirOutput)) {
         FileUtils.deleteDirectory(new File(dirOutput.toString()));
      }
      Path dirAttachments = dirOutput.resolve("attachments");
      Files.createDirectories(dirAttachments);
      Path dirResponse = dirOutput.resolve("response");
      Files.createDirectories(dirResponse);

      Utility.invoked();
      RetImgDocSetReqResource requestRes = new RetImgDocSetReqResource();
      requestRes.setMessageDir(dirResponse.toString());
      AEBean server = rig;
      requestRes.setId(server.getXdsSiteName());
      requestRes.setUser(server.getXdsUser());
      requestRes.setFullId(server.getXdsFullId());
      requestRes.setActorType(server.getXdsActorType());
      requestRes.setEnvironmentName(server.getXdsEnvironment());
      requestRes.setEndpoint(server.getWsdlURL());
      requestRes.setTls(false);
      for (KOSStudyBean study : kBean.getStudyBeanList()) {
         RetImgDocSetReqStudyResource studyRes = new RetImgDocSetReqStudyResource();
         studyRes.setStudyInstanceUID(study.getStudyUID());
         requestRes.addStudyRequest(studyRes);
         for (KOSSeriesBean series : study.getSeriesBeanList()) {
            RetImgDocSetReqSeriesResource seriesRes = new RetImgDocSetReqSeriesResource();
            seriesRes.setSeriesInstanceUID(series.getSeriesUID());
            studyRes.addSeriesRequest(seriesRes);
            for (KOSInstanceBean instance : series.getInstanceBeanList()) {
               RetImgDocSetReqDocumentResource documentRes = new RetImgDocSetReqDocumentResource();
               documentRes.setDocumentUniqueId(instance.getInstanceUID());
               documentRes.setRepositoryUniqueId(series.getRetrieveLocationUID());
               documentRes.setHomeCommunityId(rig.getHomeCommunityId());
               seriesRes.addDocumentRequest(documentRes);
            } // Instance loop
         } // Series loop
      } // Study loop
      requestRes.setTransferSyntaxUIDs(xferSyntaxUIDs);

      JAXBContext jaxbContext = JAXBContext.newInstance(RetImgDocSetReqResource.class);
      Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
      jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
      jaxbMarshaller.marshal(requestRes, System.out);

      RetImgDocSetRespResource response = builder.getEngine().imagingRetrieve(requestRes, "rad75");
      log.debug(XmlUtil.prettyPrintSOAP(response.getAbbreviatedResponse()));
      storeFiles(response);
      return response;

   }

   private void storeFiles(RetImgDocSetRespResource response) throws Exception {
      if (outputFolder == null) return;
      Path dir = Utility.getXDSIRootPath().resolve(outputFolder).resolve("response");
      Files.createDirectories(dir);
      Utility.writeToFile(response.getAbbreviatedResponse(), dir, "ResponseBody.xml");
      dir = Utility.getXDSIRootPath().resolve(outputFolder).resolve("attachments");
      Files.createDirectories(dir);
      for (RetImgDocSetRespDocumentResource doc : response.getDocuments()) {
         Utility.writeToFile(doc.getDocumentContents(), dir, doc.getDocumentUid() + ".dcm");
      }
   }

   private void initialize(String outputDirPath, String rigName, String xferSyntaxPath) throws Exception {
      setOutputFolder(outputDirPath);
      setIds(rigName);
      setXferSyntaxUIDs(xferSyntaxPath);
   }

   static void usage() {
      //  @formatter:off
      String msg =
         "Usage: COMMAND (common) other-args ...\n" + 
         "    (common arguments): \n" + 
         "      1. Output Folder \n" + 
         "      2. RIG AE Bean ini name \n" + 
         "      4. Transfer Syntax File \n" + 
         " KOS      (common) KOS-path\n" + 
         " SINGLE   (common) Composite UID (Study:Series:Instance)\n" + 
         " MULTI    (common) Path to UIDs file\n";
      //  @formatter:on
      System.out.println(msg);
      System.exit(1);
   }

   class Bean {
      String home;
      KOSBean kos;

      public Bean(String hci, KOSBean k) {
         home = hci;
         kos = k;
      }
   }

   /**
    * @param args Arguments:
    * <ol start="0">
    * <li/>Command indicating which test to run.
    * <li/>Output Folder name, absolute or relative to XDSI root.
    * <li/>name of rig .ini file.
    * <li/>name of transfer syntax UID file.
    * <li/>others depend on the command; see comments in code below.
    * </ol>
    * Note: rig, UID, and xfer syntax file names are absolute or relative to
    * runDirectory
    */
   public static void main(String[] args) {
      if (args.length != 5) usage();

      // get command to execute
      String cmd = args[0].toUpperCase();

      try {

         RAD_75_IIG rad75 = new RAD_75_IIG();

         rad75.initialize(args[1], args[2], args[3]);

         switch (cmd) {
            case "KOS":
               // command specific argument: KOS Path
               rad75.initializeKos(args[4]);
               break;
            case "SINGLE":
               // command specific argument: Composite UID (Study UID:Series
               // UID:Instance UID)
               rad75.initializeSingle(args[4]);
               break;
            case "MULTI":
               // command specific argument: Path to UIDs file
               rad75.initializeMulti(args[4]);
               break;
            default:
               usage();
         }
         rad75.executeTransaction();
      } catch (Exception e) {
         e.printStackTrace();
         System.exit(1);
      }

   } // EO main method

} // EO RAD_75_IIG class
