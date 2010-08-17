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

		public static function getNodeAsBoolean(__xml:XML, __nodeName:String, __default:Boolean = false): Boolean {
			if (!Boolean(__xml)) return __default;
			var __nodeValue:String = getNodeValue(__xml.child(__nodeName));
			if (__nodeValue == VALUE_TRUE) return true;
			if (__nodeValue == VALUE_FALSE) return false;
			return __default;
		}

		public static function getNodeAsString(__xml:XML, __nodeName:String, __default:String = ""): String {
			if (!Boolean(__xml)) return __default;
			var __nodeValue:String = getNodeValue(__xml.child(__nodeName));
			if (Boolean(__nodeValue)) return __nodeValue;
			return __default;
		}

		public static function getNodeAsInteger(__xml:XML, __nodeName:String, __default:int = 0): int {
			return int(getNodeAsFloat(__xml, __nodeName, __default));
		}

		public static function getNodeAsFloat(__xml:XML, __nodeName:String, __default:Number = 0): Number {
			if (!Boolean(__xml)) return __default;
			var __nodeValue:Number = parseFloat(getNodeValue(__xml.child(__nodeName)));
			if (!isNaN(__nodeValue)) return __nodeValue;
			return __default;
		}

		public static function getAttributeAsBoolean(__xml:XML, __attributeName:String, __default:Boolean = false): Boolean {
			if (!Boolean(__xml)) return __default;
			var __attributeValue:String = __xml.attribute(__attributeName);
			if (__attributeValue == VALUE_TRUE) return true;
			if (__attributeValue == VALUE_FALSE) return false;
			return __default;
		}

		public static function getAttributeAsString(__xml:XML, __attributeName:String, __default:String = ""): String {
			if (!Boolean(__xml)) return __default;
			var __attributeValue:String = __xml.attribute(__attributeName);
			if (Boolean(__attributeValue)) return __attributeValue;
			return __default;
		}

		public static function getAttributeAsInt(__xml:XML, __attributeName:String, __default:int = 0): Number {
			return int(getAttributeAsFloat(__xml, __attributeName, __default));
		}

		public static function getAttributeAsFloat(__xml:XML, __attributeName:String, __default:Number = 0): Number {
			if (!Boolean(__xml)) return __default;
			var __attributeValue:Number = parseFloat(__xml.attribute(__attributeName));
			if (!isNaN(__attributeValue)) return __attributeValue;
			return __default;
		}

		protected static function getNodeValue(__xmlList:XMLList): String {
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
