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

import java.util.HashMap;

/**
 * Class used to simulate an Image Data Consumer (IDC)
 * Sending a WADO Retrieve (RAD-55) transaction
 * to an Imaging Document Source (IDS)
 * Primary Reference: IHE RAD TF-3 Section 4.55 *
 */
public class RAD_16_IDC extends ClientTransaction {
	
	/**
	 * @param outputFolder Destination folder to store response to C-Move request (not the images)
	 * @param outputFileName Filename to store C-Move response (not the images, the response)
	 * @param titleCMoveSCP AE Title of the C-Move SCP
	 * @param hostCMoveSCP  Host name of the C-Move SCP
	 * @param portCMoveSCP  TCP/IP port number of the C-Move SCP
	 * @param titleCStoreSCP AE Title of the target of the C-Move
	 * @param queryParameters A map of parameters used to execute the C-Move.
	 *        These are of the form GGGGEEEE=value.
	 *        For example: 0020000D=1.2.3.4.5
	 */
	public static void executeTransaction(String outputFolder,
			String outputFileName,
			String titleCMoveSCP, String hostCMoveSCP, String portCMoveSCP,
			String titleCStoreSCP, HashMap<String, String> queryParameters) {
		
	}

   /**
    * @param args command line arguments
    */
   public void main(String[] args) {
      // TODO Auto-generated method stub

   }

}
