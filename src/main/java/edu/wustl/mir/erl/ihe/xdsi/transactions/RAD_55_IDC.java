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

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Templates;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXTransformerFactory;
import javax.xml.transform.sax.TransformerHandler;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

//import org.apache.commons.cli.Options;
import org.dcm4che3.data.Attributes;
import org.dcm4che3.io.SAXReader;
import org.dcm4che3.io.SAXWriter;
import org.dcm4che3.tool.common.SimpleHTTPResponse;

import edu.wustl.mir.erl.ihe.xdsi.util.Utility;

/**
 * Class used to simulate an Image Data Consumer (IDC) Sending a WADO Retrieve
 * (RAD-55) transaction to an Imaging Document Source (IDS) Primary Reference:
 * IHE RAD TF-3 Section 4.55 
 * 
 * Adapted from org.dcm4che3.tool.wadouri.WadoURI in dcm4che3
 */

/*
Usage:
	RAD_55_IDC studyUID:seriesUID:objectUID pacs_url contentType output_directory output_file_name
	
Examples:
$ RAD_55_IDC 1.2.3:1.2.3.4:1.2.3.4.5 http://localhost:8080/dcm4che-arc/wado/DCM4CHEE  "application/dicom" /tmp testFile

$ RAD_55_IDC 1.2.392.200036.9116.4.1.5799.1783:1.2.392.200036.9116.4.1.5799.1783.17001:1.2.392.200036.9116.4.1.5799.1783.17.1001.8.600515536 http://172.16.118.133:8080/dcm4chee-web3/  "application/dicom" /Users/Kelsey/Projects/IHE/XDSI/git/erl-ihe-xdsi/sandbox_kelsey/retrieved wado_file

*/

@SuppressWarnings("javadoc")
public class RAD_55_IDC extends ClientTransaction {

//	private static Options options;

	private SAXTransformerFactory saxTransformer;

	private Templates xsltTemplates;

	private File outDir;

	private File xsltFile;

	private String outFileName;

	private String requestTimeOut;

	private boolean xmlIndent = false;

	private boolean xmlIncludeKeyword = true;

	private String url;

	private String objectID;

	private String contentType;

	private String charset;

	private boolean anonymize;

	private String annotation;

	private int rows = Integer.MAX_VALUE;

	private int columns = Integer.MAX_VALUE;

	private String regionCoordinates;

	private String windowParams;

	private int frameNumber = Integer.MAX_VALUE;

	private int imageQuality = Integer.MAX_VALUE;

	private String presentationStateID;

	private String transferSyntax;

	private boolean overlays;

	private SimpleHTTPResponse response;
	
	private String responseInstancePath;

	public void executeTransaction(String outputDir, String outputFileName,
			Map<String, String> queryParameters) {
		
		try {
			//RAD_55_IDC xfer = new RAD_55_IDC();
			
			setObjectID(queryParameters.get("objectId"));
			setUrl(queryParameters.get("url"));
			setOutDir(new File(outputDir));
			setOutFileName(outputFileName);
			setContentType(queryParameters.get("contentType"));
			createFolderStructure();
			
			Set <Entry <String, String>> pars = queryParameters.entrySet();
			for (Entry<String, String >par : pars) {
			   String key = par.getKey();
			   String value = par.getValue();
			   switch (key) {
			      case "charset":
			         setCharset(value);
			         break;
			      case "anonymize":
			         anonymize = true;
			         break;
			      case "annotation":
			         setAnnotation(value);
			         break;
			      case "rows":
			         setRows(integer(value));
			         break;
			      case "columns":
			         setColumns(integer(value));
			         break;
			      case "region":
			         setRegionCoordinates(value);
			         break;
			      case "windowCenter":
			         setWindowParams(value + ":" + 
			            queryParameters.get("windowWidth"));
			         break;
			      case "frameNumber":
			         setFrameNumber(integer(value));
			         break;
			      case "imageQuality":
			         setImageQuality(integer(value));
			         break;
			      case "presentationSeriesUID":
			         setPresentationStateID(
			            value + ":" +
			            queryParameters.get("presentationUID"));
			         break;
			      case "transferSyntax":
			         setTransferSyntax(value);
			         break;
			      default:
			         break;
			   }
			}
			
			String resp = null;
			try {
				resp = sendRequest();
			} catch (Exception e) {
				System.out.print("Error sending request {}" + e);
			}
			System.out.print(resp);
		} catch (Exception e) {
			System.out.println("RAD_55_IDC: " + e.getMessage());
			System.err.println("Usage:	RAD_55_IDC studyUID:seriesUID:objectUID pacs_url output_file_name");
		}
	}

