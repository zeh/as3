package com.zehfernando.localization {

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class StringList {

		protected static var strings:Object;						// List of StringListItem
		protected static var language:String;					// Current language
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StringList() {
			throw new Error("Instantiation not allowed");
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		{
			strings = {};
		}

		/*
		 * Reads the string data from a XML object
		 * 
		 * @param	__xml	Object that should be read
		 * @return			TRUE if the list was successfully read, FALSE if otherwise
		 */
		public static function addFromXML(__xml:XML): Boolean {
			
			var i:uint, j:uint;
			var tStrings:XMLList = __xml.child("string");
			var tValues:XMLList;
			var success:Boolean = false;
			var stringName:String;
			
			for (i = 0; i < tStrings.length(); i++) {
				tValues = (tStrings[i] as XML).child("value");
				stringName = String(tStrings[i].@id); 
				if (!Boolean(strings[stringName])) strings[stringName] = new StringListItem();
				for (j = 0; j < tValues.length(); j++) {
					StringListItem(strings[stringName]).addValue(String(tValues[j].@language), String(tValues[j]));
					if (!success) success = true;
				}
			}

			return success;
		}
		
		public static function setLanguage(__language:String): void {
			language = __language;
			// TODO: add language change event listener
		}

		public static function getLanguage(): String {
			return (language);
		}

		public static function getString(__id:String, __language:String = null): String {
			// Returns a language
			if (strings[__id] != null) {
				return (StringListItem(strings[__id]).getValue(__language == null ? language : __language));
			}
			return "[null]"; // No string with this id was found
		}
		
		public static function filter(__txt:String, __language:String = null): String {
			// If a string starts with "##", gets from list; if not, uses original
			if (Boolean(__txt) && __txt.substr(0, 2) == "##") {
				var st:String = StringList.getString(__txt.substr(1), __language);
				if (st == StringListItem.NULL_STRING) {
					return "["+__txt+"]";
				} else {
					return st;
				}
			} else {
				return __txt;
			}
		}
	}
}

// ================================================================================================================
// AUXILIARY classes ----------------------------------------------------------------------------------------------

class StringListItem extends Object {

	public static const NULL_STRING:String = "[null]";

	protected var languages:Array;				// Languages, like "pt-br"
	protected var values:Array;					// Actual values, like "YES"

	public function StringListItem() {
		languages = [];
		values = [];
	}

	public function addValue(__languages:String, __value:String): void {
		languages.push(__languages.toLowerCase());
		values.push(parseXMLText(__value));
	}	
	
	public function getValue(__language:String): String {
		// Try to get a value according to the language
		var i:Number, j:Number;
		var pLangs:Array = __language.toLowerCase().split(";");
		
		// First, try the specific language
		for (i = 0; i < pLangs.length; i++) {
			for (j = 0; j < languages.length; j++) {
				if ((languages[j] as String).split(";").indexOf(pLangs[i]) > -1) {
					return values[j];
				} 
			}
		}

		// Then, try a tag with no language
		for (i = 0; i < languages.length; i++) {
			if (languages[i] == "") {
				return values[i];
			} 
		}

		return NULL_STRING; // No string for this language was found inside this id 
	}

	protected static function parseXMLText(__text:String): String {
		return __text.split("\r\n").join("\n");
	} 
}
