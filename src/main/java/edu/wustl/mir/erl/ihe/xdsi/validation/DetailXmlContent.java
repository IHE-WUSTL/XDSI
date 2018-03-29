/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.validation;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

import javax.xml.namespace.QName;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import edu.wustl.mir.erl.ihe.xdsi.util.PfnType;
import edu.wustl.mir.erl.ihe.xdsi.util.Utility;
import edu.wustl.mir.erl.ihe.xdsi.util.XDSINamespaceContext;
import edu.wustl.mir.erl.ihe.xdsi.util.XmlUtil;

/**
 * Base class for Detail comparing content of two XML document's 
 */
public abstract class DetailXmlContent extends Detail {
   
   private static XPathFactory xpathFactory = XPathFactory.newInstance();
   protected XPath xpath;
   protected QName[] qnames;
   private static Path xdsi;
   
   static {
      xdsi = Paths.get(Utility.getXDSIRoot());
   }
   
   private XPath getXPath() {
      if (xpath == null) {
         xpath = xpathFactory.newXPath();
         if (qnames != null) 
            xpath.setNamespaceContext(new XDSINamespaceContext(qnames));
      }
      return xpath;
   }
   
   /**
    * One element for each {@link XMLAssertion} being performed.
    */
   protected List<XMLAssertion> assertions = new ArrayList<>();
   
   /**
    * Implement in subclass for specific xml object content tested.
    * Shall set {@link #assertions} and {@link #desc}
    */
   protected abstract void initializeTests();
   
   protected String testPfn;
   protected String stdPfn;
   protected Element testElement;
   protected Element stdElement;
   
   /**
    * @param testPfn String pfn of test XML file. Absolute path or relative to XDSI Root.
    * @param stdPfn String pfn of std XML file used for comparison
    * (The "gold standard" XML). Absolute path or relative to XDSI Root.
    */
   @SuppressWarnings("hiding")
   protected void initializeDetail(String testPfn, String stdPfn) {
      initializeTests();
      this.testPfn = testPfn;
      this.stdPfn = stdPfn;
   }

   /* (non-Javadoc)
    * @see edu.wustl.mir.erl.ihe.xdsi.validation.Detail#runDetail()
    */
   @Override
   public void runDetail() throws Exception {
      String testVal = null;
      String stdVal = null;
      try {
         
         Path testPath = xdsi.resolve(testPfn);
         Utility.isValidPfn("test doc", testPath, PfnType.FILE, "r");
         testElement = XmlUtil.strToElement(FileUtils.readFileToString(testPath.toFile()));
         
         Path stdPath = xdsi.resolve(stdPfn);
         Utility.isValidPfn("std doc", stdPath, PfnType.FILE, "r");
         stdElement = XmlUtil.strToElement(FileUtils.readFileToString(stdPath.toFile()));
         
         for (XMLAssertion assertion : assertions) {
            switch (assertion.type) {
               case PRESENT:
                  testVal = (String) assertion.expr.evaluate(testElement, XPathConstants.STRING);
                  if (StringUtils.isNotBlank(testVal)) pass(assertion);
                  else fail(assertion);
                  break;
               case ABSENT:
                  testVal = (String) assertion.expr.evaluate(testElement, XPathConstants.STRING);
                  if (StringUtils.isBlank(testVal)) pass(assertion);
                  else fail(assertion);
                  break;
               case CONSTANT:
                  testVal = (String) assertion.expr.evaluate(testElement, XPathConstants.STRING);
                  if (testVal.equals(assertion.value)) pass(assertion, testVal);
                  else fail(assertion, testVal, assertion.value);
                  break;
               case SAME:
                  testVal = (String) assertion.expr.evaluate(testElement, XPathConstants.STRING);
                  stdVal = (String) assertion.expr.evaluate(stdElement, XPathConstants.STRING);
                  if (testVal.equals(stdVal)) pass(assertion, testVal);
                  else fail(assertion, testVal, stdVal);
                  break;
               case SAMEXFER:
                  sameXfer(assertion, testElement, stdElement);
                  break;
               case SAMEIMGS:
                  sameImgs(assertion, testElement, stdElement);
                  break;
               case SAMERETIMGS:
                  sameRetImgs(assertion, testElement, stdElement);
                  break;
               default:
                  throw new Exception("invalid test type");
            }
         }
         
      } catch (Exception e) {
         String em = "Evaluation error " + desc + " " + Utility.getEM(e);
         Utility.getLog().warn(em);
         errorCount++;
         errorDetails.add(em);
      } finally {

      }
   } // EO runDetail method
   
