/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.validation.iig;

import java.net.URL;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.w3c.dom.Element;

import edu.wustl.mir.erl.ihe.xdsi.util.ProcessNISTSimulatorLogs;
import edu.wustl.mir.erl.ihe.xdsi.util.Utility;
import edu.wustl.mir.erl.ihe.xdsi.util.XmlUtil;
import edu.wustl.mir.erl.ihe.xdsi.validation.Results;
import edu.wustl.mir.erl.ihe.xdsi.validation.TestImgRet;

/**
 * Processes test validations for IIG SUT
 * 
 * @author Ralph Moulton / MIR WUSTL IHE Development Project <a
 * href="mailto:moultonr@mir.wustl.edu">moultonr@mir.wustl.edu</a>
 *
 */
public class TestIIG {
   
   private static Logger log = Utility.getLog();
   
   /**
    * @param testName for example "iig-1001"
    * @param session for example "acme"
    * @param rRoot path to result root directory, or null to use standard path
    * @param sRoot path to std root directory, or null to use standard path
    * @throws Exception on error
    */
   public static void runTests(String testName, String session, String rRoot, String sRoot) throws Exception {
      
      if (rRoot == null) rRoot = Utility.getResultsDirectory(testName, session).toString();
      if (sRoot == null) sRoot = Utility.getStdDirectory(testName).toString();
      
      // Load sut-####.xml file
      URL url = TestIIG.class.getResource(testName + ".xml");
      Element testElmnt = XmlUtil.strToElement(IOUtils.toString(url, "UTF-8")); 
      
      ProcessNISTSimulatorLogs.getSimulatorTestResults(testElmnt, session, rRoot);
      
      // get <Transactions> element
      Element[] e = XmlUtil.getFirstLevelChildElementsByName(testElmnt, "Transactions");
      if (e.length == 0) throw new Exception("<Transactions> element missing");
      if (e.length > 1) throw new Exception("Only one <Transactions> element permitted, " + e.length + " found.");
      
      // pass <Transaction> elements
      for (Element transaction : XmlUtil.getFirstLevelChildElementsByName(e[0], "Transaction")) {
         String transactionId = transaction.getAttribute("id");
         String name = transaction.getAttribute("name");
         if (StringUtils.isBlank(name)) name = transactionId;
         try {
            TestImgRet test = new TestImgRet(url.toExternalForm(), transactionId, rRoot, sRoot);
            test.runTest();
            test.reportResults();
            Results results = test.getResults(name);
            log.info("Test Results:" + Utility.nl + results);
         } catch (Exception x) {
            x.printStackTrace();
         }
      }
   }
   
   /**
    * @param args <ol start=0>
    * <li/>test xml file name, for example iig-1001. ".xml" will be added
    * <li/>session id, for example "acme".
    * <li/>results directory path name, absolute or relative to XDSI root. 
    * <li/>std directory path name, absolute or relative to XDSI root.
    * </ol>
    * Note: The directories are "root" result and std directories, for example
    * std/iig/1001. The transaction id will be added to them as an additional
    * directory level. For example transaction id RAD-69,
    * std/iig/1001/RAD-69. If omitted, standard directories will be used.
    */
   public static void main(String[]args) {
      try {
      runTests(args[0], args[1], Utility.getArg(args, 2), Utility.getArg(args,3));
      } catch (Exception e) {
         e.printStackTrace();
      }
   }

} // EO TestIIG class
