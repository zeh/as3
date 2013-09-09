package com.zehfernando.utils {

	/**
	 * @author zeh
	 */
	public class XMLUtils {

		// Constants
		protected static const VALUE_TRUE:String = "true";			// Array considered as explicit "true" when reading data from a XML
		protected static const VALUE_FALSE:String = "false";		// Array considered as explicit "false" when reading data from a XML

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function hasNode(__xml:XML, __nodeName:String):Boolean {
			if (!Boolean(__xml)) return false;
			return __xml.child(__nodeName).length() > 0;
		}

		public static function getNodeAsBoolean(__xml:XML, __nodeName:String, __default:Boolean = false):Boolean {
			if (!Boolean(__xml)) return __default;
			var __nodeValue:String = getNodeValue(__xml.child(__nodeName));
			if (__nodeValue.toLowerCase() == VALUE_TRUE) return true;
			if (__nodeValue.toLowerCase() == VALUE_FALSE) return false;
			return __default;
		}

		public static function getNodeAsString(__xml:XML, __nodeName:String, __default:String = ""):String {
			if (!Boolean(__xml)) return __default;
			var __nodeValue:String = getNodeValue(__xml.child(__nodeName));
			if (Boolean(__nodeValue)) return __nodeValue;
			return __default;
		}

		public static function getNodePathAsString(__xml:XML, __nodeNamePath:String, __default:String = ""):String {
			if (!Boolean(__xml)) return __default;
			if (!Boolean(__nodeNamePath)) return __default;

			var path:Array = __nodeNamePath.split("/");

			if (path.length == 1) return getNodeAsString(__xml, path[0]);

			var __subNodes:XMLList = __xml.child(path[0]);
			if (__subNodes.length() > 0) return getNodePathAsString(__subNodes[0], path.slice(1).join("/"));

			return __default;
		}

		public static function stripXMLNamespaces(__xml:XML):XML {
			// Source: http://active.tutsplus.com/articles/roundups/15-useful-as3-snippets-on-snipplr-com/
			var s:String = __xml.toString();
			var pattern1:RegExp = /\s*xmlns[^\'\"]*=[\'\"][^\'\"]*[\'\"]/gi;
			s = s.replace(pattern1, "");
			var pattern2:RegExp = /&lt;[\/]{0,1}(\w+:).*?&gt;/i;
			while(pattern2.test(s)) {
				s = s.replace(pattern2.exec(s)[1], "");
			}
			return XML(s);
		}

		public static function stripDefaultXMLNamespace(__xml:XML):XML {
			// Use for SVG
			// Source: http://stackoverflow.com/questions/673412/how-can-i-remove-a-namespace-from-an-xml-document
			var rawXMLString:String = __xml.toXMLString();

			/* Define the regex pattern to remove the default namespace from the String representation of the XML result. */
			var xmlnsPattern:RegExp = new RegExp("xmlns=[^\"]*\"[^\"]*\"", "gi");

			/* Replace the default namespace from the String representation of the result XML with an empty string. */
			var cleanXMLString:String = rawXMLString.replace(xmlnsPattern, "");

			// Create a new XML Object from the String just created
			return new XML(cleanXMLString);
		}

		public static function getNodeAsInt(__xml:XML, __nodeName:String, __default:int = 0):int {
			return int(getNodeAsFloat(__xml, __nodeName, __default));
		}

		public static function getNodeAsFloat(__xml:XML, __nodeName:String, __default:Number = 0):Number {
			if (!Boolean(__xml)) return __default;
			var __nodeValue:Number = parseFloat(getNodeValue(__xml.child(__nodeName)));
			if (!isNaN(__nodeValue)) return __nodeValue;
			return __default;
		}

		public static function getAttributeAsBoolean(__xml:XML, __attributeName:String, __default:Boolean = false):Boolean {
			if (!Boolean(__xml)) return __default;
			var __attributeValue:String = __xml.attribute(__attributeName);
			if (__attributeValue.toLowerCase() == VALUE_TRUE) return true;
			if (__attributeValue.toLowerCase() == VALUE_FALSE) return false;
			return __default;
		}

		public static function getAttributeAsString(__xml:XML, __attributeName:String, __default:String = ""):String {
			if (!Boolean(__xml)) return __default;
			var __attributeValue:String = __xml.attribute(__attributeName);
			if (Boolean(__attributeValue)) return __attributeValue;
			return __default;
		}

		public static function getAttributeAsStringVector(__xml:XML, __attributeName:String, __separator:String, __default:Array = null):Vector.<String> {
			if (!Boolean(__default)) __default = [];
			if (!Boolean(__xml)) return VectorUtils.arrayToStringVector(__default);
			var __attributeValue:String = __xml.attribute(__attributeName);
			if (Boolean(__attributeValue)) return VectorUtils.arrayToStringVector(__attributeValue.split(__separator));
			return VectorUtils.arrayToStringVector(__default);
		}

		public static function getAttributeAsInt(__xml:XML, __attributeName:String, __default:int = 0):Number {
			return int(getAttributeAsFloat(__xml, __attributeName, __default));
		}

		public static function getAttributeAsFloat(__xml:XML, __attributeName:String, __default:Number = 0):Number {
			if (!Boolean(__xml)) return __default;
			var __attributeValue:Number = parseFloat(__xml.attribute(__attributeName));
			if (!isNaN(__attributeValue)) return __attributeValue;
			return __default;
		}

		protected static function getNodeValue(__xmlList:XMLList):String {
			var str:String = "";
			if (__xmlList.length() > 0) str = __xmlList[0];
			return str;
			//return StringUtils.stripDoubleCRLF(str);
		}

		public static function getFirstNode(__xmlList:XMLList): XML {
			if (__xmlList.length() > 0) return __xmlList[0];
			return null;
		}
	}
}
