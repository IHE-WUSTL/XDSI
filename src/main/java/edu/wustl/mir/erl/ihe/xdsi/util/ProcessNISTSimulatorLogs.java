/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.util;

import java.io.FilenameFilter;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.SimpleDateFormat;
import java.util.*;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;


/**
 * Used to pull information from NIST xdstools2 simulator logs
 */
public class ProcessNISTSimulatorLogs {

   private static Logger log = Utility.getLog();
   private static Path xdsiPath = Utility.getXDSIRootPath();

   private static SimpleDateFormat timeOfTransactionFormat = new SimpleDateFormat("yyyyMMddHHmmssSSS");
   private static String externalCache = xdsiPath.resolve("xds-toolkit").resolve("01").toString();
   
   /**
    * Processes all {@code <GetSoap>} elements in test xml file, loading results
    * for transactions processed by xdstools simulators into results directories.
    * @param test root (Test) {@link Element} of test xml file.
    * @param session Test user session, for example, "acme".
    * @param resultDir root directory for results, absolute or relative to XDSI
    * root directory. For example, "results/acme/iig/iig-1001". Transaction id
    * will be added as subdirectory, for example "results/acme/iig/iig-1001/RAD-69".
    * To use default path, use {@link #getSimulatorTestResults(Element, String, String)}.
    * @throws Exception on error.
    */
   public static void getSimulatorTestResults(Element test, String session, 
      String resultDir) throws Exception {
      Path resultDirPath = Utility.getXDSIRootPath().resolve(resultDir);
      Utility.isValidPfn("results dir", resultDirPath, PfnType.DIRECTORY, "rwx");
      NodeList nodes = test.getElementsByTagName("GetSoap");
      if (nodes == null) return;
      for (int i = 0; i < nodes.getLength(); i++) {
         Element getSoapElement = (Element) nodes.item(i);
         Element transactionElement = (Element) getSoapElement.getParentNode();
         List<String> simulatorTypes = new ArrayList<>();
         String transactionId = transactionElement.getAttribute("id");
         String simulatorName = getSoapElement.getAttribute("simulatorName");
         String t = getSoapElement.getAttribute("simulatorType");
         simulatorTypes.add(t);
         if (t.equals("iig")) simulatorTypes.add("cig");
         if (t.equals("rig")) simulatorTypes.add("crg");
         String transactionType = getSoapElement.getAttribute("transactionType");         
         Path logDirPath = null;
         for (String simulatorType : simulatorTypes) {
            try {
            logDirPath = 
               getTransactionLogDirectoryPath(session + "__" + simulatorName,
               simulatorType, transactionType, null, null);
            break;
            } catch (Exception e) {}
         }
         if (logDirPath == null) 
            throw new Exception("Could not find log directory for simulator: " + session + "__" + simulatorName);
         String outDir = resultDirPath.resolve(transactionId).toString();
         getSOAPComponents(logDirPath, outDir, transactionType);
      }
   }
   
   /**
    * Processes all {@code <GetSoap>} elements in test xml file, loading results
    * for transactions processed by xdstools simulators into default results
    * directories.
    * @param test root (Test) {@link Element} of test xml file.
    * @param session Test user session, for example, "acme".
    * @throws Exception Exception on error.
    */
   public static void getSimulatorTestResults(Element test, String session) 
      throws Exception {
      String id = test.getAttribute("id");
      String sut = test.getAttribute("sut");
      if (sut.isEmpty()) sut = StringUtils.substringBefore(id, "-");
      String resultDir = Utility.getResultsDirectory(id, session).toString();
      getSimulatorTestResults(test, session, resultDir);
   }
   