   private void pass(XMLAssertion test, String... values) {
      store(test, test.passCat, append(test.passDetail, values));
   }
   private void fail(XMLAssertion test, String... values) {
      store(test, test.failCat, append(test.failDetail, values));
   }
   private String append(String prefix, String[] values) {
      if (values.length > 0)
         prefix += " found-[" + values[0].trim() + "]";
      if (values.length > 1)
         prefix += " expected-[" + values[1].trim() + "]";
      return prefix;
   }
   
   private void store(XMLAssertion test, CAT cat, String detail) {
      switch (cat) {
         case SUCCESS:
            successCount++;
            successDetails.add(detail);
            break;
         case WARNING:
            warningCount++;
            warningDetails.add(detail);
            break;
         case ERROR:
            errorCount++;
            errorDetails.add(detail);
            break;
         case UNCAT:
            uncategorizedCount++;
            uncategorizedDetails.add(detail);
            break;
         case SILENT:
         default:
      }
   }
   
   /*
    * Process special assertion that RetrieveImagingDocumentSetRequest test and 
    * std have the same transfer syntaxes.
    */
   private void sameXfer(XMLAssertion a, Element test, Element std) 
      throws Exception {
      if (std.getTagName().endsWith("RetrieveImagingDocumentSetRequest") == false)
         throw new Exception("sameXfer assertion only applies to RetrieveImagingDocumentSetRequest");
      Set<String> stdS = new HashSet<>();
      Set<String> tstS = new HashSet<>();
      NodeList stdX = std.getElementsByTagNameNS("*","TransferSyntaxUID");
      for (int i = 0; i < stdX.getLength(); i++) {
         stdS.add(stdX.item(i).getTextContent());
      }
      NodeList tst = test.getElementsByTagNameNS("*", "TransferSyntaxUIDList");
      if (tst == null || tst.getLength() == 0) {
         store(a, CAT.ERROR, "TransferSyntaxUIDList element not found");
         return;
      }
      tst = ((Element) tst.item(0)).getElementsByTagNameNS("*", "TransferSyntaxUID");
      if (tst == null || tst.getLength() == 0) {
         store(a, CAT.ERROR, "No TransferSyntaxUID elements found");
         return;         
      }
      for (int i = 0; i < tst.getLength(); i++) {
         tstS.add(tst.item(i).getTextContent());
      }
      for (String s : tstS) {
         if (stdS.contains(s)) {
            store(a, CAT.SUCCESS, "TransferSyntaxUID " + s + " values match.");
            stdS.remove(s);
            continue;
         }
         store(a, CAT.ERROR, "TransferSyntaxUID " + s + " in test, does not match.");
      }
      for (String s : stdS) 
         store(a, CAT.ERROR, "TransferSyntaxUID " + s + " expected, not found.");
   }
   /*
    * Process special assertion that RetrieveImagingDocumentSetRequest test and 
    * std have the same image request data
    */
   private void sameImgs(XMLAssertion a, Element test, Element std) throws Exception {
      String t = std.getTagName();
      if (std.getTagName().endsWith("RetrieveImagingDocumentSetRequest") == false)
         throw new Exception("sameXfer assertion only applies to RetrieveImagingDocumentSetRequest");
      Map<String, Img> testImgs = loadImgs(a, test);
      Map<String, Img> stdImgs = loadImgs(a, std);
      Set<String> testKeys = testImgs.keySet();
      for (String testKey : testKeys) {
         if (stdImgs.containsKey(testKey) == false) {
            store(a, CAT.ERROR, "test doc UID " + testKey + ", not found in standard.");
            continue;
         }
         Img testImg = testImgs.get(testKey);
         Img stdImg = stdImgs.get(testKey);
         stdImgs.remove(testKey);
         if (stdImg.study.equals(testImg.study) &&
             stdImg.series.equals(testImg.series) &&
             comp(stdImg.home, testImg.home) &&
             comp(stdImg.repo, testImg.repo)) {
            store(a, CAT.SUCCESS, "test doc UID " + testKey + ", all values match.");
            continue;
         }
         store(a, CAT.SUCCESS, "test doc UID " + testKey + ", found in std.");
         if (testImg.study.equals(stdImg.study) == false)
            store(a, CAT.ERROR, "for doc with UID: " + testKey + " studyInstanceUID mismatch (std/test): (" + stdImg.study + "/" + testImg.study + ")");
         if (testImg.series.equals(stdImg.series) == false)
            store(a, CAT.ERROR, "for doc with UID: " + testKey + " seriesInstanceUID mismatch (std/test): (" + stdImg.series + "/" + testImg.series + ")");
         if (comp(stdImg.home, testImg.home) == false)
            store(a, CAT.ERROR, "for doc with UID: " + testKey + " homeCommunityID mismatch (std/test): (" + stdImg.home + "/" + testImg.home + ")");
         if (comp(stdImg.repo, testImg.repo) == false)
            store(a, CAT.ERROR, "for doc with UID: " + testKey + " RepositoryUniqueID mismatch (std/test): (" + stdImg.repo + "/" + testImg.repo + ")");
      }
      if (stdImgs.isEmpty()) return;
      Set<String> stdKeys = stdImgs.keySet();
      for (String key : stdKeys) 
         store(a, CAT.ERROR, "std doc UID: " + key + " not found in test msg.");
   }
   /*
    * helper for sameImgs, loads map of data for each requested image, with
    * instance UID as key. invoked for test and std.
    */
   private Map <String, Img> loadImgs(XMLAssertion a, Element msg) {
      Map <String, Img> imgs = new LinkedHashMap <>();
      NodeList docs = msg.getElementsByTagNameNS("*", "DocumentRequest");
      if (docs == null || docs.getLength() == 0) {
         store(a, CAT.ERROR, "No DocumentRequest element(s) found.");
         return imgs;     
      }
      for (int i = 0; i < docs.getLength(); i++) {
         Img img = new Img();
         Element docReq = (Element) docs.item(i);
         Element serReq = (Element) docReq.getParentNode();
         Element stdReq = (Element) serReq.getParentNode();
         img.study = stdReq.getAttribute("studyInstanceUID");
         img.series = serReq.getAttribute("seriesInstanceUID");
         img.instance = loadTxt(docReq, "DocumentUniqueId");
         img.home = loadTxt(docReq, "HomeCommunityId");
         img.repo = loadTxt(docReq, "RepositoryUniqueId");
         imgs.put(img.instance, img);
      }
      return imgs;
   }
   /*
    * helper for loadImgs. Gets text content of child tagName of element e.
    * Returns null if no such child or more than one such child.
    */
   private String loadTxt(Element e, String tagName) {
      NodeList children = e.getElementsByTagNameNS("*", tagName);
      if (children == null || children.getLength() != 1) return null;
      return children.item(0).getTextContent();
   }
   /*
    * helper method for string compares between std and test where an empty
    * or null std value means the value is not required. Used for home and
    * repository UIDs.
    */
   private boolean comp(String std, String test) {
      if (std  == null || std.length()  == 0) return true;
      if (test == null || test.length() == 0) return false;
      return std.equals(test);
   }
   /*
    * holds stuff for image used in sameImgs special assertion
    */
   class Img {
      String study;
      String series;
      String instance;
      String home;
      String repo;
   }
   
