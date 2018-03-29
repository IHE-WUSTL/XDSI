package edu.wustl.mir.erl.ihe.xdsi.execution;

import java.io.File;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import edu.wustl.mir.erl.ihe.xdsi.transactions.RAD_55_IDC;
import edu.wustl.mir.erl.ihe.xdsi.util.AEBean;
import edu.wustl.mir.erl.ihe.xdsi.util.DICOMUtility;
import edu.wustl.mir.erl.ihe.xdsi.util.KOSBean;
import edu.wustl.mir.erl.ihe.xdsi.util.KOSInstanceBean;
import edu.wustl.mir.erl.ihe.xdsi.util.KOSSeriesBean;
import edu.wustl.mir.erl.ihe.xdsi.util.KOSStudyBean;
import edu.wustl.mir.erl.ihe.xdsi.util.PfnType;
import edu.wustl.mir.erl.ihe.xdsi.util.Utility;

@SuppressWarnings("javadoc")
public class RAD55Sequences {
   
	private static Logger log = Utility.getLog();
	
	private static Path xdsiRootPath = Utility.getXDSIRootPath();
	
	
	/**
	 * @param pathKOS
	 * @param pathOutputFolder
	 * @param aeIniPath
	 * @param contentType
	 * @throws Exception
	 */
	public static void retrieveStudy(String pathKOS, String pathOutputFolder, String aeIniPath, String contentType) throws Exception {
		FileUtils.deleteDirectory(new File(pathOutputFolder));
		if (! (new File(pathOutputFolder)).mkdirs()) {
			throw new Exception ("");
		}
		AEBean aeBean = AEBean.loadFromConfigurationFile(aeIniPath);
		String wadoURL = aeBean.getWadoURL();
		DICOMUtility u = new DICOMUtility();
		KOSBean kosBean = u.readKOS(pathKOS);
		ArrayList<KOSStudyBean> studyBeanArray = kosBean.getStudyBeanList();
		Iterator<KOSStudyBean> it = studyBeanArray.iterator();
		int fileIndex = 10001;
		while (it.hasNext()) {
			KOSStudyBean studyBean = it.next();
			System.out.println("Study: " + studyBean.getStudyUID());
			ArrayList<KOSSeriesBean> seriesBeanArray = studyBean.getSeriesBeanList();
			Iterator<KOSSeriesBean> itSeries = seriesBeanArray.iterator();
			while (itSeries.hasNext()) {
				KOSSeriesBean seriesBean = itSeries.next();
				System.out.println(" Series: " + seriesBean.getRetrieveAETitle() + " " + seriesBean.getSeriesUID());
				ArrayList<KOSInstanceBean> instanceBeanArray = seriesBean.getInstanceBeanList();
				Iterator<KOSInstanceBean> itInstance = instanceBeanArray.iterator();
				while (itInstance.hasNext()) {
					KOSInstanceBean instanceBean = itInstance.next();
					System.out.println("  Instance: " +
							instanceBean.getClassUID() + " " +
							instanceBean.getInstanceUID());
					HashMap<String, String> queryParameters = new HashMap<>();
					String objectID = studyBean.getStudyUID() + ":" + seriesBean.getSeriesUID() + ":" + instanceBean.getInstanceUID();
					String outputFile = "" + fileIndex; fileIndex++;
					queryParameters.put("objectId", objectID);
					queryParameters.put("url", wadoURL);
					queryParameters.put("contentType", contentType);
					RAD_55_IDC clientRAD55 = new RAD_55_IDC();
					clientRAD55.executeTransaction(pathOutputFolder, outputFile, queryParameters);

				}
			}
		}
	}
	
	public static void retrieveSingle(String pathOutputFolder, String aeIniPath, String compositeUIDs, String contentType) throws Exception {
	   pathOutputFolder = xdsiRootPath.resolve(pathOutputFolder).toString();
		FileUtils.deleteDirectory(new File(pathOutputFolder));
		if (! (new File(pathOutputFolder)).mkdirs()) {
			throw new Exception ("");
		}
		AEBean aeBean = AEBean.loadFromConfigurationFile(aeIniPath);
		String wadoURL = aeBean.getWadoURL();
		DICOMUtility u = new DICOMUtility();
		
		HashMap<String, String> queryParameters = new HashMap<>();
		queryParameters.put("objectId", compositeUIDs);
		String outputFile = "rad55";

		queryParameters.put("url", wadoURL);
		queryParameters.put("contentType", contentType);
		RAD_55_IDC clientRAD55 = new RAD_55_IDC();
		clientRAD55.executeTransaction(pathOutputFolder, outputFile, queryParameters);
	}
	
	public static void runCase(String kosPfn, String outputDir, String outputFileName,
      RAD55Case... cases) throws Exception {
	   Path pathKOS = Utility.getXDSIRootPath().resolve(kosPfn);
	   Utility.isValidPfn("KOS File", pathKOS, PfnType.FILE, "r");
	   KOSBean kos = new DICOMUtility().readKOS(pathKOS.toString());
	   int index = 10001;
	   for (KOSStudyBean studyBean : kos.getStudyBeanList()) {
	      log.info("Study: " + studyBean.getStudyUID());
	      for (KOSSeriesBean seriesBean : studyBean.getSeriesBeanList()) {
	         log.info(" Series: " + seriesBean.getRetrieveAETitle() + " " + seriesBean.getSeriesUID());
	         for (KOSInstanceBean instanceBean : seriesBean.getInstanceBeanList()) {
	            log.info("  Instance: " + instanceBean.getClassUID() + " " +
                  instanceBean.getInstanceUID());
	            for (RAD55Case cas : cases) {
	               cas.setStudyUID(studyBean.getStudyUID());
	               cas.setSeriesUID(seriesBean.getSeriesUID());
	               cas.setObjectUID(instanceBean.getInstanceUID());
	               cas.setDir(outputDir);
	               cas.setPfn(outputFileName + "-" + index); index++;
	            }
	            runCase(cases);
	         }
	      }
	   }
	}
	