   /**
    * Retrieve SOAP Message components in "standard" form for validation.
    * <p/>
    * This method will create a "response" subdirectory in outDir, deleting 
    * existing contents of the directory if any. It will then
    * retrieve the SOAP Request and Response messages from the NIST log and 
    * generate the following files in the response subdirectory (all in String
    * format):<ul>
    * <li/> Request.xml - The entire SOAP request (raw).
    * <li/> Response.xml - The entire SOAP response (raw).
    * <li/> RequestHeader.xml - The SOAP request envelope header.
    * <li/> ResponseHeader.xml - The SOAP response envelope header.
    * <li/> RequestBody.xml - The SOAP request envelope body. The root element
    * of this file will be the child element of {@code <env:Body>}, for example,
    * the {@code <xdsiB:RetrieveImagingDocumentSetRequest>} element.
    * <li/> ResponseBody.xml - The SOAP response envelope header. The root 
    * element of this file will be the child element of {@code <env:Body>}, for 
    * example, the {@code <xdsiB:RetrieveDocumentSetResponse>} element.</ul>
    * Additional processing for RAD-69 and RAD-75 (assuming that the ResponseBody
    * can be parsed):<ul>
    * <li/>An "attachments" subdirectory will be created in outDir, deleting
    * existing contents of the directory if any.
    * <li/>Documents passed in the {@code <xdsiB:RetrieveDocumentSetResponse>}
    * element will be decoded and written to this directory.<ul>
    * <li/>The file name will be the Document Unique ID, with the extension
    * ".dcm".
    * <li/>If the {@code <DocumentUniqueId>} element is missing or blank, the
    * string "unknown" will be substituted.
    * <li/>If duplicate Document Unique Id's (or multiple unknown ids) are
    * encountered, a counter value will be added to the file name to avoid
    * duplicates.</ul> 
    * </ul>If the SOAP Request and/or Response cannot be parsed, the corresponding
    * Header and Body files will not be present, but the raw Request and
    * Response xml files should always be present.<p/>
    * 
    * @param dir xdstools log directory for transaction.
    * @param outDir directory to put file in, absolute or relative to XDSI root.
    * @param transactionType type of transaction from xtools. If this is a
    * dicom image retrieve, the document contents will be replaced by "..." for
    * brevity.
    * @throws Exception on error, such as IO error.
    */
   public static void getSOAPComponents(Path dir, String outDir, String transactionType) throws Exception {
      
      // validate/create response directory
      Path outDirPath = xdsiPath.resolve(outDir);
      respDirPath = outDirPath.resolve("response");
      Files.createDirectories(respDirPath);
      FileUtils.cleanDirectory(respDirPath.toFile());
      
      // SOAP Request
      String soapRequest;
      try {
         soapRequest = getSOAPRequest(dir, "", "");
         wrt("Request.xml", soapRequest);
         try {
            Element reqElement = XmlUtil.strToElement(soapRequest);
            String env = reqElement.getLocalName();
            if (env.equalsIgnoreCase("Envelope") == false)
               throw new Exception("root element not 'Envelope': [" + env + "]");
            try {
               Element[] hdrElement = XmlUtil.getFirstLevelChildElementsByName(reqElement, "Header"); 
               if (hdrElement.length == 0)
                  throw new Exception("'Header' element not found");
               if (hdrElement.length > 1)
                  throw new Exception(hdrElement.length + " 'Header' elements found");
               String header = XmlUtil.elementToStr(hdrElement[0]);
               wrt("RequestHeader.xml", header);
            } catch (Exception e)  {
               String em = "SOAP Request Header error: " + e.getMessage();
               log.warn(em);
               wrt("RequestHeader.err", em);
            }
            try {
               Element[] bodyElement = XmlUtil.getFirstLevelChildElementsByName(reqElement, "Body"); 
               if (bodyElement.length == 0)
                  throw new Exception("'Body' element not found");
               if (bodyElement.length > 1)
                  throw new Exception(bodyElement.length + " 'Body' elements found");
               bodyElement = XmlUtil.getFirstLevelChildElements(bodyElement[0]);
               if (bodyElement.length == 0)
                  throw new Exception("No child elements found in 'Body' element");
               if (bodyElement.length > 1)
                  throw new Exception(bodyElement.length + " child elements found in 'Body' element");
                  
               String body = XmlUtil.elementToStr(bodyElement[0]);
               wrt("RequestBody.xml", body);
            } catch (Exception e)  {
               String em = "SOAP Request Body error: " + e.getMessage();
               log.warn(em);
               wrt("RequestBody.err", em);
            }
         } catch (Exception e)  {
            String em = "Error parsing SOAP Request: " + e.getMessage();
            log.warn(em);
            wrt("Request.err", em);
         }
      } catch (Exception e) {
         String em = "Error reading SOAP Request: " + e.getMessage();
         log.warn(em);
         wrt("Request.err", em);
      }
      
      // SOAP Response
      String soapResponse;
      try {
         soapResponse = getSOAPResponse(dir, "", "");
         wrt("Response.xml", soapResponse);
         try {
            Element respElement = XmlUtil.strToElement(soapResponse);
            String env = respElement.getLocalName();
            if (env.equalsIgnoreCase("Envelope") == false)
               throw new Exception("root element not 'Envelope': [" + env + "]");
            try {
               Element[] hdrElement = XmlUtil.getFirstLevelChildElementsByName(respElement, "Header"); 
               if (hdrElement.length == 0)
                  throw new Exception("'Header' element not found");
               if (hdrElement.length > 1)
                  throw new Exception(hdrElement.length + " 'Header' elements found");
               String header = XmlUtil.elementToStr(hdrElement[0]);
               wrt("ResponseHeader.xml", header);
            } catch (Exception e)  {
               String em = "SOAP Response Header error: " + e.getMessage();
               log.warn(em);
               wrt("ResponseHeader.err", em);
            }
            try {
               Element[] bodyElement = XmlUtil.getFirstLevelChildElementsByName(respElement, "Body"); 
               if (bodyElement.length == 0)
                  throw new Exception("'Body' element not found");
               if (bodyElement.length > 1)
                  throw new Exception(bodyElement.length + " 'Body' elements found");
               bodyElement = XmlUtil.getFirstLevelChildElements(bodyElement[0]);
               if (bodyElement.length == 0)
                  throw new Exception("No child elements found in 'Body' element");
               if (bodyElement.length > 1)
                  throw new Exception(bodyElement.length + " child elements found in 'Body' element");
               Element respEle = bodyElement[0];
               // For brevity, dicom objects in response are truncated to "...".
               if (transactionType.equalsIgnoreCase("xcr.ids") || transactionType.equalsIgnoreCase("ids")) {
                  //Map<String, byte[]> docs = OMEUtil.getImgDocs(respEle);
                  Map<String, byte[]> docs = getImgDocs(respEle);
                  if (docs.isEmpty() == false) {
                     Path attDirPath = outDirPath.resolve("attachments");
                     Files.createDirectories(attDirPath);
                     FileUtils.cleanDirectory(attDirPath.toFile());
                     for (Map.Entry <String, byte[]> entry : docs.entrySet()) {
                        FileUtils.writeByteArrayToFile(attDirPath.resolve(entry.getKey() + ".dcm").toFile(), entry.getValue());
                     }
                     
                  }
                  XmlUtil.truncateDocuments(respEle);
               }
               String body = XmlUtil.elementToStr(respEle);
               wrt("ResponseBody.xml", body);
            } catch (Exception e)  {
               String em = "SOAP Response Body error: " + e.getMessage();
               log.warn(em);
               wrt("ResponseBody.err", em);
            }
         } catch (Exception e)  {
            String em = "Error parsing SOAP Response: " + e.getMessage();
            log.warn(em);
            wrt("Response.err", em);
         }
      } catch (Exception e) {
         String em = "Error reading SOAP Response: " + e.getMessage();
         log.warn(em);
         wrt("Response.err", em);
      }
      
   } // EO getSOAPComponents
   private static Path respDirPath;
   private static void wrt(String fn, String str) throws Exception {
      FileUtils.writeStringToFile(respDirPath.resolve(fn).toFile(), 
         str, Utility.utf8);
   }
   