	public static void main(String[] args) {
//		Util.initializeCommandLine("RAD_55_IDC", new String[0], null);
		Map<String, String> queryParameters = new HashMap<String, String>();
		String outputDir = null;
		String outputFileName = null;
		try {
			queryParameters.put("objectId", args[0]);
			queryParameters.put("url", args[1]);
			queryParameters.put("contentType", args[2]);
			outputDir = args[3];
			outputFileName = args[4];
			RAD_55_IDC clientRAD55 = new RAD_55_IDC();
			clientRAD55.executeTransaction(outputDir, outputFileName, queryParameters);
			} catch (Exception e) {
				System.out.println("Error reading command line parameters" + e);
				System.out.println("Usage:\n	RAD_55_IDC studyUID:seriesUID:objectUID pacs_url contentType output_directory output_file_name");
			}
		
	}					

	public RAD_55_IDC() {
	}

	public RAD_55_IDC(String url, String studyUID, String seriesUID, String objectUID, String contentType,
			String charset, boolean anonymize, String annotation, int rows, int columns, String regionCoordinates,
			String windowCenter, String windowWidth, int frameNumber, int imageQuality, String presentationSeriesUID,
			String presentationUID, String transferSyntax) {
		setUrl(url);
		setObjectID(studyUID + ":" + seriesUID + ":" + objectUID);
		setContentType(contentType);
		setCharset(charset);
		setAnonymize(anonymize);
		setAnnotation(annotation);
		setRows(rows);
		setColumns(columns);
		setRegionCoordinates(regionCoordinates);
		setWindowParams(windowCenter + ":" + windowWidth);
		setFrameNumber(frameNumber);
		setImageQuality(imageQuality);
		setPresentationStateID(presentationSeriesUID + ":" + presentationUID);
		setTransferSyntax(transferSyntax);
	}
	
   private String addParam(String purl, String key, String field) {
      if (purl.contains("?")) purl += "&";
      else purl += "?";
      return purl += key + "=" + field;
   }

	public void wado() throws Exception {
		URL newUrl = new URL(setWadoRequestQueryParams(getUrl()));
		System.out.println(newUrl.toString());
		HttpURLConnection connection = (HttpURLConnection) newUrl.openConnection();

		connection.setDoOutput(true);

		connection.setDoInput(true);

		connection.setInstanceFollowRedirects(true);

		connection.setRequestMethod("GET");

		if (getRequestTimeOut() != null) {
			connection.setConnectTimeout(Integer.valueOf(getRequestTimeOut()));
			connection.setReadTimeout(Integer.valueOf(getRequestTimeOut()));
		}

		connection.setUseCaches(false);
		int rspCode = connection.getResponseCode();
		String rspMessage = connection.getResponseMessage();
		InputStream in = connection.getInputStream();

		String ct = connection.getHeaderField("Content-Type");
		String f = null;
		if (ct.contains("application")) {
			if (ct.contains("application/dicom+xml"))
				f = writeXML(in);
			else if (ct.contains("application/pdf"))
				f = writeFile(in, ".pdf");
			else // dicom
				f = writeFile(in, ".dcm");
		} else if (ct.contains("image")) {
			if (ct.contains("image/jpeg"))
				f = writeFile(in, ".jpeg");
			else if (ct.contains("image/png"))
				f = writeFile(in, ".png");
			else // gif
				f = writeFile(in, ".gif");
		} else if (ct.contains("text")) {
			if (ct.contains("text/html")) {
				f = writeFile(in, ".html");
			} else if (ct.contains("text/rtf")) {
				f = writeFile(in, ".rtf");
			} else // text/plain
				f = writeFile(in, ".txt");
		}
		this.response = new SimpleHTTPResponse(rspCode, rspMessage);
		this.responseInstancePath = f;
		connection.disconnect();
	}
	
	private void createFolderStructure() throws Exception {
		String folder = getOutDir() + Utility.fs + "response";
		Files.createDirectories(Paths.get(folder));
		folder = getOutDir() + Utility.fs + "attachments";
		Files.createDirectories(Paths.get(folder));
	}

