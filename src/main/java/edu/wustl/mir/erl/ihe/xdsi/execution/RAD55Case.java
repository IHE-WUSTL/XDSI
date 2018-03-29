/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.execution;

import java.io.Serializable;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import edu.wustl.mir.erl.ihe.xdsi.util.AEBean;
import edu.wustl.mir.erl.ihe.xdsi.util.PfnType;
import edu.wustl.mir.erl.ihe.xdsi.util.Utility;

/**
 * Test case for RAD-55 test IDC Simulate
 */
public class RAD55Case implements Serializable {
   private static final long serialVersionUID = 1L;

   private static SortedMap <Integer, RAD55Case> cases = new TreeMap <>();
   private static boolean casesLoaded = false;

   /**
    * @return boolean: Has standard cases list been loaded?
    */
   public static boolean init() {
      return casesLoaded;
   }

   /** initialize cases */
   private static Logger log = Utility.getLog();

   static {
      try {
         RAD55Case.loadCases();
      } catch (Exception e) {
         Utility.exit(e);
      }
   }

   private Integer number = null;
   private String desc = null;
   private String dir = null;
   private String pfn = null;
   private String url = null;

   private String acceptHeader = null;
   private String requestType = null;
   private String studyUID = null;
   private String seriesUID = null;
   private String objectUID = null;
   private String contenType = null;
   private String charset = null;
   private String anonymize = null;
   private String annotation = null;
   private String rows = null;
   private String columns = null;
   private String region = null;
   private String windowCenter = null;
   private String windowWidth = null;
   private String frameNumber = null;
   private String imageQuality = null;
   private String presentationUID = null;
   private String presentationSeriesUID = null;
   private String transferSyntaxUID = null;
   
   /**
    * new instance, all properties null.
    */
   public RAD55Case() {}
   /**
    * copy constructor
    * @param other instance to copy from
    */
   public RAD55Case (RAD55Case other) {
      number = other.number;
      desc = other.desc;
      dir = other.dir;
      pfn = other.pfn;
      url = other.url;
      acceptHeader = other.acceptHeader;
      requestType = other.requestType;
      studyUID = other.studyUID;
      seriesUID = other.seriesUID;
      objectUID = other.objectUID;
      contenType = other.contenType;
      charset = other.charset;
      anonymize = other.anonymize;
      annotation = other.annotation;
      rows = other.rows;
      columns = other.columns;
      region = other.region;
      windowCenter = other.windowCenter;
      windowWidth = other.windowWidth;
      frameNumber = other.frameNumber;
      imageQuality = other.imageQuality;
      presentationUID = other.presentationUID;
      presentationSeriesUID = other.presentationSeriesUID;
      transferSyntaxUID = other.transferSyntaxUID;
   }

   /**
    * @return the {@link #number} value.
    */
   public Integer getNumber() {
      return number;
   }

   /**
    * @param number the {@link #number} to set
    */
   public void setNumber(Integer number) {
      this.number = number;
   }

   /**
    * @return the {@link #desc} value.
    */
   public String getDesc() {
      return desc;
   }

   /**
    * @param desc the {@link #desc} to set
    */
   public void setDesc(String desc) {
      this.desc = desc;
   }

   /**
    * @return the {@link #dir} value.
    */
   public String getDir() {
      return dir;
   }

   /**
    * @param dir the {@link #dir} to set
    */
   public void setDir(String dir) {
      this.dir = dir;
   }

   /**
    * @return the {@link #pfn} value.
    */
   public String getPfn() {
      return pfn;
   }

   /**
    * @param pfn the {@link #pfn} to set
    */
   public void setPfn(String pfn) {
      this.pfn = pfn;
   }

   /**
    * @return the {@link #url} value.
    */
   public String getUrl() {
      return url;
   }

   /**
    * @param url the {@link #url} to set
    */
   public void setUrl(String url) {
      this.url = url;
   }
   
