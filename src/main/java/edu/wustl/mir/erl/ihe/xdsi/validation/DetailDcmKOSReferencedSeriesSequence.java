/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.validation;

import java.util.ArrayList;
import java.util.List;

import org.dcm4che3.data.Attributes;
import org.dcm4che3.data.Sequence;
import org.dcm4che3.data.Tag;
import org.javatuples.Pair;

import edu.wustl.mir.erl.ihe.xdsi.validation.DCMAssertion.TYPE;

@SuppressWarnings("javadoc")
public class DetailDcmKOSReferencedSeriesSequence extends DetailDcmSequenceContent {

  
   @Override
   protected void initializeTest() {
      assertions = new ArrayList<>();
      // Series Instance UID (0020,000E)
      assertions.add(new DCMAssertion(TYPE.SAME, Tag.SeriesInstanceUID));
      // Retrieve AE Title (0008,0054)
      assertions.add(new DCMAssertion(TYPE.NOT_EMPTY, Tag.RetrieveAETitle));
      // Retrieve Location UID (0040,E011)
      assertions.add(new DCMAssertion(TYPE.NOT_EMPTY, Tag.RetrieveLocationUID));
      
      addSubSeq(DetailDcmKOSReferencedSOPSequence.class);
   }
   /**
    * Two calling options:
    * <ol>
    * <li/>args[0] may be DetailDcmContent instance which contains the sequence
    * to be tested.
    * <li/>args[0] may be test Attributes and args[1] std Attributes.
    * </ol>
    */
   @Override
   protected void initializeDetail(Object[] args) throws Exception {
      desc = "Referenced Series seq";
      uniqueSequenceTag = Tag.SeriesInstanceUID;
      if (args[0] instanceof DetailDcmContent) {
         DetailDcmContent parent = (DetailDcmContent) args[0];
         Pair <Attributes, Attributes> p = parent.getParents();
         test = getList(p.getValue0());
         std = getList(p.getValue1());
      }
      if (args[0] instanceof Attributes && args[1] instanceof Attributes) {
         test = getList((Attributes) args[0]);
         std = getList((Attributes) args[1]);
      }
   }
   
   private List<Attributes> getList(Attributes attr) throws Exception {
      List<Attributes> lst = new ArrayList<>();
      Sequence seq = attr.getSequence(Tag.ReferencedSeriesSequence);
      lst.addAll(seq);
      return lst;
   }
}
