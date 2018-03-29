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

/**
 * Class used to simulate an Image Data Source (IDS) Sending a Provide and
 * Register Imaging Document Set (RAD-68) transaction to a Document Repository
 * (DR) or Document Repository/Registry (RR) Primary Reference: IHE RAD TF-3
 * Section 4.68
 * 
 * @author Ralph Moulton / MIR WUSTL IHE Development Project
 * <a href="mailto:moultonr@mir.wustl.edu">moultonr@mir.wustl.edu</a>
 */

public class RAD_68_IDS extends ClientTransaction {
   /**
    * @author smm
    * @param outputFolder Path to a folder to store the response from the
    * repository
    * @param outputFileName Name of the file to hold the repository response
    * @param pathToKOS Full path to the KOS to send with this transaction
    * @param repositoryURL URL of the repository
    * @param certificateInformation Placeholder for certificate information.
    */
   public static void executeTransaction(String outputFolder, String outputFileName, String pathToKOS,
      String repositoryURL, String certificateInformation) {}

   /**
    * @param args command line arguments
    */
   public void main(String[] args) {
      // TODO Auto-generated method stub
   }

}
