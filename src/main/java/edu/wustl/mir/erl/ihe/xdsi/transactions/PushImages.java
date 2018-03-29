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

import java.nio.file.Files;
import java.nio.file.Path;

import edu.wustl.mir.erl.ihe.xdsi.util.AEBean;
import edu.wustl.mir.erl.ihe.xdsi.util.DICOMUtility;
import edu.wustl.mir.erl.ihe.xdsi.util.Utility;

/**
 * Class to push images to a PACS
 * 
 * @author Ralph Moulton / MIR WUSTL IHE Development Project <a href="mailto:moultonr@mir.wustl.edu">moultonr@mir.wustl.edu</a>
 *
 */
public class PushImages extends ClientTransaction {
   

   /**
    * Push images to PACS. Parameters:<ol>
    * <li> pfn of AE.ini file</li>
    * <li> pfn of directory with reference study.</li>
    * <li> patientIdentifier The patient identifier for the "new" study, in CX format.
    * For example: <pre> {@code id-19^^^&1.3.6.1.4.1.21367.2005.3.7&ISO } </pre></li>
    * <li> The study Instance UID (0020,000D) for the "new" study.</li>
    * <li> The accession number (0008,0050) for the "new" study.</li>
    * </ol>
    * TODO Add realistic error handling.
    * @param args command line arguments.
    * */
  public static void main(String[] args) {
      try {
         Path runDirectoryPath = Utility.getRunDirectoryPath();
         String aeIniPfn = args[0];
         Path studyDirPath = runDirectoryPath.resolve(args[1]);
         String pid = args[2];
         String studyInstanceUID = args[3];
         String accessionNumber = args[4];

         // Generate "new" study.
         Path tempPath =
            Files.createDirectories(runDirectoryPath.resolve("temp" + Utility.fs + "PushImages"));
         Path tempDirPath = Files.createTempDirectory(tempPath, "newStudy");
         DICOMUtility.reidentifyStudy(tempDirPath.toString(), studyDirPath.toString(), pid, studyInstanceUID,
            accessionNumber, "", "", "", "");

         AEBean aeBean = AEBean.loadFromConfigurationFile(aeIniPfn);
         // TODO push to AE title RAM current working location.

      } catch (Exception e) {
         Utility.exit(Utility.getEM(e));

      }
   }

}
