package com.zehfernando.localization {

	import com.zehfernando.data.types.Color;
	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class StringList {

		// Constants
		public static const LANGUAGE_LIST_SEPARATOR:String = ",";
		public static const ID_HYERARCHY_SEPARATOR:String = "/";
		public static const VALUE_NOT_FOUND:String = "[null]";
		
		// Properties
		protected static var strings:StringListGroup;
		protected static var currentLanguages:Vector.<String>;						// Current language

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StringList() {
			throw new Error("Instantiation not allowed");
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		protected static function getXMLAsItem(__item:XML): StringListItem {
			var newItem:StringListItem;
			var i:int;
			
			switch (String(__item.name())) {
				case "group":
					newItem = getXMLListAsGroup(__item.children());
					//trace (newItem.name, newItem["items"].length);
					break;
				case "string":
					newItem = new StringListString();
					(newItem as StringListString).value = __item.toString();
					break;
				case "color":
					newItem = new StringListColor();
					(newItem as StringListColor).setFromString(__item);
					//trace ("--------->" +  __item + " -> " + newItem["value"]);
					break;
				case "number":
					newItem = new StringListNumber();
					(newItem as StringListNumber).setFromString(__item);
					break;
				case "boolean":
					newItem = new StringListBoolean();
					(newItem as StringListBoolean).setFromString(__item);
					//trace (newItem.name, newItem["value"]);
					break;
				case "array":
					newItem = new StringListArray();
					
					
					// Ugh? Use the stringlist items for this too
					var subItems:XMLList = __item.children();
					for (i = 0; i < subItems.length(); i++) {
						switch (String((subItems[i] as XML).name())) {
							case "string":
								((newItem as StringListArray).value as Array).push(String(subItems[i]));
								break;
							case "number":
								((newItem as StringListArray).value as Array).push(parseFloat(String(subItems[i])));
								break;
							case "color":
								((newItem as StringListArray).value as Array).push(Color.fromString(String(subItems[i])).toRRGGBB());
								break;
							case "boolean":
								((newItem as StringListArray).value as Array).push(String(subItems[i]) == StringListBoolean.VALUE_TRUE);
								break;
						}
					}
					//trace (newItem.name, newItem["value"]);
					break;
				default:
					trace ("StringList :: Error parsing string node of type ["+String(__item.name())+"]");
			}
			
			newItem.name = __item.attribute("name");
			
//			trace ("--> " + newItem.name + " ==== " + newItem["value"]);
			
			var itemLang:String = __item.attribute("language");
			if (Boolean(itemLang)> 0) {
				var langs:Array = itemLang.split(LANGUAGE_LIST_SEPARATOR);
				for (i = 0; i < langs.length; i++) {
					newItem.languages.push(langs[i]);
				}
			}
			
			return newItem;
		}
		
		protected static function getXMLListAsGroup(__items:XMLList): StringListGroup {
			var newGroup:StringListGroup = new StringListGroup();
			var i:int;
			for (i = 0; i < __items.length(); i++) {
				newGroup.items.push(getXMLAsItem(__items[i]));
			}
			return newGroup;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function setFromXML(__xml:XML): void {
			strings = getXMLListAsGroup(__xml.children());
			// TODO: read XML data correctly? replace unix/windows line feed....
		}

		public static function setCurrentLanguage(__language:String): void {
			setCurrentLanguages(__language);
		}
		
		public static function setCurrentLanguages(... __languages): void {
			currentLanguages = new Vector.<String>();
			for (var i:int = 0; i < __languages.length; i++) {
				currentLanguages.push(__languages[i]);
			}
			// TODO: add language change event listener
		}

		public static function getCurrentLanguages(): Vector.<String> {
			return currentLanguages.concat();
		}

		public static function getValue(__id:String, ... __languages): * {
			
			// Get the full path to the value name
			var ids:Array = __id.split(ID_HYERARCHY_SEPARATOR);
			var names:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < ids.length; i++) names.push(ids[i]);

			var langsToUse:Vector.<String>;
			if (Boolean(__languages) && __languages.length > 0) {
				langsToUse = new Vector.<String>();
				for (i = 0; i < __languages.length; i++) langsToUse.push(__languages[i]); 
			} else {
				langsToUse = StringList.getCurrentLanguages();
			}
			
			return strings.getValueByNames(names, langsToUse);
		}

		public static function getColor(__id:String, ... __languages): int {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args);
		}

		public static function getString(__id:String, ... __languages): String {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args);
		}



		public static function getProcessedString(__string:String):String {
			// Returns a string with processed codes
			// For example "this is an ${examples/example}!" returns "this is an EXAMPLE!" (where the value of examples/example in strings.xml is "EXAMPLE")
			
//			__string = "this is a ${test} and a ${test2}.";
//			__string = "hello.";
			
			var newString:String = "";

			var codes:RegExp = /\$\{(.+?)\}/ig;
			var result:Object = codes.exec(__string);
			
			var lastIndex:Number = 0;
			var newIndex:Number;
			
//			trace ("INPUT ============================ " + __string);

			while (Boolean(result)) {
				newIndex = result["index"];
				
				// What came before the tag
				newString += __string.substring(lastIndex, newIndex);

				// The tag tex
				newString += getValue(result[1]);

				lastIndex = codes.lastIndex;

//				trace ("----------> " + result.index, codes.lastIndex + " = " + result[0] + " -------->  " + result[1]);
				result = codes.exec(__string);
			}
			
			// End text after last tag
			newString += __string.substring(lastIndex, __string.length);

//			trace ("OUTPUT ============================ " + newString);

			return newString;
			
		}

//		public static function filter(__txt:String, __language:String = null): String {
//			// If a string starts with "##", gets from list; if not, uses original
//			if (Boolean(__txt) && __txt.substr(0, 2) == "##") {
//				var st:String = StringList.getString(__txt.substr(1), __language);
//				if (st == StringListItem.NULL_STRING) {
//					return "["+__txt+"]";
//				} else {
//					return st;
//				}
//			} else {
//				return __txt;
//			}
//			return "";
//		}
	}
}