   /**
    * Set {@link #url} for DICOM using {@link AEBean}.
    * @param name String name of AEBean to use.
    */
   public void setDcmUrlFromAEBean(String name) {
      AEBean ae = AEBean.loadFromConfigurationFile(name);
      url = "http://" + ae.getHost() + ":" + ae.getWadoPort() + "/" + ae.getWadoPath();
   }
   
   /**
    * Set {@link #url} for WADO using {@link AEBean}.
    * @param name String name of AEBean to use.
    */
   public void setWADOUrlFromAEBean(String name) {
      AEBean ae = AEBean.loadFromConfigurationFile(name);
      url = "http://" + ae.getHost() + ":" + ae.getWadoPort() + "/" + ae.getWadoPath();
   }

   /**
    * @return the {@link #acceptHeader} value.
    */
   public String getAcceptHeader() {
      return acceptHeader;
   }

   /**
    * @param acceptHeader the {@link #acceptHeader} to set
    */
   public void setAcceptHeader(String acceptHeader) {
      this.acceptHeader = acceptHeader;
   }

   /**
    * @return the {@link #requestType} value.
    */
   public String getRequestType() {
      return requestType;
   }

   /**
    * @param requestType the {@link #requestType} to set
    */
   public void setRequestType(String requestType) {
      this.requestType = requestType;
   }

   /**
    * @return the {@link #studyUID} value.
    */
   public String getStudyUID() {
      return studyUID;
   }

   /**
    * @param studyUID the {@link #studyUID} to set
    */
   public void setStudyUID(String studyUID) {
      this.studyUID = studyUID;
   }

   /**
    * @return the {@link #seriesUID} value.
    */
   public String getSeriesUID() {
      return seriesUID;
   }

   /**
    * @param seriesUID the {@link #seriesUID} to set
    */
   public void setSeriesUID(String seriesUID) {
      this.seriesUID = seriesUID;
   }

   /**
    * @return the {@link #objectUID} value.
    */
   public String getObjectUID() {
      return objectUID;
   }

   /**
    * @param objectUID the {@link #objectUID} to set
    */
   public void setObjectUID(String objectUID) {
      this.objectUID = objectUID;
   }

   /**
    * @return the {@link #contenType} value.
    */
   public String getContenType() {
      return contenType;
   }

   /**
    * @param contenType the {@link #contenType} to set
    */
   public void setContenType(String contenType) {
      this.contenType = contenType;
   }

   /**
    * @return the {@link #charset} value.
    */
   public String getCharset() {
      return charset;
   }

   /**
    * @param charset the {@link #charset} to set
    */
   public void setCharset(String charset) {
      this.charset = charset;
   }

   /**
    * @return the {@link #anonymize} value.
    */
   public String getAnonymize() {
      return anonymize;
   }
   
   /**
    * @return {@link #anonymize} value in boolean form
    */
   public boolean getBooleanAnonymize() {
      if (anonymize == null) return false;
      return true;
   }

   /**
    * @param anonymize the {@link #anonymize} to set
    */
   public void setAnonymize(String anonymize) {
      this.anonymize = anonymize;
   }
   /**
    * @param anonymize set anonymize from boolean
    */
   public void setAnonymize(boolean anonymize) {
      if (anonymize == false) this.anonymize = null;
      this.anonymize = "yes";
   }

   /**
    * @return the {@link #annotation} value.
    */
   public String getAnnotation() {
      return annotation;
   }

   /**
    * @param annotation the {@link #annotation} to set
    */
   public void setAnnotation(String annotation) {
      this.annotation = annotation;
   }

   /**
    * @return the {@link #rows} value.
    */
   public String getRows() {
      return rows;
   }

   /**
    * @return the {@link #rows} value.
    */
   public Integer getIntegerRows() {
      return integer(rows);
   }

   /**
    * @param rows the {@link #rows} to set
    */
   public void setRows(String rows) {
      this.rows = rows;
   }

