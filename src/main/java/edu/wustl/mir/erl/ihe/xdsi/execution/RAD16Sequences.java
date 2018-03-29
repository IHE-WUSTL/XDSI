package edu.wustl.mir.erl.ihe.xdsi.execution;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

import edu.wustl.mir.erl.ihe.xdsi.util.DICOMUtility;
import edu.wustl.mir.erl.ihe.xdsi.util.MoveSCU;
import edu.wustl.mir.erl.ihe.xdsi.util.KOSBean;
import edu.wustl.mir.erl.ihe.xdsi.util.KOSInstanceBean;
import edu.wustl.mir.erl.ihe.xdsi.util.KOSSeriesBean;
import edu.wustl.mir.erl.ihe.xdsi.util.KOSStudyBean;
import edu.wustl.mir.erl.ihe.xdsi.util.Utility;

public class RAD16Sequences {
	   
	private static Logger log = null;
	
	public void RAD16Sequences() {
		log = Utility.getLog();
	}
	
	public void retrieveUsingKOS(String pathOutputFolder, String pathKOS,  String moveSCPTitle, String targetAE, String options, String pathSCPFolder) throws Exception {
		log.debug("RAD16Sequences::retrieveUsingKOS enter method");
		FileUtils.deleteDirectory(new File(pathOutputFolder));
		if (! (new File(pathOutputFolder)).mkdirs()) {
			throw new Exception ("Unable to create output folder: " + pathOutputFolder);
		}
		DICOMUtility u = new DICOMUtility();
		KOSBean kosBean = u.readKOS(pathKOS);
		String[] moveLevels = options.split(":");
		for (int i = 0; i < moveLevels.length; i++) {
			log.debug("Move Level: " + moveLevels[i]);
			if (new File(pathSCPFolder).exists()) {
				FileUtils.cleanDirectory(new File(pathSCPFolder));
			}
			if (moveLevels[i].equals("STUDY")) {
				this.retrieveStudyLevel(kosBean, moveSCPTitle, targetAE);
			} else if (moveLevels[i].equals("SERIES")) {
				this.retrieveSeriesLevel(kosBean, moveSCPTitle, targetAE);
			} else if (moveLevels[i].equals("INSTANCE")) {
				this.retrieveInstanceLevel(kosBean, moveSCPTitle, targetAE);
			}
			String finalOutputPath = pathOutputFolder + "/" + moveLevels[i];
			if (new File(finalOutputPath).exists()) {
				FileUtils.cleanDirectory(new File(finalOutputPath));
			}
			this.moveInstancesToStorage(finalOutputPath, pathSCPFolder);
		}
		log.debug("RAD16Sequences::retrieveUsingKOS exit method");
	}
	
	private void moveInstancesToStorage(String pathOutputFolder, String pathInputFolder) throws Exception {
		log.debug("RAD16Sequences::moveInstancesToStorage enter method output=" + pathOutputFolder + 
				" input=" + pathInputFolder);
		File f = new File(pathOutputFolder);
		if (f.exists()) {
			FileUtils.deleteDirectory(f);
		}
		if (! f.mkdirs()) {
			throw new Exception ("Unable to create output folder: " + pathOutputFolder);
		}
		File fileInputFolder = new File(pathInputFolder);
		String inputList[] = fileInputFolder.list();
		for (int i = 0; i < inputList.length; i++ ) {
			File sourceFile = new File(pathInputFolder + "/" + inputList[i]);
			File targetFile = new File(pathOutputFolder+ "/" + inputList[i]);
			FileUtils.moveFile(sourceFile, targetFile);
		}
//		FileUtils.copyDirectory(new File(pathInputFolder), new File(pathOutputFolder));

		log.debug("RAD16Sequences::moveInstancesToStorage exit method");
	}
	
	private void retrieveStudyLevel(KOSBean kosBean, String moveSCPTitle,
			String targetAE) throws Exception {
		log.debug("RAD16Sequences::retrieveStudyLevel enter method");
		ArrayList<KOSStudyBean>studyBeanList = kosBean.getStudyBeanList();
		Iterator<KOSStudyBean> iteratorStudyBean = studyBeanList.iterator();
		String studyUID="";
		try {
			while (iteratorStudyBean.hasNext()) {
				KOSStudyBean studyBean = iteratorStudyBean.next();
				studyUID = studyBean.getStudyUID();
				log.debug("About to request C-Move: SCP=" + moveSCPTitle +
						" Target AE=" + targetAE +
						" Study UID=" + studyUID);
				MoveSCU.moveStudy("CMOVECLIENT", moveSCPTitle, targetAE, studyUID, "", "");
			}
		} catch (Exception e) {
			throw new Exception("Unable to perform STUDY level C-Move, SCP AE Title=" + moveSCPTitle +
					" Targt AE title=" + targetAE +
					" Study UID=" + studyUID);
		}
		log.debug("RAD16Sequences::retrieveStudyLevel exit method");
	}
	
