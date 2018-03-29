/*******************************************************************************
 * Copyright (c) 2015 Washington University in St. Louis All rights reserved.
 * This program and the accompanying materials are made available under the
 * terms of the Apache License, Version 2.0 (the "License"); you may not use
 * this file except in compliance with the License. The License is available at:
 * http://www.apache.org/licenses/LICENSE-2.0 Unless required by applicable law
 * or agreed to in writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language
 * governing permissions and limitations under the License. Contributors:
 * Initial author: Steve Moore/ MIR WUSM IHE Development Project
 * smoore@wustl.edu
 ******************************************************************************/
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
import gov.nist.toolkit.toolkitServicesCommon.resource.RetImgDocSetReqDocumentResource;
import gov.nist.toolkit.toolkitServicesCommon.resource.RetImgDocSetReqResource;
import gov.nist.toolkit.toolkitServicesCommon.resource.RetImgDocSetReqSeriesResource;
import gov.nist.toolkit.toolkitServicesCommon.resource.RetImgDocSetReqStudyResource;
import gov.nist.toolkit.toolkitServicesCommon.resource.RetImgDocSetRespDocumentResource;
import gov.nist.toolkit.toolkitServicesCommon.resource.RetImgDocSetRespResource;

import edu.wustl.mir.erl.ihe.xdsi.util.*;

/**
 * IDC Simulator class
 * 
 * @author Matt Kelsey / MIR WUSTL IHE Development Project
 * <a href="mailto:kelseym@wustl.edu">kelseym@wustl.edu</a>
 * @author smm
 * @see "IHE RAD TF-3 Transactions (Continued) Section 4.69"
 */
public class RAD_69_IDC extends ClientTransaction {

   private static Logger log = Utility.getLog();
   private static SimulatorBuilder builder = new SimulatorBuilder(Utility.getXdstools2URL());

   // ***************************************************************************
   // Instance properties
   // ***************************************************************************
   /**
    * Image Document Source configuration
    */
   private AEBean ids = null;
   /**
    * Initiating Imaging Gateway configuration, null for same community retrieve
    */
   private AEBean ig = null;

   /**
    * File system folder to be used for storing RAD-69 results, either absolute
    * or relative to XDSI root directory. Must exist and have rw permissions.
    * Processing transaction will create two subdirectories in this directory:
    * <ol>
    * <li/>attachments - containing the retrieved files.
    * <li/>response - containing:
    * <ul>
    * <li/>The {@code <RetrieveDocumentSetResponse>} xml in string form, with
    * actual {@code <Document>} element text contents replaced with "..." for
    * brevity.
    * <li/>The (@code <RetrieveDocumentSetRequest>} xml in string form, as it
    * was sent to the server.
    * <li/>The Request and Response SOAP headers xml in string form.
    * </ul>
    * </ol>
    * Any previous contents of this directory will be cleared.
    */
   private String outputFolder = null;

   /**
    * KOS instances, built by initialization methods and used to determine what
    * images will be retrieved.
    */
   private List<Bean> beans = new ArrayList<>();
   
   /**
    * Image Repository Unique ID to use in transactions. This is set to the
    * Image Data Source repositoryUniqueId value when that is set, as happens in
    * {@link #initialize(String, String, String, String)} and can also be set
    * directly. The then current value is used when any of the other initialize
    * methods are invoked.
    */
   private String repositoryUniqueId = null;
   
   /**
    * home community ID to use in XC transactions. This is set to the
    * Image Data Source homeCommunityId value when that is set, as happens in
    * {@link #initialize(String, String, String, String)} and can also be set
    * directly. The then current value is used when any of the other initialize
    * methods are invoked.
    */
   private String homeCommunityId = null;


   /**
    * Transfer Syntax UIDs.
    */
   private List <String> xferSyntaxUIDs = null;

   // ***************************************************************************
   // Getters and Setters for instance properties
   // ***************************************************************************

   /**
    * @param idsName Name of Imaging Document Source (IDS) See also
    * {@link AEBean#loadFromConfigurationFile(String)}
    * Also sets/resets {@link #repositoryUniqueId}
    */
   public void setIds(String idsName) {
      ids = AEBean.loadFromConfigurationFile(idsName);
      repositoryUniqueId = ids.getRepositoryUniqueId();
      homeCommunityId = ids.getHomeCommunityId();
   }