   private void sameRetImgs(XMLAssertion a, Element test, Element std) throws Exception {
      String t = std.getTagName();
      if (std.getTagName().endsWith("RetrieveDocumentSetResponse") == false)
         throw new Exception("sameXfer assertion only applies to RetrieveDocumentSetResponse");
      Map<String, RetImg> testImgs = loadRetImgs(a, test);
      Map<String, RetImg> stdImgs = loadRetImgs(a, std);
      Set<String> testKeys = testImgs.keySet();
      for (String testKey : testKeys) {
         if (stdImgs.containsKey(testKey) == false) {
            store(a, CAT.ERROR, "test doc UID " + testKey + ", not found in standard.");
            continue;
         }
         RetImg testImg = testImgs.get(testKey);
         RetImg stdImg = stdImgs.get(testKey);
         stdImgs.remove(testKey);
         if (comp(stdImg.home, testImg.home) &&
             comp(stdImg.repo, testImg.repo) &&
             comp(stdImg.mime, testImg.mime)) {
            store(a, CAT.SUCCESS, "test doc UID " + testKey + ", all values match.");
            continue;
         }
         store(a, CAT.SUCCESS, "test doc UID " + testKey + ", found in std.");
         if (comp(stdImg.home, testImg.home) == false)
            store(a, CAT.ERROR, "for doc with UID: " + testKey + " homeCommunityID mismatch (std/test): (" + stdImg.home + "/" + testImg.home + ")");
         if (comp(stdImg.repo, testImg.repo) == false)
            store(a, CAT.ERROR, "for doc with UID: " + testKey + " RepositoryUniqueID mismatch (std/test): (" + stdImg.repo + "/" + testImg.repo + ")");
         if (comp(stdImg.mime, testImg.mime) == false)
            store(a, CAT.ERROR, "for doc with UID: " + testKey + " mimeType mismatch (std/test): (" + stdImg.mime + "/" + testImg.mime + ")");
      }
      if (stdImgs.isEmpty()) return;
      Set<String> stdKeys = stdImgs.keySet();
      for (String key : stdKeys) 
         store(a, CAT.ERROR, "std doc UID: " + key + " not found in test msg.");
   }
   