   private static Map<String, byte[]> getImgDocs(Element respElement) throws Exception {
      Base64.Decoder decoder  = Base64.getMimeDecoder();
      Map<String, byte[]> imgDocs = new HashMap<>();
      for (Element docResponseElement: XmlUtil.getFirstLevelChildElementsByName(respElement, "DocumentResponse")) {
         Element docUidElement = XmlUtil.getFirstLevelChildElementByName(docResponseElement, "DocumentUniqueId");
         String docUid = XmlUtil.getFirstLevelTextContent(docUidElement);
         Element docElement = XmlUtil.getFirstLevelChildElementByName(docResponseElement, "Document");
         String docStr = XmlUtil.getFirstLevelTextContent(docElement);
         byte[] docBytes = decoder.decode(docStr);
         imgDocs.put(docUid, docBytes);
      }
      return imgDocs;
   }

   /**
    * Get SOAP Request message from xdstools log
    * 
    * @param dir xdstools log directory for transaction.
    * @param outDir directory to put file in, absolute or relative to XDSI root
    * @param fName name of file
    * @return xml SOAP Request.
    */
   public static String getSOAPRequest(Path dir, String outDir, String fName) {
      byte lt = "<".getBytes()[0];
      byte gt = ">".getBytes()[0];
      try {
         byte[] bytes = Files.readAllBytes(dir.resolve("request_body.bin"));
         int p = ByteUtils.indexOf(bytes, "Envelope".getBytes("UTF-8"), false);
         while (bytes[p] != lt)
            p-- ;
         bytes = ByteUtils.subbytes(bytes, p, false);
         p = ByteUtils.indexOf(bytes, "--MIMEBoundary".getBytes("UTF-8"), false);
         if (p == -1) {
            byte[] eoEnvelope = "</Envelope>".getBytes("UTF-8");
            p = ByteUtils.indexOf(bytes, "<Envelope".getBytes("UTF-8"), true);
            if (p != 0) {
               p = ByteUtils.indexOf(bytes, "<".getBytes("UTF-8"), true);
               int q = ByteUtils.indexOf(bytes, ":Envelope".getBytes("UTF-8"), true);
               byte[] ns = ByteUtils.subbytes(bytes, p + 1, q, true);
               eoEnvelope = ByteUtils.toBytes("</", new String(ns, "UTF-8"), ":Envelope>");
               p = ByteUtils.indexOf(bytes, eoEnvelope, true);
               if (p < 0) throw new Exception("getSOAPRequest: no MIMEBoundary or </Envelope>");
               while (bytes[p] != gt) p++; 
               p++;
            }
         }
         bytes = ByteUtils.subbytes(bytes, 0, p, false);
         String str = new String(bytes, "UTF-8").replaceAll("\\s+", " ");
         writeToFile(str, outDir, fName);
         return str;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return null;
   }

   /**
    * Store file from request.
    * 
    * @param dir xdstools log directory for transaction.
    * @param outDir directory to put file in, absolute or relative to XDSI root
    * @param fName name of file
    */
   public static void getSOAPFile(Path dir, String outDir, String fName) {
      try {
         Path repDir = dir.resolve("Repository");
         String inName = repDir.toFile().list()[0];
         Path inPath = repDir.resolve(inName);
         Path outPath = xdsiPath.resolve(outDir).resolve(fName);
         Files.copy(inPath, outPath, StandardCopyOption.REPLACE_EXISTING);
      } catch (Exception e) {
         e.printStackTrace();
      }
   }

   /**
    * Get SOAP Response message from xdstools log
    * 
    * @param dir xdstools log directory for transaction.
    * @param outDir directory to put file in, absolute or relative to XDSI root
    * @param fName name of file
    * @return xml SOAP Response.
    */
   public static String getSOAPResponse(Path dir, String outDir, String fName) {
      try {
         String str = FileUtils.readFileToString(dir.resolve("response_body.txt").toFile());
         int p = str.indexOf("Envelope");
         while (str.substring(p).startsWith("<") == false)
            p-- ;
         str = str.substring(p);
         p = str.indexOf("--MIMEBoundary");
         if (p != -1) str = str.substring(0, p);
         str = new String(str.replaceAll("\\s+", " "));
         writeToFile(str, outDir, fName);
         return str;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return null;
   }

   /**
    * Get SubmitObjectsRequest element from SOAP Request from xdstools log
    * 
    * @param dir xdstools log directory for transaction.
    * @param outDir directory to put file in, absolute or relative to XDSI root
    * @param fName name of file
    * @return xml SubmitObjectsRequest element and contents.
    */
   public static String getSOAPMetaData(Path dir, String outDir, String fName) {
      try {
         String tag = "SubmitObjectsRequest";
         String str = getSOAPRequest(dir, null, null);
         int p = str.indexOf(tag);
         while (str.substring(p).startsWith("<") == false)
            p-- ;
         str = str.substring(p);
         p = str.lastIndexOf(tag);
         while (str.substring(p).startsWith(">") == false)
            p++ ;
         str = str.substring(0, p + 1);
         writeToFile(str, outDir, fName);
         return str;
      } catch (Exception e) {
         e.printStackTrace();
      }
      return null;
   }

   /**
    * Gets the Path of the log directory for a specific transaction.
    * 
    * @param simulatorName the name of the xtools simulator. Mandatory.
    * @param simulatorType the xtools actor code, for example "rep" for repository,
    * or "reg" for registry. Default is "rep".
    * @param transactionCode the xtools transaction code, for example "prb" for
    * "provide and register". Default is "prb".
    * @param pid the Patient ID. If not null, only transactions for this patient
    * will be considered.
    * @param timeOfTransaction time the transaction was run. The Path returned
    * will be for the earliest transaction which is not before this time. If
    * null, method returns the most recently completed transaction.
    * @return absolute path to the log directory, or null. A null return means
    * there are no transactions or that all transactions were logged before the
    * passed time (probably an error).
    */
   public static Path getTransactionLogDirectoryPath(String simulatorName, 
      String simulatorType, String transactionCode, String pid,
      Date timeOfTransaction) {
      try {
         FilenameFilter filter = new PidDateFilenameFilter(pid, timeOfTransaction);
         if (StringUtils.isBlank(simulatorType)) simulatorType = "rep";
         if (StringUtils.isBlank(transactionCode)) transactionCode = "prb";
         Path base = Paths.get(externalCache, "simdb", simulatorName, simulatorType, transactionCode);
         Utility.isValidPfn("xtools log dir", base, PfnType.DIRECTORY, "r");
         String[] logDirs = base.toFile().list(filter);
         Arrays.sort(logDirs);
         if (logDirs.length == 0) {
            log.debug("No metadata folder found for actor " + simulatorType + " Patient ID " + pid);
            return null;
         }
         log.debug("Found " + logDirs.length + " folder matching search criteria; will return most recent folder");
         return base.resolve(logDirs[logDirs.length - 1]);
      } catch (Exception e) {
         e.printStackTrace();
      }
      return null;
   }

   private static void writeToFile(String str, String outDir, String fName) throws Exception {
      if (StringUtils.isBlank(outDir) || StringUtils.isBlank(fName)) return;
      Path pfn = xdsiPath.resolve(outDir).resolve(fName);
      Files.write(pfn, str.getBytes("UTF-8"));
   }

   /**
    * Test harness for ProcessNISTSimulatorLogs static methods.
    * <p/>
    * To retrieve SOAP message components, arguments:
    * <ol start=0>
    * <li/>GETSOAP = {@link #getSOAPComponents}
    * <li/>The simulator name from the NIST tools.
    * <li/>The simulator type from the NIST tools, for example "rg" for 
    * receiving gateway. Default is "rep" for repository.
    * <li/>The transaction type from the NIST tools, for example, "xcr.ids" for
    * a Cross Community retrieve image set. Default is "prb" for provide and
    * register.
    * <li/>The Transaction time in yyyyMMddHHmmssSSS format. If present, the 
    * first transaction after this time will be used. If null the most recent 
    * transaction will be used.
    * <li/>The output directory.
    * </ol>
    * For other methods, arguments: 
    * <ol start = 0> 
    * <li/>Method to test
    * <ul> 
    * <li/>GETREQUEST = {@link #getSOAPRequest} 
    * <li/>GETMETADATA = {@link #getSOAPMetaData} 
    * <li/>GETRESPONSE = {@link #getSOAPResponse}
    * <li/>GETKOS = {@link #getSOAPFile} 
    * </ul> 
    * <li/>The simulator name from the NIST xtools. 
    * <li/>The simulator type from the NIST tools, for example "rg" for 
    * receiving gateway. Default is "rep" for repository.
    * <li/>The transaction type from the NIST tools, for example, "xcr.ids" for
    * a Cross Community retrieve image set. Default is "prb" for provide and
    * register.
    * <li/>The patient ID, or null for any patient id. 
    * <li/>The Transaction time in yyyyMMddHHmmssSSS format. If present, the 
    * first transaction after this time will be used. If null the most recent
    * transaction will be used. 
    * <li/>The output directory, or null for no write.
    * <li/>The output file name, or null for no write. 
    * </ol>
    * Use "-" or "null" for null arguments, trailing null arguments may be
    * omitted.
    * 
    * @param args arguments
    */
   public static void main(String[] args) {
      try {
         xdsiPath = Paths.get(Utility.getXDSIRoot());
         log = Utility.getLog();
         String methodToTest = getArg(args, 0).toUpperCase();
         if (methodToTest.equals("GETSOAP")) args = new String[] { args[0], args[1], args[2], args[3], "-", args[4], args[5] };
         String simulatorName = getArg(args, 1);
         String simulatorType = getArg(args, 2);
         String transactionType = getArg(args, 3);
         String pid = getArg(args, 4);
         Date timeOfTransaction = null;
         String a3 = getArg(args, 5);
         if (a3 != null) timeOfTransaction = timeOfTransactionFormat.parse(a3);
         String outDir = getArg(args, 6);
         String fName = getArg(args, 7);
         if (pid != null) pid = pid + "^^^" + Identifiers.getAssigningAuthorityAffinityDomain();

         Path logDir =
            ProcessNISTSimulatorLogs.getTransactionLogDirectoryPath(simulatorName, simulatorType, transactionType, pid, timeOfTransaction);
         if (logDir == null) {
            log.error(
               "No metadata folder found for these criteria: " + simulatorName + " " + pid + " " + timeOfTransaction);
         } else {
            String req = "";
            switch (methodToTest) {
               case "GETSOAP":
                  ProcessNISTSimulatorLogs.getSOAPComponents(logDir, outDir, transactionType);
                  break;
               case "GETREQUEST":
                  req = ProcessNISTSimulatorLogs.getSOAPRequest(logDir, outDir, fName);
                  req = XmlUtil.prettyPrintSOAP(req);
                  log.info("SOAP Request:" + Utility.nl + req);
                  break;
               case "GETMETADATA":
                  req = ProcessNISTSimulatorLogs.getSOAPMetaData(logDir, outDir, fName);
                  req = XmlUtil.prettyPrintSOAP(req);
                  log.info("SOAP Request MetaData:" + Utility.nl + req);
                  break;
               case "GETRESPONSE":
                  req = ProcessNISTSimulatorLogs.getSOAPResponse(logDir, outDir, fName);
                  req = XmlUtil.prettyPrintSOAP(req);
                  log.info("SOAP Response:" + Utility.nl + req);
                  break;
               case "GETKOS":
                  ProcessNISTSimulatorLogs.getSOAPFile(logDir, outDir, fName);
                  break;
               default:
                  throw new Exception("no such command: " + methodToTest);
            }
            log.info(methodToTest + " test completed");
         }
      } catch (Exception e) {
         log.fatal("test failed" + e.getMessage());
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

} // EO ProcessNISTSimulatorLogs
