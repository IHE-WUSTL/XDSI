package edu.wustl.mir.erl.ihe.xdsi.toolkit;

import org.apache.log4j.Logger;

import edu.wustl.mir.erl.ihe.xdsi.util.Utility;
import gov.nist.toolkit.toolkitApi.SimulatorBuilder;

/**
 * Image Document Consumer Simulator API
 */
public class IDCSimulator {
      
   private static Logger log = Utility.getLog();
   private static SimulatorBuilder builder = new SimulatorBuilder(Utility.getXdstools2URL());
   private String id;
   private String user;
   private String env;
      
   /**
    * Creates IDCSimulator with given IDS SUT target
    * @param sutId for ids SUT
    * @param sutUser that is, test session
    * @param env environment name
    * @throws Exception on error, for example, target does not exist or is
    * not an ids
    */
   public IDCSimulator(String sutId, String sutUser, String env) throws Exception {
      id = sutId;
      user = sutUser;
      this.env = env;
//      SimConfig idsSimConfig = builder.get(idsSimId);
//      if(idsSimConfig.getActorType().equals(ActorType.IMAGING_DOC_SOURCE.getName()) == false)
//         throw new Exception("SUT id " + sutId + " is not an ids");

   }
   
 //  private RetrieveResponse retrieveImagingDocSet(RetrieveImageRequestResource request) 
//   private RetrieveResponse retrieveImagingDocSet(OneImageRetrieveResource request) 
//      throws ToolkitServiceException {
//      request.setId(id);
//      request.setUser(user);
//      request.setEnvironmentName(env);
//      request.setActorType("ids");
//      return builder.getEngine().imagingRetrieve(request);
//   }
   
//   private RetrieveResponse retrieveSingleImage(String studyUID, String seriesUID,
//      String imageUID, String homeId, String idsUID, String syntax) 
//         throws ToolkitServiceException, JAXBException {
//      RetrieveImageRequestResource request = new RetrieveImageRequestResource();
//      
//      RetrieveImageStudyRequest study = new RetrieveImageStudyRequestResource();
//      study.setStudyInstanceUID(studyUID);
//      List<RetrieveImageStudyRequest> studyList = new ArrayList<>();
//      studyList.add(study);
//      request.setRetrieveImageStudyRequests(studyList);
//      
//      RetrieveImageSeriesRequest series = new RetrieveImageSeriesRequestResource();
//      series.setSeriesInstanceUID(seriesUID);
//      List<RetrieveImageSeriesRequest> seriesList = new ArrayList<>();
//      study.setRetrieveImageSeriesRequests(seriesList);
//      
//      RetrieveImageDocumentRequest doc = new RetrieveImageDocumentRequestResource();
//      doc.setDocumentUniqueId(imageUID);
//      doc.setHomeCommunityId(homeId);
//      doc.setRepositoryUniqueId(idsUID);
//      List<RetrieveImageDocumentRequest> docList = new ArrayList<>();
//      docList.add(doc);
//      series.setRetrieveImageDocumentRequests(docList);
//      
//      List<String> xferList = new ArrayList<>();
//      xferList.add(syntax);
//      request.setTransferSystaxUIDs(xferList);
//      
//      JAXBContext jaxbContext = JAXBContext.newInstance(RetrieveImageRequestResource.class);
      
//      OneImageRetrieveResource request = new OneImageRetrieveResource();
//      request.setId(id);
//      request.setUser(user);
//      request.setEnvironmentName(env);
//      request.setActorType("ids");
//      request.setStudyUID(studyUID);
//      request.setSeriesUID(seriesUID);
//      request.setDocumentUniqueId(imageUID);
//      request.setHomeCommunityId(homeId);
//      request.setRepositoryUniqueId(idsUID);
//      request.setXferSyntax(syntax);
//      
//      JAXBContext jaxbContext = JAXBContext.newInstance(OneImageRetrieveResource.class);
//      Marshaller jaxbMarshaller = jaxbContext.createMarshaller();
//      jaxbMarshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT,true);
//      jaxbMarshaller.marshal(request, System.out);
//      
//      return retrieveImagingDocSet(request);
//   }
   
   /**
    * Test harness
    * <ol>
    * <li>First argument indicates test</li>
    * <ul>
    * <li/>IDS_TEST1 exercise query retrieve: (samples are for a single image
    * test against Steve's test IDS.
    * <ol>
    * <li/>arg 0 - ONE_IMAGE
    * <li/>arg 1 - simulator id from xdstools: IDS
    * <li/>arg 2 - user id (test session) from xdstools: xdsi01
    * <li/>arg 3 - environment name: xdsi
    * <li/>arg 4 = study UID: "1.3.6.1.4.1.21367.201599.1.201602161646039"
    * <li/>arg 5 - series UID: "1.3.6.1.4.1.21367.201599.2.201602161646039"
    * <li/>arg 6 - Document UID: "1.3.6.1.4.1.21367.201599.3.201602161646039.1"
    * <li/>arg 7 - repository UID: "1.1.4567332.10.99"
    * <li/>arg 8 - Transfer Syntax UID: "1.2.840.10008.1.2.2"
    * 
    * </ul>
    * </ol>
    * 
    * @param args arguments
    */
//   public static void main(String[] args) {
//      String cmd;
//      log = Utility.getLog();
//      cmd = getArg(args, 0);
//      try {
//         if (cmd.equalsIgnoreCase("ONE_IMAGE")) {
//            IDCSimulator idc = new IDCSimulator(args[1], args[2], args[3]);
//            RetrieveResponse response = idc.retrieveSingleImage(args[4], args[5], args[6], "", args[7], args[8]);
//            log.info(response);
//         }
//         log.info(cmd + " test completed");
//      } catch (Exception e) {
//         log.fatal(cmd + " test failed");
//         log.fatal(Utility.getEM(e));
//         e.printStackTrace();
//      } 
//   } // EO main method
//
//      private static String getArg(String[] args, int arg) {
//         if (args.length > arg) {
//            String a = args[arg];
//            if (StringUtils.isBlank(a) || a.equals("-") || a.equals("_") || a.equalsIgnoreCase("null")) return null;
//            return a.trim();
//         }
//         return null;
//      }

} // EO IDSSimulator class