   private Map<String, RetImg> loadRetImgs(XMLAssertion a, Element msg) {
      Map<String, RetImg> imgs = new LinkedHashMap<>();
      NodeList docs = msg.getElementsByTagNameNS("*",  "DocumentResponse");
      if (docs == null || docs.getLength() == 0) {
         store(a, CAT.ERROR, "No DocumentResponse element(s) found.");
         return imgs;     
      }
      for (int i = 0; i < docs.getLength(); i++) {
         RetImg img = new RetImg();
         Element docReq = (Element) docs.item(i);
         img.instance = loadTxt(docReq, "DocumentUniqueId");
         img.home = loadTxt(docReq, "HomeCommunityId");
         img.repo = loadTxt(docReq, "RepositoryUniqueId");
         img.mime = loadTxt(docReq, "mimeType");
         imgs.put(img.instance, img);
      }
      return imgs;
   }
      
   class RetImg {
      String instance;
      String home;
      String repo;
      String mime;
   }
   /**
    * Encapsulates parameters for one test
    */
   protected class XMLAssertion {
      TYPE type;
      String name = "";
      XPathExpression expr = null;
      String value;
      CAT passCat = CAT.SUCCESS;
      CAT failCat = CAT.ERROR;
      String passDetail;
      String failDetail;
      
      /**
       * Create a new XML Assertion 
       * @param name human readable name short assertion, for example, "patient id".
       * @param type TYPE of assertion to make
       * @param xpathExpression for value being tested.
       * @param value value to match (CONSTANT TYPE only).
       * @param cat CATs to use, first is pass (default SUCCESS), second is fail
       * (default ERROR)
       */
      XMLAssertion(String name, TYPE type, String xpathExpression, String value, CAT... cat) {
         this.type = type;
         this.name = name;
         if (this.type.needsXpath) this.expr = compile(xpathExpression);
         this.value = value;
         if (cat.length > 0) this.passCat = cat[0];
         this.passDetail = gpd(type.passDetail);
         if (cat.length > 1) this.failCat = cat[1];
         this.failDetail = gpd(type.failDetail);
      }

      private XPathExpression compile(String xpathExpression) {
         try {
            return getXPath().compile(xpathExpression);
         } catch (Exception e) {
            Utility.getLog().error(Utility.getEM(e));
         }
         return null;
      }

      private String gpd(String dtl) {
         if (dtl.contains("%")) dtl = dtl.replace("%", name);
         if (dtl.contains("$")) dtl = dtl.replace("$", value);
         return dtl;
      }
      
   } // EO inner class XmlAssertion
   
   protected enum TYPE {

         PRESENT("% present", "% missing", true), 
         ABSENT("% not present as expected", "% found when it should be absent", true),
         CONSTANT("correct % value", "incorrect % value", true), 
         SAME("% values match", "% values do not match", true),
         SAMEIMGS("% values match", "% values do not match", false),
         SAMEXFER("% values match", "% values do not match", false),
         SAMERETIMGS("% values match", "% values do not match", false);

      private TYPE(String pass, String fail, boolean xpath) {
         passDetail = pass;
         failDetail = fail;
         needsXpath = xpath;
      }

      String passDetail;
      String failDetail;
      boolean needsXpath;
      
      /**
       * Get TYPE which matches name, ignoring case, or null
       * @param name of TYPE
       * @return TYPE for name
       */
      public static TYPE forThis(String name) {
         TYPE[] types = TYPE.values();
         for (TYPE type : types) {
            if (type.name().equalsIgnoreCase(name)) return type;
         }
         return null;
      }
   };
   
   
   
   
   
   
   
}
