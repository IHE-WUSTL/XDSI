/**
 * Contains classes specific to validation of tests against an Initiating
 * Imaging Gateway System under Test - iig SUT
 * Also contains test xml files for tests:
 * <pre>
 * iig-1001: Single Image Study, Single Gateway
 * iig-1002: Two Imaging Studies, Single Gateway
 * iig-1003: Transfer Syntax JPEG Lossless, Single Gateway
 * iig-1004: Multiple Transfer Syntaxes, Single Gateway
 * iig-1005: Transfer Syntax Failure, Single Gateway
 * iig-1006: Unknown DICOM UIDs, Single Gateway
 * iig-1007: Unknown Responding Gateway, Single Gateway
 * iig-1008: Consolidated Success/Failure, Single Gateway
 * iig-1011: One Multi-Image Study, Single Gateway
 * iig-1021: Multiple Responding Gateways
 * iig-1022: Consolidated Success/Failure, Multiple Gateways</pre>
 *  
 * For details on these tests, see XCA-I.b Conformity Assessment Tests: 
 * Initiating Imaging Gateway, in the Google Docs.<p/>
 * 
 * @author Ralph Moulton / MIR WUSTL IHE Development Project <a
 * href="mailto:moultonr@mir.wustl.edu">moultonr@mir.wustl.edu</a>
 */
package edu.wustl.mir.erl.ihe.xdsi.validation.iig;