   /**
    * @return the {@link #columns} value.
    */
   public String getColumns() {
      return columns;
   }

   /**
    * @return the {@link #columns} value.
    */
   public Integer getIntegerColumns() {
      return integer(columns);
   }

   /**
    * @param columns the {@link #columns} to set
    */
   public void setColumns(String columns) {
      this.columns = columns;
   }

   /**
    * @return the {@link #region} value.
    */
   public String getRegion() {
      return region;
   }

   /**
    * @param region the {@link #region} to set
    */
   public void setRegion(String region) {
      this.region = region;
   }

   /**
    * @return the {@link #windowCenter} value.
    */
   public String getWindowCenter() {
      return windowCenter;
   }

   /**
    * @param windowCenter the {@link #windowCenter} to set
    */
   public void setWindowCenter(String windowCenter) {
      this.windowCenter = windowCenter;
   }

   /**
    * @return the {@link #windowWidth} value.
    */
   public String getWindowWidth() {
      return windowWidth;
   }

   /**
    * @param windowWidth the {@link #windowWidth} to set
    */
   public void setWindowWidth(String windowWidth) {
      this.windowWidth = windowWidth;
   }

   /**
    * @return the {@link #frameNumber} value.
    */
   public String getFrameNumber() {
      return frameNumber;
   }

   /**
    * @return the {@link #frameNumber} value.
    */
   public Integer getIntegerFrameNumber() {
      return integer(frameNumber);
   }

   /**
    * @param frameNumber the {@link #frameNumber} to set
    */
   public void setFrameNumber(String frameNumber) {
      this.frameNumber = frameNumber;
   }

   /**
    * @return the {@link #imageQuality} value.
    */
   public String getImageQuality() {
      return imageQuality;
   }

   /**
    * @return the {@link #imageQuality} value.
    */
   public Integer getIntegerImageQuality() {
      return integer(imageQuality);
   }

   /**
    * @param imageQuality the {@link #imageQuality} to set
    */
   public void setImageQuality(String imageQuality) {
      this.imageQuality = imageQuality;
   }

   /**
    * @return the {@link #presentationUID} value.
    */
   public String getPresentationUID() {
      return presentationUID;
   }

   /**
    * @param presentationUID the {@link #presentationUID} to set
    */
   public void setPresentationUID(String presentationUID) {
      this.presentationUID = presentationUID;
   }

   /**
    * @return the {@link #presentationSeriesUID} value.
    */
   public String getPresentationSeriesUID() {
      return presentationSeriesUID;
   }

   /**
    * @param presentationSeriesUID the {@link #presentationSeriesUID} to set
    */
   public void setPresentationSeriesUID(String presentationSeriesUID) {
      this.presentationSeriesUID = presentationSeriesUID;
   }

   /**
    * @return the {@link #transferSyntaxUID} value.
    */
   public String getTransferSyntaxUID() {
      return transferSyntaxUID;
   }

   /**
    * @param transferSyntaxUID the {@link #transferSyntaxUID} to set
    */
   public void setTransferSyntaxUID(String transferSyntaxUID) {
      this.transferSyntaxUID = transferSyntaxUID;
   }
   /**
    * returns Integer for String
    * @param intValue String to be processed.
    * @return Decimal Integer represented by String, or MAX_VALUE if String
    * does not represent a valid Integer
    */
   private Integer integer(String intValue) {
      Integer val = Integer.MAX_VALUE;
      try {
         val = Integer.parseInt(intValue);
      } catch (Exception nfe) { }
      return val;
   }