   /**
    * @param igName Name of the Initiating Imaging Gateway (IIG or IG). See also
    * {@link AEBean#loadFromConfigurationFile(String)}.<br>
    * A null or empty value indicates that the Request is to be sent directly to
    * the IDS.
    */
   public void setIg(String igName) {
      if (StringUtils.isBlank(igName)) ig = null;
      else ig = AEBean.loadFromConfigurationFile(igName);
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
         List<String> lines = Utility.readTextLines(pth);
         for (String line : lines) {
            if (line.contains("#")) line = line.substring(0, line.indexOf("#"));
            line = line.trim();
            if (StringUtils.isBlank(line)) continue;
            xferSyntaxUIDs.add(line);
         }
         if (xferSyntaxUIDs.isEmpty()) 
            throw new Exception("Transfer Syntax file: " + pth + 
               " containing no valid entries will be ignored");
      } catch (Exception e) {
         if (StringUtils.isNotBlank(e.getMessage())) log.warn(e.getMessage());
         xferSyntaxUIDs.add("1.2.840.10008.1.2.1");
      }
   }

   /**
    * @return the {@link #beans} value.
    */
   public List<Bean> getBeans() {
      return beans;
   }

   /**
    * @param bns the {@link #beans} to set
    */
   public void setKosBeans(List <Bean> bns) {
      this.beans = bns;
   }
   
   public void addBean(String hci, KOSBean kos) {
      beans.add(new Bean(hci, kos));
   }

   /**
    * @return the {@link #homeCommunityId} value.
    */
   public String getHomeCommunityId() {
      return homeCommunityId;
   }

   /**
    * @param homeCommunityId the {@link #homeCommunityId} to set
    */
   public void setHomeCommunityId(String homeCommunityId) {
      this.homeCommunityId = homeCommunityId;
   }

   /**
    * @return the {@link #repositoryUniqueId} value.
    */
   public String getRepositoryUniqueId() {
      return repositoryUniqueId;
   }

   /**
    * @param repositoryUniqueId the {@link #repositoryUniqueId} to set
    */
   public void setRepositoryUniqueId(String repositoryUniqueId) {
      this.repositoryUniqueId = repositoryUniqueId;
   }
   
   // ***************************************************************************
   // Initialization routines
   // ***************************************************************************

   private void initializeKos(KOSBean kosBean)
      throws Exception {
      log.debug("RAD_69_IDC#initializeKos/kos");
      addBean(homeCommunityId, kosBean);

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
    * @param pathKos path to DICOM KOS file
    * @throws Exception on error
    */
   public void initializeKos(String pathKos)
      throws Exception {
      log.debug("RAD_69_IDC#initializeKos/path");

      DICOMUtility u = new DICOMUtility();
      KOSBean kos = u.readKOS(pathKos);
      initializeKos(kos);
   }

   public void initializeSingle(String uidComposition)
      throws Exception {
      log.debug("RAD_69_IDC#initializeSingle");
      DICOMUtility u = new DICOMUtility();
      KOSBean kos = u.manufactureKOSFromCompositeUID(uidComposition, "WUSTL", repositoryUniqueId, "1.2.6");
      initializeKos(kos);
   }

   /**
    * Adds one or more {@link KOSBean} instances to the transaction, using a
    * file containing:
    * <ul>
    * <li/>composite ids, that is, studyid:seriesid:instanceid on one line.
    * <li/>repository unique ids, on one line, which will change the "current"
    * repository.
    * <li/>home community ids, on one line, staring with "urn:oid", which will
    * change the "current" home community.
    * <li/>An "#" character begins a comment running to the end of the line,
    * which will be ignored.
    * <li/>Blank and whitespace only lines will be ignored.
    * </ul> 
    * @param pathUidFile path of the file, absolute or relative to runDirectory.
    * @throws Exception on formatting or IO error.
    */
   public void initializeMulti(String pathUidFile)
      throws Exception {
      Utility.invoked();
      Path path = Utility.getRunDirectoryPath().resolve(pathUidFile);
      Utility.isValidPfn("image composite ids file", path, PfnType.FILE, "r");
      List<String> uids = new ArrayList<>();
      for (String line : Files.readAllLines(path)) {
         log.info(line);
         // comments and blank lines.
         if (line.contains("#"))
            line = line.substring(0, line.indexOf("#")).trim();
         if (line.isEmpty()) continue;
         // home community ids
         if (line.startsWith("urn:oid")) {
            kosFromCompositeIds(uids);
            homeCommunityId = line;
            continue;
         }
         // composite id lines.
         if (line.contains(":")) {
            uids.add(line);
            continue;
         }
         // other, assumed to be repository unique id lines.
         kosFromCompositeIds(uids);
         repositoryUniqueId = line;
      }
      kosFromCompositeIds(uids);
   }
   
   private void kosFromCompositeIds(List<String> uids) throws Exception {
      if (uids.isEmpty()) return;
      DICOMUtility u = new DICOMUtility();
      KOSBean kos = u.manufactureKOSFromUIDs(uids, "WUSTL", repositoryUniqueId, "1.2.6");
      addBean(homeCommunityId, kos);
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

      log.debug("RAD_69_IDC#executeTransaction");
      RetImgDocSetReqResource requestRes = new RetImgDocSetReqResource();
      requestRes.setMessageDir(dirResponse.toString());
      AEBean server = (ig == null) ? ids : ig;
      requestRes.setId(server.getXdsSiteName());
      requestRes.setUser(server.getXdsUser());
      requestRes.setFullId(server.getXdsFullId());
      requestRes.setActorType(server.getXdsActorType());
      requestRes.setEnvironmentName(server.getXdsEnvironment());
      requestRes.setEndpoint(server.getWsdlURL());
      requestRes.setTls(false);
      for (Bean bean : beans) {
         KOSBean kos = bean.kos;
         String home = bean.home;
         for (KOSStudyBean study : kos.getStudyBeanList()) {
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
                  documentRes.setHomeCommunityId(home);
                  seriesRes.addDocumentRequest(documentRes);
               } // Instance loop
            } // Series loop
         } // Study loop
      } // EO KosBean loop
      requestRes.setTransferSyntaxUIDs(xferSyntaxUIDs);

      JAXBContext jaxbContext = JAXBContext.newInstance(RetImgDocSetReqResource.class);
      Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
      jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
      jaxbMarshaller.marshal(requestRes, System.out);
      
      String tType = "rad69Iig";
      if (ig == null) tType = "rad69";

      RetImgDocSetRespResource response = builder.getEngine().imagingRetrieve(requestRes, tType);
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

   private void initialize(String outputDirPath, String idsName, String igName, String xferSyntaxPath)
      throws Exception {
      setOutputFolder(outputDirPath);
      setIds(idsName);
      setIg(igName);
      setXferSyntaxUIDs(xferSyntaxPath);
   }

   static void usage() {
      //  @formatter:off
      String msg =
         "Usage: COMMAND (common) other-args ...\n" + 
         "    (common arguments): \n" + 
         "      1. Output Folder \n" + 
         "      2. IDS AE Bean ini name \n" + 
         "      3. IG AE Bean ini name (only if XC)\n" + 
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
    * <li/>Output Folder name, absolute or relative to {@link Utility#getXDSIRootPath()}
    * <li/>name of ids .ini file - rg .ini file if Cross Community
    * <li/>name of ig .ini file if Cross Community
    * <li/>name of transfer syntax UID file.
    * <li/>others depend on the command; see comments in code below
    * </ol>
    * Note: ids, ig, and xfer syntax file names are absolute or relative to
    * {@link Utility#getRunDirectoryPath()}
    */
   public static void main(String[] args) {
      if (args.length < 5) usage();
      
      // get command to execute
      String cmd = args[0].toUpperCase();
      
      // if command contains "XC" it is Cross Community. These command have an
      // extra common argument, the ig name, so their first command specific
      // argument is 5, not 4.
      boolean isXc = false;
      int fcsa = 4;
      if (cmd.contains("XC")) { isXc = true; fcsa = 5; }
      try {

         RAD_69_IDC rad69 = new RAD_69_IDC();
         
         if (isXc) rad69.initialize(args[1], args[2], args[3], args[4]);
         else rad69.initialize(args[1], args[2], "", args[3]);

         switch (cmd) {
            case "KOS":
            case "KOS_XC":
               // command specific argument: KOS Path
               rad69.initializeKos(args[fcsa]);
               break;
            case "SINGLE":
            case "SINGLE_XC":
               // command specific argument: Composite UID (Study UID:Series UID:Instance UID)
               rad69.initializeSingle(args[fcsa]);
               break;
            case "MULTI":
            case "MULTI_XC":
               // command specific argument: Path to UIDs file
               rad69.initializeMulti(args[fcsa]);
               break;
            default:
               usage();
         }
         rad69.executeTransaction();
      } catch (Exception e) {
         e.printStackTrace();
         System.exit(1);
      }

   } // EO main method

} // EO RAD_69_IDC class