	private void retrieveSeriesLevel(KOSBean kosBean, String moveSCPTitle,
			String targetAE) throws Exception {
		log.debug("RAD16Sequences::retrieveSeriesLevel enter method");
		ArrayList<KOSStudyBean>studyBeanList = kosBean.getStudyBeanList();
		Iterator<KOSStudyBean> iteratorStudyBean = studyBeanList.iterator();
		String studyUID="";
		String seriesUID="";
		try {
			while (iteratorStudyBean.hasNext()) {
				KOSStudyBean studyBean = iteratorStudyBean.next();
				studyUID = studyBean.getStudyUID();
				Iterator<KOSSeriesBean> iteratorSeriesBean = studyBean.getSeriesBeanList().iterator();
				while (iteratorSeriesBean.hasNext()) {
					KOSSeriesBean seriesBean = iteratorSeriesBean.next();
					seriesUID = seriesBean.getSeriesUID();
					log.debug("About to request C-Move: SCP=" + moveSCPTitle +
							" Target AE=" + targetAE +
							" Study UID=" + studyUID +
							" SeriesUID=" + seriesUID);
					MoveSCU.moveStudy("CMOVECLIENT", moveSCPTitle, targetAE, studyUID, seriesUID, "");
				}
			}
		} catch (Exception e) {
			throw new Exception("Unable to perform STUDY level C-Move, SCP AE Title=" + moveSCPTitle +
					" Targt AE title=" + targetAE +
					" Study UID=" + studyUID +
					" Series UID=" + seriesUID);
		}
		log.debug("RAD16Sequences::retrieveSeriesLevel exit method");
	}
	
	private void retrieveInstanceLevel(KOSBean kosBean, String moveSCPTitle,
			String targetAE) throws Exception {
		log.debug("RAD16Sequences::retrieveInstanceLevel enter method");
		ArrayList<KOSStudyBean>studyBeanList = kosBean.getStudyBeanList();
		Iterator<KOSStudyBean> iteratorStudy = studyBeanList.iterator();
		String studyUID="";
		String seriesUID="";
		String instanceUID="";
		try {
			while (iteratorStudy.hasNext()) {
				KOSStudyBean studyBean = iteratorStudy.next();
				studyUID = studyBean.getStudyUID();
				Iterator<KOSSeriesBean> iteratorSeries = studyBean.getSeriesBeanList().iterator();
				while (iteratorSeries.hasNext()) {
					KOSSeriesBean seriesBean = iteratorSeries.next();
					seriesUID = seriesBean.getSeriesUID();
					Iterator<KOSInstanceBean> iteratorInstance = seriesBean.getInstanceBeanList().iterator();
					while (iteratorInstance.hasNext()) {
						KOSInstanceBean instanceBean = iteratorInstance.next();
						instanceUID = instanceBean.getInstanceUID();
						log.debug("About to request C-Move: SCP=" + moveSCPTitle +
								" Target AE=" + targetAE +
								" Study UID=" + studyUID +
								" SeriesUID=" + seriesUID +
								" Instance UID=" + instanceUID);
						MoveSCU.moveStudy("CMOVECLIENT", moveSCPTitle, targetAE, studyUID, seriesUID, instanceUID);
					}
				}
			}
		} catch (Exception e) {
			throw new Exception("Unable to perform STUDY level C-Move, SCP AE Title=" + moveSCPTitle +
					" Targt AE title=" + targetAE +
					" Study UID=" + studyUID +
					" Series UID=" + seriesUID +
					" Instance UID = " + instanceUID);
		}
		log.debug("RAD16Sequences::retrieveInstanceLevel exit method");
	}


	public static void main(String[] args) {
		// TODO Auto-generated method stub
        log = Utility.getLog();
        RAD16Sequences rad16Sequences = new RAD16Sequences();
		try {
			if (args[0].equals("C-MOVE_KOS")) {
				/*
				 * C-MOVE_KOS
				 * Output path (top level; we will add a level beneath
				 * Path to KOS
				 * Name of .ini file for Imaging Document Source (just name, not path)
				 * Target AE title (most likely SIMSTORAGESCP, but  not required)
				 * Options (STUDY:SERIES:INSTANCE)
				 * Path to folder used by our storage SCP
				 */
				rad16Sequences.retrieveUsingKOS(args[1],  args[2],  args[3],  args[4],  args[5], args[6]);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

}
