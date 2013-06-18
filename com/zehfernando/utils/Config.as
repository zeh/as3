package com.zehfernando.utils {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class Config {

		// Static properties
		protected static var defaultOptions:Object;					// List of DefaultListOption
		protected static var inited:Boolean;

		[Embed(source='/../embedded/config.xml',mimeType='application/octet-stream')]
		protected static var ConfigXML:Class;
		// TODO: make the config XML a separate XML that is loaded externally

		protected static var eventDispatcher:EventDispatcher;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Config() {
			throw new Error("Instantiation not allowed");
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		protected static function init():void {
			if (!inited) {
				defaultOptions = {};

				eventDispatcher = new EventDispatcher();

				// Add defaults from XML
				var configXML:XML = XML(new ConfigXML());

				var i:uint;
				var options:XMLList = configXML.child("option");
				var option:XML;

				for (i = 0; i < options.length(); i++) {
					option = options[i];
					defaultOptions[String(option.attribute("id"))] = new DefaultListOption(option.toString(), option.attribute("type"));
				}

				inited = true;

			}
		}

		public static function get(__option:String): Object {
			// Try to get from the existing list, if not, get from the default
			init();
			var so:SharedObject = getSharedObject();
			if (so.data.hasOwnProperty(__option)) {
				// Has the data
				return so.data[__option];
			}
			// Doesn't have the data, use default
			return getDefault(__option);
		}

		public static function set(__option:String, __value:Object):void {
			init();
			var so:SharedObject = getSharedObject();
			so.data[__option] = __value;
			so.flush();
			eventDispatcher.dispatchEvent(new Event(Event.CHANGE));
			// TODO: check when shared object data saving is disabled?
		}

		public static function hasOption(__option:String):Boolean {
			// Whether or not an option has been set already
			init();
			var so:SharedObject = getSharedObject();
			return so.data.hasOwnProperty(__option);
		}

		protected static function getSharedObject(): SharedObject {
			return SharedObject.getLocal("config");
		}

		protected static function getDefault(__option:String): Object {
			if (defaultOptions.hasOwnProperty(__option)) {
				var dp:DefaultListOption = defaultOptions[__option];
				if (dp.type == "Number") {
					return dp.getNumber();
				} else if (dp.type == "Boolean") {
					return dp.getBoolean();
				} else {
					return dp.getString();
				}
			}
			return null;
		}

		public static function reset():void {
			init();
			var so:SharedObject = getSharedObject();
			so.clear();
			so.flush();
		}

		public static function addEventListener(__type:String, __listener:Function):void {
			eventDispatcher.addEventListener(__type, __listener);
		}

		public static function removeEventListener(__type:String, __listener:Function):void {
			eventDispatcher.removeEventListener(__type, __listener);
		}

	}
}

import flash.system.Capabilities;

// ================================================================================================================
// AUXILIARY classes ----------------------------------------------------------------------------------------------

class DefaultListOption extends Object {

	public var data:String;
	public var type:String;

	public function DefaultListOption(__data:String, __type:String) {
		data = __data;
		type = __type;
	}

	public function getBoolean():Boolean {
		return data == "true";
	}

	public function getNumber():Number {
		return parseFloat(data);
	}

	public function getString():String {
		var str:String = String(data);
		if (str == "[system-language]") {
			str = Capabilities.language;
		}
		return str;
	}

}