	/**
    * Runs test case(s) based on data in a RAD55Case instance.<br/>
    * Properties which MUST be filled in:<ol>
    * <li/>WADO host URL.
    * <li/>contentType.
    * </ol>
    * Other parameters are optional.
    * @param cases to run.
    */
   public static void runCase(String studyUID, String seriesUID, String objectUID, 
      String outputDir, String outputFileName,
      RAD55Case... cases) {
      for (RAD55Case cas : cases) {
         cas.setStudyUID(studyUID);
         cas.setSeriesUID(seriesUID);
         cas.setObjectUID(objectUID);
      }
      runCase(outputDir, outputFileName, cases);
   }
	
	/**
    * Runs test case(s) based on data in a RAD55Case instance.<br/>
    * Properties which MUST be filled in:<ol>
    * <li/>Study, series, and object UIDs.
    * <li/>WADO host URL.
    * <li/>contentType.
    * </ol>
    * Other parameters are optional.
    * @param cases to run.
    */
   public static void runCase(String outputDir, String outputFileName, RAD55Case... cases) {
      for (RAD55Case cas : cases) {
         cas.setDir(outputDir);
         cas.setPfn(outputFileName);
      }
      runCase(cases);
   }
	
	/**
	 * Runs test case(s) based on data in a RAD55Case instance.<br/>
	 * Properties which MUST be filled in:<ol>
	 * <li/>Study, series, and object UIDs.
	 * <li/>Output directory and file name.
	 * <li/>WADO host URL.
	 * <li/>contentType.
	 * </ol>
	 * Other parameters are optional.
	 * @param cases to run.
	 */
   public static void runCase(RAD55Case... cases) {
      for (RAD55Case cas : cases) {
         try {
            String outputDir = cas.getDir();
            String outputFileName = cas.getPfn();
            Map <String, String> qps = new HashMap <>();
            put(qps, "objectId", cas.getStudyUID() + ":" + cas.getSeriesUID() + ":" + cas.getObjectUID());
            put(qps, "url", cas.getUrl());
            put(qps, "contentType", cas.getContenType());
            put(qps, "charset", cas.getCharset());
            put(qps, "anonymize", cas.getAnonymize());
            put(qps, "annotation", cas.getAnnotation());
            put(qps, "rows", cas.getRows());
            put(qps, "columns", cas.getColumns());
            put(qps, "region", cas.getRegion());
            put(qps, "windowCenter", cas.getWindowCenter());
            put(qps, "windowWidth", cas.getWindowWidth());
            put(qps, "frameNumber", cas.getFrameNumber());
            put(qps, "imageQuality", cas.getImageQuality());
            put(qps, "presentationUID", cas.getPresentationUID());
            put(qps, "presentationSeriesUID", cas.getPresentationSeriesUID());
            put(qps, "transferSyntax", cas.getTransferSyntaxUID());
            RAD_55_IDC clientRAD55 = new RAD_55_IDC();
            clientRAD55.executeTransaction(outputDir, outputFileName, qps);
         } catch (Exception e) {
            log.warn(Utility.getEM(e));
         }
      }
   }
	private static void put(Map<String, String> map, String key, String value) {
	   if (value != null) map.put(key, value);
	}

	public static void main(String[] args) {
	   log = Utility.getLog();
	   String cmd = getArg(args, 0);
	   String cmdLine = "";
	   for (int i = 1; i < args.length; i++) cmdLine += args[i] + " ";
	   log.info("prs command: " + cmd + ": " + cmdLine);
		try {
		   switch (cmd) {
		      case "SINGLE":
		    	  retrieveSingle(args[1], args[2], args[3], args[4]);
		    	  break;
			   
		      case "STUDY":
			  	   retrieveStudy(args[1], args[2], args[3], args[4]);
			  	   break;
			  	/*
			  	 * Run one or more standard cases on a single image.
			  	 */
		      case "ONEIMG":
		         Integer[] numbers = new Integer[args.length - 7];
		         for (int i = 0; i < numbers.length; i++) 
		            numbers[i] = Integer.parseInt(args[7+i]);
		         RAD55Case[] cases = RAD55Case.getCaseCopies(numbers);
		         for (RAD55Case cas : cases) {
		         cas.setWADOUrlFromAEBean(args[1]);
		         cas.setStudyUID(args[2]);
		         cas.setSeriesUID(args[3]);
		         cas.setObjectUID(args[4]);
		         cas.setDir(args[5]);
		         cas.setPfn(args[6]);
		         }
		         runCase(cases);
		         break;
			  	default:
			  	   throw new Exception("No such test: " + cmd);
			}
         log.info(cmd + " test completed");
      } catch (Exception e) {
         log.error(cmd + " test failed - " + e.getMessage());
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
