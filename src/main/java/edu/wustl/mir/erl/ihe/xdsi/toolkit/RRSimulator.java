/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.toolkit;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import edu.wustl.mir.erl.ihe.xdsi.util.Utility;
import edu.wustl.mir.erl.ihe.xdsi.util.XmlUtil;
import gov.nist.toolkit.configDatatypes.SimulatorActorType;
import gov.nist.toolkit.registrymetadata.Metadata;
import gov.nist.toolkit.registrymetadata.MetadataParser;
import gov.nist.toolkit.toolkitApi.DocumentRegRep;
import gov.nist.toolkit.toolkitApi.SimulatorBuilder;
import gov.nist.toolkit.toolkitApi.ToolkitServiceException;
import gov.nist.toolkit.toolkitApi.XdsDocumentRegRep;
import gov.nist.toolkit.toolkitServicesCommon.DocumentContent;
import gov.nist.toolkit.toolkitServicesCommon.SimConfig;
import gov.nist.toolkit.toolkitServicesCommon.SimId;
import gov.nist.toolkit.toolkitServicesCommon.resource.SimConfigResource;

/**
 * Queries against an xdstool2 Document Registry/Repository Simulator.
 */
public class RRSimulator {

   private static final String actorName = SimulatorActorType.REPOSITORY_REGISTRY.getName();

   private static Logger log;
   private static SimulatorBuilder builder = null;
   SimId simId;
   SimConfig simConfig;
   DocumentRegRep rr;

   /**
    * @param id of existing registry/repository (rr) simulator
    * @param user that is, test session
    * @param env environment name
    * @throws ToolkitServiceException if server return status not 200.
    * @throws Exception if simulator is not Registry/Repository.
    */
   public RRSimulator(String id, String user, String env) throws ToolkitServiceException, Exception {

      if (builder == null) builder = new SimulatorBuilder(Utility.getXdstools2URL());
      simId = builder.get(user, id);
      simConfig = builder.get(simId);
      XdsDocumentRegRep act = new XdsDocumentRegRep();
      act.setConfig((SimConfigResource) simConfig);
      act.setEngine(builder.getEngine());
      rr = act;

      String actorType = simConfig.getActorType();
      String msg = "Simulator " + id + ":" + user + " ";
      if (actorType.equals(actorName) == false) {
         String em = msg + "is type " + actorType + ". Should be " + actorName;
         throw new Exception(em);
      }
   }

   /**
    * This is the equivalent of a FindDocuments Stored Query.
    * 
    * @param patientID - full patient id with Assigning Authority
    * @return list of object references - UUIDs of the DocumentEntries. Returns
    * empty list if nothing found for patient id.
    * @throws ToolkitServiceException on error.
    */
   public List <String> findDocumentsForPatientID(String patientID) throws ToolkitServiceException {
      try {
         return rr.findDocumentsForPatientID(patientID).getRefs();
      } catch (ToolkitServiceException e) {
         if (e.getCode() == 404) {
            log.warn("RegRep returned 404; nothing on file for " + patientID);
            return new ArrayList <String>();
         }
         throw e;
      }
   }

   /**
    * Get full metadata (XML) for a DocumentEntry
    * 
    * @param uuid - UUID of a DocumentEntry
    * @return full XML metadata for ExtrinsicObject representing DocumentEntry
    * @throws ToolkitServiceException on error
    */
   public String getDocEntry(String uuid) throws ToolkitServiceException {
      return rr.getDocEntry(uuid);
   }

   /**
    * Get contents of a document
    * 
    * @param uniqueId - DocumentEntry.uniqueId
    * @return contents of the document
    * @throws ToolkitServiceException on error
    */
   public DocumentContent getDocument(String uniqueId) throws ToolkitServiceException {
      return rr.getDocument(uniqueId);
   }

   /**
    * Test harness
    * <ol>
    * <li>First argument indicates test</li>
    * <ul>
    * <li/>TEST1 exercise query retrieve:
    * <ol>
    * <li/>arg 0 - TEST1
    * <li/>arg 1 - simulator id from xdstools
    * <li/>arg 2 - user id (test session) from xdstools
    * <li/>arg 3 - full patient id with assigning authority
    * </ul>
    * <li/>Remainder of arguments are passed to method more or less in order, as
    * needed.
    * </ol>
    * 
    * @param args arguments
    */
   public static void main(String[] args) {
      String cmd;
      log = Utility.getLog();
      cmd = getArg(args, 0);
      try {
         if (cmd.equalsIgnoreCase("TEST1")) {
            RRSimulator rr = new RRSimulator(args[1], args[2], args[3]);
            List <String> docs = rr.findDocumentsForPatientID(args[4]);
            String uuid = docs.get(0);
            String docEntry = rr.getDocEntry(uuid);
            log.info(XmlUtil.prettyPrintXML(docEntry));
            Metadata metadata = MetadataParser.parseNonSubmission(docEntry);
            List <String> uids = metadata.getAllUids();
            String id = uids.get(0);
            DocumentContent dc = rr.getDocument(id);
            String doc = new String(dc.getContent());
            log.info("uuid: " + dc.getUniqueId());
            log.info(doc);
         }

         log.info(cmd + " test completed");
      } catch (Exception e) {
         log.fatal(cmd + " test failed");
         log.fatal(Utility.getEM(e));
         e.printStackTrace();
      }
   }

   private static String getArg(String[] args, int arg) {
      if (args.length > arg) {
         String a = args[arg];
         if (StringUtils.isBlank(a) || a.equals("-") || a.equals("_") || a.equalsIgnoreCase("null")) return null;
         return a.trim();
      }
      return null;
   }

}
