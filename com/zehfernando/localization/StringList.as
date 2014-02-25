package com.zehfernando.localization {
	import com.zehfernando.data.types.Color;
	import com.zehfernando.utils.DateUtils;
	import com.zehfernando.utils.StringUtils;

	import flash.events.EventDispatcher;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class StringList extends EventDispatcher {

/*
		<string name="myString" language="en,en-us">aaaa</string>
		<color>#ffffff</color> <!-- Or any CSS-like value -->
		<number>110.2</number>
		<boolean>true</boolean>
		<datetime>1980-01-01T00:00:00-06:00</datetime>

		<string-array><item>...</item></string-array>
		<color-array>
		<number-array>
		<boolean-array>
		<datetime-array>

		<group>...</group>

		<data><someXML/></data>
*/

		// Constants
		public static const LANGUAGE_LIST_SEPARATOR:String = ",";
		public static const ID_HYERARCHY_SEPARATOR:String = "/";

		// Static properties
		protected static var lists:Vector.<StringList>;

		// Value enums
		protected static const VALUE_BOOLEAN_TRUE:String = "true";
		protected static const VALUE_BOOLEAN_FALSE:String = "false";

		// Default values - in string, to be interpreted by using the same parser
		protected static const VALUE_STRING_DEFAULT:String = "";
		protected static const VALUE_NUMBER_DEFAULT:String = "0";
		protected static const VALUE_BOOLEAN_DEFAULT:String = VALUE_BOOLEAN_FALSE;
		protected static const VALUE_COLOR_DEFAULT:String = "#000000";
		protected static const VALUE_DATETIME_DEFAULT:String = "1980-01-01T00:00:00-06:00";

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
		protected var _name:String;
		protected var values:ValueGroup;									// Main group
		protected var currentLanguages:Vector.<String>;						// Current language chain, e.g. ["en", "en-us"]

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StringList(__name:String = "") {
			_name = __name;

			values = new ValueGroup();
			setCurrentLanguages("en");

			StringList.addList(this);
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		{
			lists = new Vector.<StringList>();
		}

		protected static function addList(__list:StringList):void {
			if (lists.indexOf(__list) == -1) {
				lists.push(__list);
			}
		}

		protected static function removeList(__list:StringList):void {
			if (lists.indexOf(__list) != -1) {
				lists.splice(lists.indexOf(__list), 1);
			}
		}

		public static function getList(__name:String = "", __canCreate:Boolean = true):StringList {
			var i:int;
			for (i = 0; i < lists.length; i++) {
				if (lists[i].name == __name) return lists[i];
			}

			// Not found
			if (__canCreate) {
				// Create a new, empty list
				return new StringList(__name);
			}

			// Error
			return null;
		}

		protected static function getXMLAsItem(__item:XML):ValueNode {
			// Converts XML data to a value node
			var newItem:ValueNode;
			var i:int;
			var nodeName:String = StringUtils.getCleanString(__item.name());

			// Set the value's content
			switch (nodeName) {
				case TYPE_STRING:
				case TYPE_NUMBER:
				case TYPE_BOOLEAN:
				case TYPE_COLOR:
				case TYPE_DATETIME:
					// String-based values are stored as string
					newItem = new ValueString();
					newItem.type = nodeName;
					(newItem as ValueString).value = StringUtils.getCleanString(__item.toString());
					break;
				case TYPE_STRING_ARRAY:
				case TYPE_NUMBER_ARRAY:
				case TYPE_BOOLEAN_ARRAY:
				case TYPE_COLOR_ARRAY:
				case TYPE_DATETIME_ARRAY:
					// Array-based values are stored as a list of strings
					newItem = new ValueArray();
					newItem.type = nodeName;
					var subItems:XMLList = __item.child(TYPE_ITEM);
					for (i = 0; i < subItems.length(); i++) {
						(newItem as ValueArray).items.push(StringUtils.getCleanString((subItems[i] as XML).toString()));
					}
					break;
				case TYPE_DATA:
					// Data values are stored as its XML source
					newItem = new ValueXML();
					(newItem as ValueXML).value = __item;
					break;
				case TYPE_GROUP:
					// Groups (with subitems) are stored as a special type
					newItem = getXMLListAsGroup(__item.children());
					break;
				default:
					trace ("StringList :: Error parsing string node of type ["+String(__item.name())+"]");
					return null;
			}

			// Sets the value's name
			newItem.name = StringUtils.getCleanString(__item.attribute("name"));

			// Sets the value's languages
			var itemLang:String = StringUtils.getCleanString(__item.attribute("language"));
			if (Boolean(itemLang)> 0) {
				var langs:Array = itemLang.split(LANGUAGE_LIST_SEPARATOR);
				for (i = 0; i < langs.length; i++) {
					newItem.languages.push(StringUtils.getCleanString(langs[i]));
				}
			}

			return newItem;
		}

		protected static function getXMLListAsGroup(__items:XMLList):ValueGroup {
			// Converts XML data to a value group
			var newGroup:ValueGroup = new ValueGroup();
			newGroup.type = TYPE_GROUP; // This is a little bit redundant but consistent with how other types are treated
			var i:int;
			for (i = 0; i < __items.length(); i++) {
				newGroup.items.push(getXMLAsItem(__items[i]));
			}
			return newGroup;
		}

		protected static function convertStringToType(__string:String, __type:String):* {
			// Converts a string-based value to its specific value
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

		protected static function convertStringArrayToType(__strings:Vector.<String>, __type:String):* {
			// Converts a string-based array to its specific value array
			var lst:Object;
			var itemType:String;
			var i:int;

			switch(__type) {
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
					trace ("StringList :: Error trying to convert array to node of type ["+String(__type)+"]");
					return null;
			}

			for (i = 0; i < __strings.length; i++) {
				lst["push"](convertStringToType(__strings[i], itemType));
			}

			return lst;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function getProcessedStringInternal(__string:String, __languages:Vector.<String>):String {
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

			return StringUtils.getCleanString(newString);
		}

		protected function getProcessedStringArrayInternal(__strings:Vector.<String>, __languages:Vector.<String>):Vector.<String> {
			var i:int;
			var newStrings:Vector.<String> = new Vector.<String>();

			for (i = 0; i < __strings.length; i++) {
				newStrings.push(getProcessedStringInternal(__strings[i], __languages));
			}

			return newStrings;
		}

		protected function getValue(__id:String, __languages:Array):* {
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
				langsToUse = getCurrentLanguages();
			}

			var node:ValueNode = values.getValueNodeByNames(names, langsToUse);

			// Sets data depending on type

			if (node is ValueString) {
				// Any standard string node
				return convertStringToType(getProcessedStringInternal((node as ValueString).value, langsToUse), node.type);
			} else if (node is ValueArray)  {
				// Any array node
				return convertStringArrayToType(getProcessedStringArrayInternal((node as ValueArray).items, langsToUse), node.type);
			} else if (node is ValueXML) {
				// Any XML node
				return (node as ValueXML).value;
			} else if (!Boolean(node)) {
				// Not found at all
				return null;
			}

			trace ("StringList :: Error trying to read node [" + node + "] of type ["+node.type+"]");
			return null;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setFromXML(__xml:XML):void {
			values.add(getXMLListAsGroup(__xml.children()));
			// TODO: read string data replacing unix/windows line feed?
		}

		public function setCurrentLanguages(... __languages):void {
			currentLanguages = new Vector.<String>();
			for (var i:int = 0; i < __languages.length; i++) {
				currentLanguages.push(__languages[i]);
			}

			dispatchEvent(new StringListEvent(StringListEvent.CHANGED_LANGUAGE));
		}

		public function getCurrentLanguages():Vector.<String> {
			return currentLanguages.concat();
		}

//		public function setString(__id:String, __value:String):void {
//			var vs:ValueString = new ValueString();
//			vs.name = __id;
//			vs.value = __value;
//			vs.type = TYPE_STRING;
//
//			var vg:ValueGroup = new ValueGroup();
//			vg.items.push(vs);
//
//			values.add(vg);
//		}

		public function getString(__id:String, ... __languages):String {
			return getValue(__id, __languages);
		}

		public function getNumber(__id:String, ... __languages):Number {
			return getValue(__id, __languages);
		}

		public function getBoolean(__id:String, ... __languages):Boolean {
			return getValue(__id, __languages);
		}

		public function getColor(__id:String, ... __languages):uint {
			return getValue(__id, __languages);
		}

		public function getXML(__id:String, ... __languages):XML {
			return getValue(__id, __languages);
		}

		public function getProcessedString(__text:String, ... __languages):String {
			var langsToUse:Vector.<String>;
			var i:int;
			if (Boolean(__languages) && __languages.length > 0) {
				langsToUse = new Vector.<String>();
				for (i = 0; i < __languages.length; i++) langsToUse.push(__languages[i]);
			} else {
				langsToUse = getCurrentLanguages();
			}

			return getProcessedStringInternal(__text, langsToUse);
		}

		public function getStringArray(__id:String, ... __languages):Vector.<String> {
			return getValue(__id, __languages);
		}

		public function getNumberArray(__id:String, ... __languages):Vector.<Number> {
			return getValue(__id, __languages);
		}

		public function getBooleanArray(__id:String, ... __languages):Vector.<Boolean> {
			return getValue(__id, __languages);
		}

		public function getColorArray(__id:String, ... __languages):Vector.<uint> {
			return getValue(__id, __languages);
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get name():String {
			return _name;
		}
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

		var i:int, j:int;
		var itemAdded:Boolean;

		// Check every item first
		for (i = 0; i < __strings.items.length; i++) {

			itemAdded = false;

			for (j = 0; j < items.length; j++) {
				if (items[j].name == __strings.items[i].name) {
					// Item already exists
					if (items[j] is ValueGroup && __strings.items[i] is ValueGroup) {
						// It's a group, merge it
						(items[j] as ValueGroup).add((__strings.items[i] as ValueGroup));
					} else {
						// It's a data item, overwrite it
						items[j] = __strings.items[i];
					}
					itemAdded = true;
					break;
				}
			}
			if (!itemAdded) {
				// Item doesn't exist, add it
				items.push(__strings.items[i]);
			}
		}

		//Log.echo("Strings has " + items.length + "items!");
	}

	// Public functions
	public function getValueNodeByNames(__names:Vector.<String>, __languages:Vector.<String>):ValueNode {
		// Returns a value given its name path and languages
		// Same as StringList.getValue(), but with pre-processed parameters (split)

		var i:int, j:int;

		// Looks for the string in all languages, one at a time
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

		// Not found, try to find a value with no language
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