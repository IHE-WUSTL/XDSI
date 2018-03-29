/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.toolkit;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import edu.wustl.mir.erl.ihe.xdsi.util.Utility;
import gov.nist.toolkit.toolkitApi.SimulatorBuilder;

/**
 * Generate client requests for Document Consumer actor.
 */
public class DCClient {
   
   private static Logger log = Utility.getLog();
   
   /**
    * Registry Stored Query on Patient ID (ITI-18).
    * @param pid patient id
    * @param tls  boolean, should TLS connection be used?
    */
   public static void sendRegistryStoredQueryPid(String pid, boolean tls) {

      try {

         SimulatorBuilder builder = new SimulatorBuilder(Utility.getXdstools2URL());

  //    } catch (ToolkitServiceException e) {
  //       log.error(Utility.getEM(e));
      } catch (Throwable thrown) {
         log.error(Utility.getEM(thrown));
         thrown.printStackTrace();
      }
   }
   
   /**
    * Test harness
    * <ol>
    * <li>First argument indicates method to test</li>
    * <ul>
    * <li/>SENDRSQPID = {@link #sendRegistryStoredQueryPid}
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
         if (cmd.equalsIgnoreCase("SENDRSQPID")) {
            DCClient.sendRegistryStoredQueryPid(args[1], false);
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
