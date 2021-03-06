/**
 * 
 */
package edu.wustl.mir.erl.ihe.xdsi.util;


import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import javax.xml.namespace.QName;

import org.apache.axiom.om.*;
import org.w3c.dom.*;

import gov.nist.toolkit.utilities.xml.XmlFormatter;

/**
 * A bit of a kludge, this is the XmlUtil class from the NIST tools, because we
 * have an XmlUtil class using wc3.dom.
 *
 */
public class OMEUtil {
   static public OMFactory om_factory = OMAbstractFactory.getOMFactory();
   static public OMNamespace xml_namespace =   om_factory.createOMNamespace("http://www.w3.org/XML/1998/namespace", "xml");

   public static OMElement firstChildWithLocalName(OMElement ele, String localName) {
      for (Iterator<?> it=ele.getChildElements(); it.hasNext(); ) {
         OMElement child = (OMElement) it.next();
         if (child.getLocalName().equals(localName))
            return child;
      }
      return null;
   }

   public static OMElement firstChildWithLocalNameEndingWith(OMElement ele, String localNameSuffix) {
      for (Iterator<?> it=ele.getChildElements(); it.hasNext(); ) {
         OMElement child = (OMElement) it.next();
         if (child.getLocalName().endsWith(localNameSuffix))
            return child;
      }
      return null;
   }

   public static List<OMElement> childrenWithLocalName(OMElement ele, String localName) {
      List<OMElement> al = new ArrayList<OMElement>();
      for (Iterator<?> it=ele.getChildElements(); it.hasNext(); ) {
         OMElement child = (OMElement) it.next();
         if (child.getLocalName().equals(localName))
            al.add(child);
      }
      return al;
   }

   public static List<String> childrenLocalNames(OMElement ele) {
      List<String> al = new ArrayList<String>();
      for (Iterator<?> it=ele.getChildElements(); it.hasNext(); ) {
         OMElement child = (OMElement) it.next();
         al.add(child.getLocalName());
      }
      return al;
   }

   public static OMElement firstDecendentWithLocalName(OMElement ele, String localName) {
      List<OMElement> decendents = decendentsWithLocalName(ele, localName);
      if (decendents.size() == 0) return null;
      return decendents.get(0);
   }

   public static List<OMElement> decendentsWithLocalName(OMElement ele, String localName) {
      return decendentsWithLocalName(ele, localName, -1);
   }

   public static List<OMElement> decendentsWithLocalName(OMElement ele, String localName, int depth) {
      List<OMElement> al = new ArrayList<OMElement>();
      if (ele == null || localName == null)
         return al;
      decendentsWithLocalName1(al, ele, localName, depth);
      return al;
   }

   private static void decendentsWithLocalName1(List<OMElement> decendents, OMElement ele, String localName, int depth) {
      if (depth == 0)
         return;
      for (Iterator<?> it=ele.getChildElements(); it.hasNext(); ) {
         OMElement child = (OMElement) it.next();
         if (child.getLocalName().equals(localName))
            decendents.add(child);
         decendentsWithLocalName1(decendents, child, localName, depth - 1);
      }
   }
   
   public static String getAttributeValue(OMElement element, String attributeName) {
      return element.getAttributeValue(new QName(attributeName));
   }

   public static OMElement createElement(String localName, OMNamespace ns) {
      return om_factory.createOMElement(localName, ns);
   }
   
   /**
    * Creates a new OMElement with the same local name and namespace as the 
    * parameter element. <b>NOT</b> a clone
    * @param element reference element for new element
    * @return new element
    */
   public static OMElement createElement(OMElement element) {
      return om_factory.createOMElement(element.getLocalName(), element.getNamespace());
   }

   public static OMElement addChild(String localName, OMNamespace ns, OMElement parent) {
      return om_factory.createOMElement(localName, ns, parent);
   }
   
   /**
    * Creates a new child OMElement with the same local name and namespace as the 
    * parameter element. <b>NOT</b> a clone
    * @param element reference element
    * @param parent for new element
    * @return new element
    */
   public static OMElement addChild(OMElement element, OMElement parent) {
      return om_factory.createOMElement(element.getLocalName(), element.getNamespace(), parent);
   }


   static public String XmlWriter(Node node) {
      return XmlFormatter.format(XmlFormatter.normalize(getStringFromNode(node)), false);
   }

   static public String getStringFromNode(Node node) {
      StringBuffer sb = new StringBuffer();
      if ( node == null ) {
         return null;
      }

      int type = node.getNodeType();
      switch ( type ) {
         case Node.DOCUMENT_NODE:
            sb.append("");
            sb.append(getStringFromNode((((Document)node).getDocumentElement())));
            break;

         case Node.ELEMENT_NODE:
            sb.append('<');

            sb.append(node.getNodeName());
            NamedNodeMap attrs = node.getAttributes();

            for ( int i = 0; i < attrs.getLength(); i++ ) {
               sb.append(' ');
               sb.append(attrs.item(i).getNodeName());
               sb.append("=\"");

               sb.append(attrs.item(i).getNodeValue());
               sb.append('"');
            }
            sb.append('>');
            sb.append("\n"); // HACK
            NodeList children = node.getChildNodes();
            if ( children != null ) {
               int len = children.getLength();
               for ( int i = 0; i < len; i++ ) {
                  sb.append(getStringFromNode(children.item(i)));
               }
            }
            break;

         case Node.TEXT_NODE:
            sb.append(node.getNodeValue());
            break;

      }

      if ( type == Node.ELEMENT_NODE ) {
         sb.append("</");
         sb.append(node.getNodeName());
         sb.append(">");
         sb.append("\n"); // HACK
      }

      return sb.toString();
   }
   

   }
