package com.zehfernando.localization {

	import com.zehfernando.data.types.Color;
	import com.zehfernando.utils.DateUtils;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class StringList {
		
//		Android:
//		<color name="color">#ffffff</color>
//		<dimen name="dimension">10px</dimen>
//		<drawable name="drawable">#ffffff</drawable>
//		<integer-array name="integer_array">
//			<item>1312</item>
//		</integer-array>
//		<item format="color" type="color" name="item">#ffffff</item>
//		<string name="string">0187390123</string>
//		<string-array name="string_array">
//			<item>lajsdhlas</item>
//		</string-array>
//		<style parent="asda" name="style_theme"></style>
/*

		<string>
		<color>
		<number>
		<boolean>
		<datetime>
		
		<string-array>
		<color-array>
		<number-array>
		<boolean-array>
		<datetime-array>
		
		<group>
		
		<data>
*/
		

		// Constants
		public static const LANGUAGE_LIST_SEPARATOR:String = ",";
		public static const ID_HYERARCHY_SEPARATOR:String = "/";
		
		// Value enums
		protected static const VALUE_BOOLEAN_TRUE:String = "true";
		protected static const VALUE_BOOLEAN_FALSE:String = "false";
		
		// Default values - in string, to be interpreted by using the same parser
		protected static const VALUE_STRING_DEFAULT:String = "";
		protected static const VALUE_NUMBER_DEFAULT:String = "0";
		protected static const VALUE_BOOLEAN_DEFAULT:String = VALUE_BOOLEAN_FALSE;
		protected static const VALUE_COLOR_DEFAULT:String = "#000000";
		protected static const VALUE_DATETIME_DEFAULT:String = "1980-01-01T00:00:00-06:00";

		protected static const VALUE_NOT_FOUND:String = "[null]"; // TODO: properly return null when this happens? or the string id itself?

		// Type enums
		protected static const TYPE_STRING:String = "string";
		protected static const TYPE_STRING_ARRAY:String = "string-array";
		protected static const TYPE_NUMBER:String = "number";
		protected static const TYPE_NUMBER_ARRAY:String = "number-array";
		protected static const TYPE_BOOLEAN:String = "boolean";
		protected static const TYPE_BOOLEAN_ARRAY:String = "boolean-array";
		protected static const TYPE_COLOR:String = "color";
		protected static const TYPE_COLOR_ARRAY:String = "color-array";
		protected static const TYPE_DATETIME:String = "datetime";
		protected static const TYPE_DATETIME_ARRAY:String = "datetime-array";
		protected static const TYPE_DATA:String = "data";
		protected static const TYPE_GROUP:String = "group";
		protected static const TYPE_ITEM:String = "item";

		// Properties
		protected static var values:ValueGroup;
		protected static var currentLanguages:Vector.<String>;						// Current language, ie, ["en", "en-us"]

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------
		
		protected static function init(): void {
			// ValueGroup is not accessible on the actual static init block, so initialize it manually
			if (!Boolean(values)) {
				values = new ValueGroup();
			}
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StringList() {
			throw new Error("Instantiation not allowed");
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		protected static function getXMLAsItem(__item:XML): ValueNode {
			// Converts XML data to a value node
			var newItem:ValueNode;
			var i:int;
			var nodeName:String = __item.name();
			
			// Set the value's content
			switch (nodeName) {
				case TYPE_STRING:
				case TYPE_NUMBER:
				case TYPE_BOOLEAN:
				case TYPE_COLOR:
				case TYPE_DATETIME:
					newItem = new ValueString();
					newItem.type = nodeName;
					(newItem as ValueString).value = __item.toString();
					break;
				case TYPE_STRING_ARRAY:
				case TYPE_NUMBER_ARRAY:
				case TYPE_BOOLEAN_ARRAY:
				case TYPE_COLOR_ARRAY:
				case TYPE_DATETIME_ARRAY:
					newItem = new ValueArray();
					newItem.type = nodeName;
					var subItems:XMLList = __item.child(TYPE_ITEM);
					for (i = 0; i < subItems.length(); i++) {
						(newItem as ValueArray).items.push(String(subItems[i]));
					}
					break;
				case TYPE_DATA:
					newItem = new ValueXML();
					(newItem as ValueXML).value = __item;
					break;
				case TYPE_GROUP:
					newItem = getXMLListAsGroup(__item.children());
					break;
				default:
					trace ("StringList :: Error parsing string node of type ["+String(__item.name())+"]");
					return null;
			}
			
			// Sets the value's name
			newItem.name = __item.attribute("name");
			
			// Sets the value's languages
			var itemLang:String = __item.attribute("language");
			if (Boolean(itemLang)> 0) {
				var langs:Array = itemLang.split(LANGUAGE_LIST_SEPARATOR);
				for (i = 0; i < langs.length; i++) {
					newItem.languages.push(langs[i]);
				}
			}
			
			return newItem;
		}
		
		protected static function getXMLListAsGroup(__items:XMLList): ValueGroup {
			// Converts XML data to a value group
			var newGroup:ValueGroup = new ValueGroup();
			newGroup.type = TYPE_GROUP; // TODO: this is redundant, remove?
			var i:int;
			for (i = 0; i < __items.length(); i++) {
				newGroup.items.push(getXMLAsItem(__items[i]));
			}
			return newGroup;
		}

		protected static function convertStringToType(__string:String, __type:String): * {
			switch(__type) {
				case TYPE_STRING:
					if (!Boolean(__string)) __string = VALUE_STRING_DEFAULT;
					return __string;
				case TYPE_NUMBER:
					if (!Boolean(__string)) __string = VALUE_NUMBER_DEFAULT;
					return parseFloat(__string);
				case TYPE_BOOLEAN:
					if (!Boolean(__string)) __string = VALUE_BOOLEAN_DEFAULT;
					return __string.toLowerCase() == VALUE_BOOLEAN_TRUE;
				case TYPE_COLOR:
					if (!Boolean(__string)) __string = VALUE_COLOR_DEFAULT;
					return Color.fromString(__string).toAARRGGBB();
				case TYPE_DATETIME:
					if (!Boolean(__string)) __string = VALUE_DATETIME_DEFAULT;
					return DateUtils.xsdDateTimeToDate(__string);
				default:
					trace ("StringList :: Error trying to convert string to node of type ["+String(__type)+"]");
				break;
			}
			return null;
		}

		protected static function getProcessedString(__string:String, __languages:Vector.<String>): String {
			// Returns a string with processed codes
			// For example "this is an ${examples/example}!" returns "this is an EXAMPLE!" (where the value of examples/example in strings.xml is "EXAMPLE")
			
			// Should be recursive

			var newString:String = "";

			var codes:RegExp = /\$\{(.+?)\}/ig;
			var result:Object = codes.exec(__string);
			
			var lastIndex:Number = 0;
			var newIndex:Number;

			while (Boolean(result)) {
				newIndex = result["index"];
				
				// What came before the tag
				newString += __string.substring(lastIndex, newIndex);

				// The tag tex
				newString += getString.apply(null, ([result[1]] as Array).concat(__languages));

				lastIndex = codes.lastIndex;

				result = codes.exec(__string);
			}
			
			// End text after last tag
			newString += __string.substring(lastIndex, __string.length);

//			trace ("OUTPUT ============================ " + newString);

			return newString;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function setFromXML(__xml:XML): void {
			init();

			values.add(getXMLListAsGroup(__xml.children()));
			// TODO: read string data replacing unix/windows line feed?
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
			var i:int;
			
			// Get the full path to the value name
			var ids:Array = __id.split(ID_HYERARCHY_SEPARATOR);
			var names:Vector.<String> = new Vector.<String>();
			for (i = 0; i < ids.length; i++) names.push(ids[i]);

			var langsToUse:Vector.<String>;
			if (Boolean(__languages) && __languages.length > 0) {
				langsToUse = new Vector.<String>();
				for (i = 0; i < __languages.length; i++) langsToUse.push(__languages[i]); 
			} else {
				langsToUse = StringList.getCurrentLanguages();
			}

			var node:ValueNode = values.getValueNodeByNames(names, langsToUse);
			
			// Sets data depending on type
			
			if (node is ValueString) {
				// Any standard string node
				return convertStringToType(getProcessedString((node as ValueString).value, langsToUse), node.type);
			
			} else if (node is ValueArray)  {
				// Any array node
				var lst:*;
				var itemType:String;

				switch(node.type) {
					case TYPE_STRING_ARRAY:
						lst = new Vector.<String>();
						itemType = TYPE_STRING;
						break;
					case TYPE_NUMBER_ARRAY:
						lst = new Vector.<Number>();
						itemType = TYPE_NUMBER;
						break;
					case TYPE_BOOLEAN_ARRAY:
						lst = new Vector.<Boolean>();
						itemType = TYPE_BOOLEAN;
						break;
					case TYPE_COLOR_ARRAY:
						lst = new Vector.<Color>();
						itemType = TYPE_COLOR;
						break;
					case TYPE_DATETIME_ARRAY:
						lst = new Vector.<Date>();
						itemType = TYPE_DATETIME;
						break;
					default:
						trace ("StringList :: Error trying to convert array to node of type ["+node.type+"]");
						return null;
					break;
				}

				for (i = 0; i < (node as ValueArray).items.length; i++) {
					lst["push"](convertStringToType(getProcessedString((node as ValueArray).items[i], langsToUse), itemType));
				}
				
				return lst;
			} else if (node is ValueXML) {
				// Any XML node
				return (node as ValueXML).value;
				
			} else if (!Boolean(node)) {
				// Not found at all
				return VALUE_NOT_FOUND;
			}

			trace ("StringList :: Error trying to read node [" + node + "] of type ["+node.type+"]");			
			return null;
		}

		public static function getString(__id:String, ... __languages): String {
			var args:Array = [__id];
			args = args.concat(__languages);

			return getValue.apply(null, args);
		}

		public static function getNumber(__id:String, ... __languages): Number {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args);
		}

		public static function getBoolean(__id:String, ... __languages): Boolean {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args);
		}

		public static function getColor(__id:String, ... __languages): int {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args);
		}

		public static function getStringArray(__id:String, ... __languages): Vector.<String> {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args) as Vector.<String>;
		}

		public static function getNumberArray(__id:String, ... __languages): Vector.<Number> {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args) as Vector.<Number>;
		}

		public static function getBooleanArray(__id:String, ... __languages): Vector.<Boolean> {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args) as Vector.<Boolean>;
		}

		public static function getColorArray(__id:String, ... __languages): Vector.<uint> {
			var args:Array = [__id];
			args = args.concat(__languages);
			
			return getValue.apply(null, args) as Vector.<uint>;
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


// ================================================================================================================
// AUXILIARY classes ----------------------------------------------------------------------------------------------

// Auxiliary classes should be type-agnostic (except for data, which uses XML data)

class ValueNode {
	// Properties
	public var name:String;						// Name of this node
	public var languages:Vector.<String>;		// Languages supported by this node
	public var type:String;						// Type of this node

	// Constructor
	public function ValueNode() {
		name = "";
		languages = new Vector.<String>();
	}
}

class ValueString extends ValueNode {

	// Properties
	public var value:String;

	// Constructor
	public function ValueString() {
		super();
		
		value = "";
	}
}

class ValueXML extends ValueNode {

	// Properties
	public var value:XML;

	// Constructor
	public function ValueXML() {
		super();
		
		value = null;
	}
}

class ValueArray extends ValueNode {

	// Properties
	public var items:Vector.<String>;

	// Constructor
	public function ValueArray() {
		super();
		
		items = new Vector.<String>();
	}
}

class ValueGroup extends ValueNode {
	
	// Properties
	public var items:Vector.<ValueNode>;
	
	// Constructor
	public function ValueGroup() {
		super();

		items = new Vector.<ValueNode>();
	}

	public function add(__strings:ValueGroup):void {
		// Adds items from another string list group, overwriting items if they have the same name
		// Warning - only overwrites on a top level!
		// TODO: proper overwrite of sub-elements only
		var i:int, j:int;
		for (i = 0; i < __strings.items.length; i++) {
			for (j = 0; j < items.length; j++) {
				if (items[j].name == __strings.items[i].name) {
					items.splice(j, 1);
					j--;
				}
			}
			items.push(__strings.items[i]);
		}
		
		//Log.echo("Strings has " + items.length + "items!");
	}

	// Public functions
	public function getValueNodeByNames(__names:Vector.<String>, __languages:Vector.<String>): ValueNode {
		// Returns a value given its name path and languages
		// Same as StringList.getValue(), but with pre-processed parameters

		var i:int, j:int;
		
		// Looks for all languages, one by one
		for (i = 0; i < __languages.length; i++) {
			// Looks for all items
			for (j = 0; j < items.length; j++) {
				if (items[j].name == __names[0] && items[j].languages.indexOf(__languages[i]) > -1) {
					if (items[j] is ValueGroup) {
						// Sub-node is a group of nodes, get item from it
						return (items[j] as ValueGroup).getValueNodeByNames(__names.slice(1), __languages);
					} else {
						// Sub-node is a final value, return it
						return items[j];
					}
				}
			}
		}

		// Not found, try a value with no language
		// TODO: redundant, refactor this
		for (i = 0; i < items.length; i++) {
			if (items[i].name == __names[0] && items[i].languages.length == 0) {
				if (items[i] is ValueGroup) {
					// Sub-node is a group of nodes, get item from it
					return (items[i] as ValueGroup).getValueNodeByNames(__names.slice(1), __languages);
				} else {
					// Sub-node is a final value, return it
					return items[i];
				}
			}
		}

		// Not found at all
		return null;
	}

}