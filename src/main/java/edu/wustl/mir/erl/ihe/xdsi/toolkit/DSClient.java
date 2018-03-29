/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.toolkit;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import edu.wustl.mir.erl.ihe.xdsi.util.Utility;
import gov.nist.toolkit.toolkitApi.DocumentSource;
import gov.nist.toolkit.toolkitApi.SimulatorBuilder;
import gov.nist.toolkit.toolkitApi.ToolkitServiceException;
import gov.nist.toolkit.toolkitServicesCommon.RawSendRequest;
import gov.nist.toolkit.toolkitServicesCommon.RawSendResponse;
import gov.nist.toolkit.toolkitServicesCommon.resource.DocumentResource;

/**
 * Generate Client Requests for Document Source actor.
 */
public class DSClient {
   
   private static Logger log = Utility.getLog();

   /**
    * Provide and Register KOS with metadata
    * @param kosPfn String pfn of kos.dcm file
    * @param metadataPfn String pfn of metadata.xml file
    * @param tls boolean, should TLS connection be used?
    * @throws IOException if metadata or KOS can't be read
    */
   public static void sendProvideAndRegisterKOS(String kosPfn, 
      String metadataPfn, boolean tls ) throws IOException {
      try {
         byte[] kos = Files.readAllBytes(Paths.get(kosPfn));
         DocumentResource document = new DocumentResource("application/dicom", kos);
         
         String metadata = new String(Files.readAllBytes(Paths.get(metadataPfn)));
         
         SimulatorBuilder builder = new SimulatorBuilder(Utility.getXdstools2URL());

         DocumentSource ds = builder.createDocumentSource("rep_reg", "ids", "xdsi");
         
         RawSendRequest request = ds.newRawSendRequest();
         request.setTransactionName("xdrpr");
         request.setTls(tls);
         request.setMetadata(metadata);
         request.addDocument("Document01", document);
         
         RawSendResponse response = ds.sendProvideAndRegister(request);
         
      } catch (ToolkitServiceException e) {
         log.error(Utility.getEM(e));
      } catch (Throwable thrown) {
         log.error(Utility.getEM(thrown));
         thrown.printStackTrace();
      }
   } // EO sendProvideAndRegisterKOS method
   
   /**
    * Test harness
    * <ol>
    * <li>First argument indicates method to test</li>
    * <ul>
    * <li/>SENDPNRKOS = {@link #sendProvideAndRegisterKOS}
    * </ul>
    * <li/>Remainder of arguments are passed to method more or less in order.
    * </ol>
    * 
    * @param args arguments
    */
   public static void main(String[] args) {
      String cmd;
      log = Utility.getLog();
      cmd = getArg(args, 0);
      try {
         if (cmd.equalsIgnoreCase("SENDPNRKOS")) {
            DSClient.sendProvideAndRegisterKOS(args[1], args[2], false);
         }

         log.info(cmd + " test completed");
      } catch (Exception e) {
         log.fatal(cmd + " test failed");
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