	private String sendRequest() throws Exception {
		URL newUrl = new URL(setWadoRequestQueryParams(getUrl()));
		System.out.println(newUrl.toString());
		HttpURLConnection connection = (HttpURLConnection) newUrl.openConnection();

		connection.setDoOutput(true);

		connection.setDoInput(true);

		connection.setInstanceFollowRedirects(true);

		connection.setRequestMethod("GET");

		if (getRequestTimeOut() != null) {
			connection.setConnectTimeout(Integer.valueOf(getRequestTimeOut()));
			connection.setReadTimeout(Integer.valueOf(getRequestTimeOut()));
		}

		connection.setUseCaches(false);
		String resp = "Server responded with " + connection.getResponseCode() + " - "
				+ connection.getResponseMessage();
		writeResponse(resp);
		InputStream in = connection.getInputStream();

		String ct = connection.getHeaderField("Content-Type");

		if (ct.contains("application")) {
			if (ct.contains("application/dicom+xml"))
				writeXML(in);
			else if (ct.contains("application/pdf"))
				writeFile(in, ".pdf");
			else // dicom
				writeFile(in, ".dcm");
		} else if (ct.contains("image")) {
			if (ct.contains("image/jpeg"))
				writeFile(in, ".jpeg");
			else if (ct.contains("image/png"))
				writeFile(in, ".png");
			else // gif
				writeFile(in, ".gif");
		} else if (ct.contains("text")) {
			if (ct.contains("text/html")) {
				writeFile(in, ".html");
			} else if (ct.contains("text/rtf")) {
				writeFile(in, ".rtf");
			} else // text/plain
				writeFile(in, ".txt");
		}
		connection.disconnect();

		return resp;

	}

	private TransformerHandler getTransformerHandler() throws Exception {

		if (saxTransformer == null)
			saxTransformer = (SAXTransformerFactory) TransformerFactory.newInstance();

		if (getXsltFile() == null)
			return saxTransformer.newTransformerHandler();

		Templates templates = xsltTemplates;

		if (templates == null) {
			templates = saxTransformer.newTemplates(new StreamSource(xsltFile));
			xsltTemplates = templates;
		}

		return saxTransformer.newTransformerHandler(templates);
	}
	
	private String writeResponse(String s) throws Exception {
		String folder = getOutDir() + Utility.fs + "response";
		Files.createDirectories(Paths.get(folder));
		File file = new File(folder, "response.txt");
		PrintWriter w = new PrintWriter(file, "UTF-8");
		w.write(s);
		w.close();
		return file.getAbsolutePath();	
	}

	private String writeXML(InputStream in) throws Exception {
		String folder = getOutDir() + Utility.fs + "attachments";
		Files.createDirectories(Paths.get(folder));

		File file = new File(getOutDir() + Utility.fs + "attachments", getOutFileName() + ".xml");
		TransformerHandler th = getTransformerHandler();
		th.getTransformer().setOutputProperty(OutputKeys.INDENT, xmlIndent ? "yes" : "no");
		th.setResult(new StreamResult(file));
		Attributes attrs = SAXReader.parse(in);
		SAXWriter saxWriter = new SAXWriter(th);
		saxWriter.setIncludeKeyword(xmlIncludeKeyword);
		saxWriter.write(attrs);
		return file.getAbsolutePath();
	}

	private String writeFile(InputStream in, String extension) throws Exception {
		String folder = getOutDir() + Utility.fs + "attachments";
		Files.createDirectories(Paths.get(folder));
		
		File file = new File(getOutDir() + Utility.fs + "attachments", getOutFileName() + extension);
		try {
			Files.copy(in, file.toPath(), StandardCopyOption.REPLACE_EXISTING);
		} catch (IOException e) {
			System.out.println("RAD_55_IDC: Error writing results to file " + e.getMessage());
		}
		return file.getAbsolutePath();
	}

	private String setWadoRequestQueryParams(String url) {

		url = addParam(url, "requestType", "WADO");
		String[] objID = getObjectID().split(":");
		url = addParam(url, "studyUID", objID[0]);
		url = addParam(url, "seriesUID", objID[1]);
		url = addParam(url, "objectUID", objID[2]);

		if (getContentType() != null)
			url = addParam(url, "contentType", getContentType());

		if (getCharset() != null)
			url = addParam(url, "charset", getCharset());

		if (anonymize)
			url = addParam(url, "anonymize", "yes");

		if (getAnnotation() != null)
			url = addParam(url, "annotation", getAnnotation());

		if (getRows() != Integer.MAX_VALUE)
			url = addParam(url, "rows", Integer.toString(getRows()));

		if (getColumns() != Integer.MAX_VALUE)
			url = addParam(url, "columns", Integer.toString(getColumns()));

		if (getRegionCoordinates() != null)
			url = addParam(url, "region", getRegionCoordinates());

		if (getWindowParams() != null) {
			String[] windowPars = getWindowParams().split(":");
			url = addParam(url, "windowCenter", windowPars[0]);
			url = addParam(url, "windowWidth", windowPars[1]);
		}

		if (getFrameNumber() != Integer.MAX_VALUE)
			url = addParam(url, "frameNumber", Integer.toString(getFrameNumber()));

		if (getImageQuality() != Integer.MAX_VALUE)
			url = addParam(url, "imageQuality", Integer.toString(getImageQuality()));

		if (getPresentationStateID() != null) {
			String[] presentationUID = getPresentationStateID().split(":");
			url = addParam(url, "presentationSeriesUID", presentationUID[0]);
			url = addParam(url, "presentationUID", presentationUID[1]);
		}

		if (getContentType().matches("application/dicom") && getTransferSyntax() != null)
			url = addParam(url, "transferSyntax", getTransferSyntax());

		url = addParam(url, "overlays", isOverlays() ? "true" : "false");

		return url;
	}