   /**
    * Return copies of cases from the standard list for processing.
    * @param numbers case numbers of cases to return. Numbers which do not
    * correspond to cases in the standard list are ignored.
    * @return an array of RAD55Case instances from the standard list for the
    * passed case numbers, in the order the case numbers are listed as
    * arguments. If no case numbers are passed, return the entire standard list
    * in case number order.
    */
   public static RAD55Case[] getCaseCopies(Integer... numbers) {
      if (casesLoaded == false) return null;
      RAD55Case[] cs = cases.values().toArray(new RAD55Case[0]);
      if (numbers.length > 0) {
         List <RAD55Case> kases = new ArrayList <>();
         for (Integer i : numbers) {
            RAD55Case c = cases.get(i);
            if (c != null) kases.add(c);
         }
         cs = kases.toArray(new RAD55Case[0]);
      } 
      for (int i = 0; i < cs.length; i++)
         cs[i] = new RAD55Case(cs[i]);
      return cs;
   }

   private static void loadCases() throws Exception {
      if (casesLoaded == true) return;
      casesLoaded = true;
      RAD55Case c = null;

      Path xlsxPath = Utility.getRunDirectoryPath().resolve("RAD55Cases.xlsx");
      Utility.isValidPfn("RAD55Cases spreadsheet", xlsxPath, PfnType.FILE, "r");
      // Open workbook
      try (XSSFWorkbook wb = new XSSFWorkbook(xlsxPath.toFile())) {
         XSSFSheet sheet = wb.getSheetAt(0);
         log.info("Loading RAD55Cases.xlsx");

         Iterator <Row> rows = sheet.rowIterator();
         // Load columns from 1st row; duplicates are ignored
         cols = new HashMap <>();
         row = rows.next();
         for (int i = row.getFirstCellNum(); i < row.getLastCellNum(); i++ ) {
            Cell cell = row.getCell(i);
            if (cell == null || cell.getCellType() != Cell.CELL_TYPE_STRING) continue;
            cols.putIfAbsent(cell.getStringCellValue().trim(), i);
         }
         // Load cases from remaining rows. Duplicate case numbers ignored
         while (rows.hasNext()) {
            row = rows.next();
            if (isRowEmpty()) continue;

            c = new RAD55Case();

            c.setNumber((int) row.getCell(cols.get("number")).getNumericCellValue());

            c.setDesc(get("desc"));
            c.setAcceptHeader(get("acceptHeader"));
            c.setRequestType(get("requestType"));
            c.setContenType(get("contentType"));
            c.setCharset(get("charset"));
            c.setAnonymize(get("anonymize"));
            c.setAnnotation(get("annotation"));
            c.setRows(get("rows"));
            c.setColumns(get("columns"));
            c.setRegion(get("region"));
            c.setWindowCenter(get("windowCenter"));
            c.setWindowWidth(get("windowWidth"));
            c.setFrameNumber(get("frameNumber"));
            c.setImageQuality(get("imageQuality"));
            c.setPresentationUID(get("presentationUID"));
            c.setPresentationSeriesUID(get("presentationSeriesUID"));
            c.setTransferSyntaxUID(get("transferSyntaxUID"));

            cases.putIfAbsent(c.getNumber(), c);
            log.trace(String.format("%4d ", c.getNumber()) + c.getDesc());
         } // EO iterate rows
         log.info("RAD55Cases.xlsx loaded");
      } catch (Exception e) {
         Utility.exit(e);
      }
   } // EO loadCases method

   private static Row row = null;
   private static Map <String, Integer> cols = null;

   private static String get(String colName) {
      Integer col = cols.get(colName);
      if (col == null) return null;
      Cell cell = row.getCell(col);
      if (cell == null || cell.getCellType() != Cell.CELL_TYPE_STRING) return null;
      return StringUtils.trimToNull(cell.getStringCellValue());
   }

   /**
    * Checks to see if current row is empty.
    * @return true if row is empty, false otherwise
    */
   private static boolean isRowEmpty() {
      if (row.getPhysicalNumberOfCells() == 0) return true;
      for (int c = row.getFirstCellNum(); c < row.getLastCellNum(); c++ ) {
         Cell cell = row.getCell(c);
         if (cell != null && cell.getCellType() != Cell.CELL_TYPE_BLANK) return false;
      }
      return true;
   }

}