import com.zehfernando.data.types.Color;
import com.zehfernando.localization.StringList;

// ================================================================================================================
// AUXILIARY classes ----------------------------------------------------------------------------------------------

class StringListItem {

	// Properties
	public var name:String;
	public var languages:Vector.<String>;
	public var value:*;

	// Constructor
	public function StringListItem() {
		name = "";
		languages = new Vector.<String>();
	}
	
	// Public functions
	public function getValueByNames(__names:Vector.<String>, __languages:Vector.<String>): * {
		__languages; // Useless, to avoid FDT highlights - ugh
		if (__names.length == 0) return value;
	}
}
class StringListGroup extends StringListItem {
	
	// Properties
	public var items:Vector.<StringListItem>;
	
	// Constructor
	public function StringListGroup() {
		//super();

		items = new Vector.<StringListItem>();
	}

	// Public functions
	override public function getValueByNames(__names:Vector.<String>, __languages:Vector.<String>): * {
		var i:int, j:int;
		
//		trace (" group getValueByNames == " + __names);

//		trace (" -- langs");

		// Looks for all languages, one by one
		for (i = 0; i < __languages.length; i++) {
//			trace ("    looking at item with language "+__languages[i]);
			// Looks for all items
			for (j = 0; j < items.length; j++) {
//				trace("        looking at item "+ items[j].name);
				if (items[j].name == __names[0] && items[j].languages.indexOf(__languages[i])> -1) return items[j].getValueByNames(__names.slice(1), __languages);
			}
		}

//		trace (" -- no lang");

		// Not found, try a value with no language
		for (i = 0; i < items.length; i++) {
//			trace ("    looking at item "+items[i].name);
			if (items[i].name == __names[0] && items[i].languages.length == 0) return items[i].getValueByNames(__names.slice(1), __languages);
		}

//		trace (" -- not found!");

		// Not found at all
		return StringList.VALUE_NOT_FOUND;
	}
}

class StringListArray extends StringListItem {

	// Constructor
	public function StringListArray() {
		super();

		value = [];
	}
}

class StringListString extends StringListItem {

	// Constructor
	public function StringListString() {
		super();

		value = "";
	}
}

class StringListNumber extends StringListItem {

	// Constructor
	public function StringListNumber() {
		super();

		value = 0;
	}
	
	// Public functions
	public function setFromString(__value:String): void {
		value = parseFloat(__value);
	}

}

class StringListColor extends StringListItem {

	// Constructor
	public function StringListColor() {
		super();

		value = 0;
	}
	
	// Public functions
	public function setFromString(__value:String): void {
		value = Color.fromString(__value).toRRGGBB();
	}

}

class StringListBoolean extends StringListItem {

	// Constants
	public static const VALUE_TRUE:String = "true";
	public static const VALUE_FALSE:String = "false";

	// Constructor
	public function StringListBoolean() {
		super();

		value = false;
	}
	
	// Public functions
	public function setFromString(__value:String): void {
		value = __value == VALUE_TRUE;
	}
}

//	protected static function parseXMLText(__text:String): String {
//		return __text.split("\r\n").join("\n");
//	} 