	public File getOutDir() {
		return outDir;
	}

	public void setOutDir(File outDir) {
		outDir.mkdirs();
		this.outDir = outDir;
	}

	public File getXsltFile() {
		return xsltFile;
	}

	public void setXsltFile(File xsltFile) {
		this.xsltFile = xsltFile;
	}

	public String getOutFileName() {
		return outFileName;
	}

	public void setOutFileName(String outFileName) {
		this.outFileName = outFileName;
	}

	public String getRequestTimeOut() {
		return requestTimeOut;
	}

	public void setRequestTimeOut(String requestTimeOut) {
		this.requestTimeOut = requestTimeOut;
	}

	public boolean isXmlIndent() {
		return xmlIndent;
	}

	public void setXmlIndent(boolean xmlIndent) {
		this.xmlIndent = xmlIndent;
	}

	public boolean isXmlIncludeKeyword() {
		return xmlIncludeKeyword;
	}

	public void setXmlIncludeKeyword(boolean xmlIncludeKeyword) {
		this.xmlIncludeKeyword = xmlIncludeKeyword;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getObjectID() {
		return objectID;
	}

	public void setObjectID(String objectID) {
		this.objectID = objectID;
	}

	public String getContentType() {
		return contentType;
	}

	public void setContentType(String contentType) {
		this.contentType = contentType;
	}

	public String getCharset() {
		return charset;
	}

	public void setCharset(String charset) {
		this.charset = charset;
	}

	public boolean isAnonymize() {
		return anonymize;
	}

	public void setAnonymize(boolean anonymize) {
		this.anonymize = anonymize;
	}

	public String getAnnotation() {
		return annotation;
	}

	public void setAnnotation(String annotation) {
		if (!annotation.contains("NULL"))
			this.annotation = annotation;
	}

	public int getRows() {
		return rows;
	}

	public void setRows(int rows) {
		if (rows > 0)
			this.rows = rows;
	}

	public int getColumns() {
		return columns;
	}

	public void setColumns(int columns) {
		if (columns > 0)
			this.columns = columns;
	}

	public String getRegionCoordinates() {
		return regionCoordinates;
	}

	public void setRegionCoordinates(String regionCoordinates) {
		if (!regionCoordinates.contains("NULL"))
			this.regionCoordinates = regionCoordinates;
	}

	public String getWindowParams() {
		return windowParams;
	}

	public void setWindowParams(String windowParams) {
		if (!windowParams.contains("NULL"))
			this.windowParams = windowParams;
	}

	public int getFrameNumber() {
		return frameNumber;
	}

	public void setFrameNumber(int frameNumber) {
		if (frameNumber > 0)
			this.frameNumber = frameNumber;
	}

	public int getImageQuality() {
		return imageQuality;
	}

	public void setImageQuality(int imageQuality) {
		if (imageQuality > 0)
			this.imageQuality = imageQuality;
	}

	public String getPresentationStateID() {
		return presentationStateID;
	}

	public void setPresentationStateID(String presentationStateID) {
		if (!presentationStateID.contains("NULL"))
			this.presentationStateID = presentationStateID;
	}

	public String getTransferSyntax() {
		return transferSyntax;
	}

	public void setTransferSyntax(String transferSyntax) {
		if (!transferSyntax.contains("NULL"))
			this.transferSyntax = transferSyntax;
	}

	public boolean isOverlays() {
		return overlays;
	}

   public void setOverlays(boolean overlays) {
		this.overlays = overlays;
	}

	public SimpleHTTPResponse getResponse() {
		return response;
	}

	public String getResponseInstancePath() {
		return responseInstancePath;
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

}
