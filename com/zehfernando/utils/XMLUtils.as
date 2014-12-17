package com.zehfernando.utils {
	/**
	 * @author zeh
	 */
	public class XMLUtils {

		// Constants
		protected static const VALUE_TRUE:String = "true";			// Array considered as explicit "true" when reading data from a XML
		protected static const VALUE_FALSE:String = "false";		// Array considered as explicit "false" when reading data from a XML

		private static var filterListSortAttributeNames:Array;				// Temp for getFilteredNodeList()'s sort function


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function hasNode(__xml:XML, __nodeName:String):Boolean {
			if (!Boolean(__xml)) return false;
			return __xml.child(__nodeName).length() > 0;
		}

		public static function getNode(__xml:XML, __nodeName:String):XML {
			if (!Boolean(__xml)) return null;
			var __nodes:XMLList = __xml.child(__nodeName);
			if (__nodes.length() == 0) return null;
			return __nodes[0];
		}

		public static function getValue(__xml:XML, __default:String = ""):String {
			return __xml == null ? __default : StringUtils.getCleanString(__xml);
		}

		public static function getNodeName(__xml:XML, __default:String = ""):String {
			return __xml == null ? __default : StringUtils.getCleanString(__xml.name());
		}

		public static function getNodeAsBoolean(__xml:XML, __nodeName:String, __default:Boolean = false):Boolean {
			if (!Boolean(__xml)) return __default;
			var __nodeValue:String = StringUtils.getCleanString(getNodeValue(__xml.child(__nodeName)));
			if (__nodeValue.toLowerCase() == VALUE_TRUE) return true;
			if (__nodeValue.toLowerCase() == VALUE_FALSE) return false;
			return __default;
		}

		public static function getFilteredNodeAsFloat(__xml:XML, __nodeName:String, __attributeNames:Array, __attributeFilters:Array, __includeEmptyAttribute:Boolean = true, __allowAnyPartOfString:Boolean = true, __default:Number = 0):Number {
			var str:String = getFilteredNodeAsString(__xml, __nodeName, __attributeNames, __attributeFilters, __includeEmptyAttribute = true, __allowAnyPartOfString = true, null);
			return str == null ? __default : parseFloat(str);
		}

		public static function getFilteredNodeAsInt(__xml:XML, __nodeName:String, __attributeNames:Array, __attributeFilters:Array, __includeEmptyAttribute:Boolean = true, __allowAnyPartOfString:Boolean = true, __default:int = 0):int {
			return int(getFilteredNodeAsFloat(__xml, __nodeName, __attributeNames, __attributeFilters, __includeEmptyAttribute = true, __allowAnyPartOfString = true, __default));
		}

		public static function getFilteredNodeAsBoolean(__xml:XML, __nodeName:String, __attributeNames:Array, __attributeFilters:Array, __includeEmptyAttribute:Boolean = true, __allowAnyPartOfString:Boolean = true, __default:Boolean = false):Boolean {
			var str:String = getFilteredNodeAsString(__xml, __nodeName, __attributeNames, __attributeFilters, __includeEmptyAttribute = true, __allowAnyPartOfString = true, null);
			if (str == null) return __default;
			str = str.toLowerCase();
			if (str == VALUE_TRUE) return true;
			if (str == VALUE_FALSE) return false;
			return __default;
		}

		public static function getFilteredNodeAsString(__xml:XML, __nodeName:String, __attributeNames:Array, __attributeFilters:Array, __includeEmptyAttribute:Boolean = true, __allowAnyPartOfString:Boolean = true, __default:String = ""):String {
			// Returns the value of a subnode as a string, but filtering by attributes of a single type
			// If "__includeEmptyAttribute" is true, nodes with an empty or invalid attribute are treated as the default
			// If "__allowAnyPartOfString" is true, "stuff" matches "some stuff"
			if (__xml == null) return __default;
			var node:XML = getFilteredFirstNode(__xml.child(__nodeName), __attributeNames, __attributeFilters, __includeEmptyAttribute, __allowAnyPartOfString);
			return node == null ? __default : StringUtils.getCleanString(node);
		}

		public static function getNodeAsString(__xml:XML, __nodeName:String, __default:String = ""):String {
			if (!Boolean(__xml)) return __default;
			var __nodeValue:String = StringUtils.getCleanString(getNodeValue(__xml.child(__nodeName)));
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
			return XML(StringUtils.getCleanString(s));
		}

		public static function stripDefaultXMLNamespace(__xml:XML):XML {
			// Use for SVG
			// Source: http://stackoverflow.com/questions/673412/how-can-i-remove-a-namespace-from-an-xml-document
			var rawXMLString:String = __xml.toXMLString();

			/* Define the regex pattern to remove the default namespace from the String representation of the XML result. */
			var xmlnsPattern:RegExp = new RegExp("xmlns=[^\"]*\"[^\"]*\"", "gi");

			/* Replace the default namespace from the String representation of the result XML with an empty string. */
			var cleanXMLString:String = StringUtils.getCleanString(rawXMLString.replace(xmlnsPattern, ""));

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
			var __attributeValue:String = String(__xml.attribute(__attributeName)).toLowerCase();
			if (__attributeValue == VALUE_TRUE) return true;
			if (__attributeValue == VALUE_FALSE) return false;
			return __default;
		}

		public static function getAttributeAsString(__xml:XML, __attributeName:String, __default:String = ""):String {
			if (!Boolean(__xml)) return __default;
			var __attributeValue:String = StringUtils.getCleanString(__xml.attribute(__attributeName));
			if (Boolean(__attributeValue)) return __attributeValue;
			return __default;
		}

		public static function getAttributeAsStringVector(__xml:XML, __attributeName:String, __separator:String, __default:Array = null):Vector.<String> {
			if (!Boolean(__default)) __default = [];
			if (!Boolean(__xml)) return VectorUtils.arrayToStringVector(__default);
			var __attributeValue:String = StringUtils.getCleanString(__xml.attribute(__attributeName));
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
			if (__xmlList.length() > 0) str = StringUtils.getCleanString(__xmlList[0]);
			return str;
			//return StringUtils.stripDoubleCRLF(str);
		}

		public static function getFirstNode(__xmlList:XMLList):XML {
			if (__xmlList != null && __xmlList.length() > 0) return __xmlList[0];
			return null;
		}

		public static function getFilteredFirstNode(__xmlList:XMLList, __attributeNames:Array, __attributeFilters:Array, __includeEmptyAttribute:Boolean = true, __allowAnyPartOfString:Boolean = true):XML {
			var list:Vector.<XML> = getFilteredNodeList(__xmlList, __attributeNames, __attributeFilters, __includeEmptyAttribute, __allowAnyPartOfString);
			return list.length > 0 ? list[0] : null;
		}

		public static function getFilteredNodeList(__xmlList:XMLList, __attributeNames:Array, __attributeFilters:Array, __includeEmptyAttribute:Boolean = true, __allowAnyPartOfString:Boolean = true):Vector.<XML> {
			var list:Vector.<XML> = new Vector.<XML>();
			if (__xmlList != null && __xmlList.length() >= 0) {
				var i:int;

				// Initial list
				for (i = 0; i < __xmlList.length(); i++) list.push(__xmlList[i]);

//				if (list.length > 0 && list[0].name() == "scaleLogoBrand") {
//					log("--");
//					for (j = 0; j < list.length; j++) {
//						log("  Initial list => " + j + " => ada = [" + list[j].attribute("ada") + "], platform = [" + list[j].attribute("platform") + "], value = " + list[j].valueOf());
//					}
//				}

				// Apply all filters
				for (i = 0; i < __attributeNames.length; i++) {
					list = getSingleFilteredNodeList(list, __attributeNames[i], __attributeFilters[i], __includeEmptyAttribute, __allowAnyPartOfString);
//					if (list.length > 0 && list[0].name() == "scaleLogoBrand") {
//						log("  Filtering [" + __attributeNames[i] + "] = [" + __attributeFilters[i] + "]");
//						for (j = 0; j < list.length; j++) {
//							log("    Iteration [" + i + "] => " + j + " => ada = " + list[j].attribute("ada") + ", platform = " + list[j].attribute("platform") + ", value = " + list[j].valueOf());
//						}
//					}
				}

				// Sort the list by more important items first (by number of items that match, then order of attribute name preference)
				filterListSortAttributeNames = __attributeNames;
				list = list.sort(sortFilterList);
			}

			return list;
		}

		private static function sortFilterList(__xml1:XML, __xml2:XML):int {
			// Count the number of items of both lists
			var i:int;
			var filters1:Vector.<int> = new Vector.<int>();
			var filters2:Vector.<int> = new Vector.<int>();
			for (i = 0; i < filterListSortAttributeNames.length; i++) {
				if (__xml1.attribute(filterListSortAttributeNames[i]).length() > 0) filters1.push(i);
				if (__xml2.attribute(filterListSortAttributeNames[i]).length() > 0) filters2.push(i);
			}

			// Check if either node has more valid filter attributes
			if (filters1.length > filters2.length) return -1;
			if (filters2.length > filters1.length) return 1;

			// Same number of attributes, returns whoever has the more important item
			for (i = 0; i < filters1.length; i++) {
				if (filters1[i] < filters2[i]) return -1;
				if (filters1[i] > filters2[i]) return 1;
			}

			// They're the same!
			return 0;
		}

		public static function getSingleFilteredNodeList(__xmls:Vector.<XML>, __attributeName:String, __attributeFilter:String, __includeEmptyAttribute:Boolean = true, __allowAnyPartOfString:Boolean = true):Vector.<XML> {
			var list:Vector.<XML> = new Vector.<XML>();

			if (__xmls.length >= 0) {

				var currentAttribute:String;
				for (var i:int = 0; i < __xmls.length; i++) {
					currentAttribute = (__xmls[i] as XML).attribute(__attributeName);
					if (!Boolean(currentAttribute) && __includeEmptyAttribute) {
						// No attribute (is a fallback node), still add it
						list.push(__xmls[i]);
					} else {
						// Has attribute
						if ((currentAttribute == __attributeFilter || (__allowAnyPartOfString && currentAttribute.indexOf(__attributeFilter) > -1))) {
							list.push(__xmls[i]);
						}
					}
				}
			}

			return list;
		}
	}
}
