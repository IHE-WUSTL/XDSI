package net.ihe.gazelle.standalone.test;

import java.io.ByteArrayInputStream;
import java.io.IOException;

import javax.xml.bind.JAXBException;
import javax.xml.transform.TransformerConfigurationException;

import net.ihe.gazelle.simulator.common.tf.model.AffinityDomain;
import net.ihe.gazelle.simulator.common.tf.model.Transaction;
import net.ihe.gazelle.test.TransformDicom;
import net.ihe.gazelle.xds.DocumentRequestType;
import net.ihe.gazelle.xdsi.SeriesRequestType;
import net.ihe.gazelle.xdsi.StudyRequestType;
import net.ihe.gazelle.xdstar.xdsi.action.XDSI69Manager;
import net.ihe.gazelle.xdstar.xdsi.model.ImgDocSourceConfiguration;
import net.ihe.gazelle.xdstar.xdsi.utils.DicomTool;

public class XDSI69Standalone {
	
	public static void main(String[] args) throws TransformerConfigurationException, IOException, JAXBException {
		String url = "http://ovh4.ihe-europe.net:8380/dcm4chee-xdsib-ws?wsdl";
		String kosPath = "src/test/resources/178";
		String repId = "1.2.40.0.13.1.1.192.168.0.211.200901012243";
		sendRAD69BasedOnKOS(url, kosPath, repId);
	}

	private static void sendRAD69BasedOnKOS(String url, String kosPath, String idsRepositoryUniqueId) throws TransformerConfigurationException, IOException, JAXBException {
		XDSI69Manager xdsi69 = new XDSI69Manager() {
			private static final long serialVersionUID = 1L;

			public void init() {
				useXUA = false;
				selectedConfiguration = null;
				displayResultPanel = false;
				message = null;
				this.selectedTransaction =  new Transaction("RAD-69", null, null);
				this.selectedAffinityDomain = new AffinityDomain();
				this.selectedAffinityDomain.setKeyword("IHE_XDS-I.b");
			}
		};
		xdsi69.init();
		xdsi69.setSelectedConfiguration(new ImgDocSourceConfiguration());
		xdsi69.getSelectedConfiguration().setUrl(url);
		String dump = DicomTool.dicom2xml(kosPath);
		xdsi69.setGeneratedDicom(TransformDicom.load(new ByteArrayInputStream(dump.getBytes())));
		xdsi69.generateRequestFromManifest();
		xdsi69.setSelectedTransferSyntaxUID("1.2.840.10008.1.2.2:Expicit");
		xdsi69.addSelectedTransferSyntaxUID();
		
		if (xdsi69.getSelectedRetrieveImagingDocumentSetRequest() != null && 
				xdsi69.getSelectedRetrieveImagingDocumentSetRequest().getStudyRequest().size()>0) {
			for (StudyRequestType stud : xdsi69.getSelectedRetrieveImagingDocumentSetRequest().getStudyRequest()) {
				for (SeriesRequestType ser : stud.getSeriesRequest()) {
					for (DocumentRequestType doc : ser.getDocumentRequest()) {
						doc.setRepositoryUniqueId(idsRepositoryUniqueId);
					}
				}
			}
		}
		String messs = xdsi69.previewMessage();
		System.out.println(messs);
		xdsi69.sendMessageWithNoPersist();
		String resp = xdsi69.getMessage().getReceivedMessageContent().getMessageContent();
		System.out.println("resp = " + resp);
	}

}
