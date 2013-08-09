package com.zehfernando.localization {
	/**
	 * @author zeh fernando
	 */
	public class StringResources {

		// Localization class for Strings only

/*
		{
			"id" : "value",
			"group" : {
				"id" : "value"
			}
		}

		Use:
		getString("id");
		getString("group.id");
*/

		// Constants
		public static const ID_HYERARCHY_SEPARATOR:String = ".";

		// Static properties
		private static var instances:Vector.<StringResources>;

		// Default values
		private static const VALUE_STRING_DEFAULT:String = "[null]";

		// Properties
		private var _name:String;
		private var values:Object;									// From a JSON object


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StringResources(__name:String = "") {
			_name = __name;

			values = {};

			StringResources.addInstance(this);
		}


		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		{
			instances = new Vector.<StringResources>();
		}

		protected static function addInstance(__instance:StringResources):void {
			if (instances.indexOf(__instance) == -1) {
				instances.push(__instance);
			}
		}

		protected static function removeList(__instance:StringResources):void {
			if (instances.indexOf(__instance) != -1) {
				instances.splice(instances.indexOf(__instance), 1);
			}
		}

		public static function getList(__name:String = "", __canCreate:Boolean = true):StringResources {
			var i:int;
			for (i = 0; i < instances.length; i++) {
				if (instances[i].name == __name) return instances[i];
			}

			// Not found

			// If allowed, creates a new, empty list
			if (__canCreate) return new StringResources(__name);

			// Error
			return null;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function getProcessedStringInternal(__string:String):String {
			// Returns a string with processed codes
			// For example "this is an ${examples/example}!" returns "this is an EXAMPLE!" (where the value of examples.example in strings.json is "EXAMPLE")

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
				newString += getString(result[1]);

				lastIndex = codes.lastIndex;

				result = codes.exec(__string);
			}

			// End text after last tag
			newString += __string.substring(lastIndex, __string.length);

			return newString;
		}

		private function getStringInternal(__id:String):String {

			// Get the full path to the value name
			var ids:Array = __id.split(ID_HYERARCHY_SEPARATOR);
			var i:int;

			var result:String = null;
			var obj:Object = values;
			for (i = 0; i < ids.length; i++) {
				if (obj.hasOwnProperty(ids[i])) {
					obj = obj[ids[i]];
				} else {
					trace("StringResources :: String [" + __id + "] doesn't exist!");
					obj = VALUE_STRING_DEFAULT;
					break;
				}
			}

			if (obj != null) result = obj as String;

			return result;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setValues(__object:Object):void {
			// Set the values; __object must be a JSON-like object
			values  = __object;
			// TODO: read string data replacing unix/windows line feed?
		}

		public function getString(__id:String):String {
			return getStringInternal(__id);
		}

		public function getProcessedString(__text:String):String {
			return getProcessedStringInternal(__text);
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get name():String {
			return _name;
		}
	}
}
