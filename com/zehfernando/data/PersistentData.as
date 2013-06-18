package com.zehfernando.data {
	import flash.net.SharedObject;
	/**
	 * @author zeh fernando
	 */
	public class PersistentData {
		// A proxy class for SharedObject with a simpler API

		// Constant properties
		private static var datas:Vector.<PersistentData>;

		// Properties
		private var _name:String;
		private var sharedObject:SharedObject;

		// TODO:
		// * Initialize from XML
		// * Allow "defaults"

		// ================================================================================================================
		// STATIC ---------------------------------------------------------------------------------------------------------

		{
			datas = new Vector.<PersistentData>();
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function PersistentData(__name:String) {
			_name = __name;
			PersistentData.addInstance(this);
			sharedObject = SharedObject.getLocal("persistentData_" + __name);
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		private static function addInstance(__data:PersistentData):void {
			datas.push(__data);
		}

		public static function getInstance(__name:String = ""):PersistentData {
			// TODO: use hashmap for speed?

			// Looks for one on the list first
			for (var i:int = 0; i < datas.length; i++) {
				if (datas[i].name == __name) return datas[i];
			}

			// Doesn't exist, create a new one and return it
			return new PersistentData(__name);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function clear():void {
			sharedObject.clear();
			sharedObject.flush();
		}

		public function get(__key:String, __default:* = null):* {
			if (hasProperty(__key)) {
				// Has the data
				return sharedObject.data[__key];
			}
			// Doesn't have the data, use default
			return __default;
		}

		public function set(__key:String, __value:*):void {
			sharedObject.data[__key] = __value;
			sharedObject.flush();
		}

		public function getAsBoolean(__key:String, __default:Boolean = false):Boolean {
			return get(__key, __default);
		}

		public function getAsString(__key:String, __default:String = ""):String {
			return get(__key, __default);
		}

		public function getAsNumber(__key:String, __default:Number = 0):Number {
			return get(__key, __default);
		}

		/*
		public void putJSONArray(String __key, JSONArray __array) {
			SharedPreferences.Editor editor = preferences.edit();
			editor.putString(__key, __array.toString());
			//F.log("====> SAVING ARRAY! " + __array.toString());
			editor.commit();
		}

		public JSONArray getJSONArray(String __key) {
			try {
				//F.log("===> READING ARRAY! " + preferences.getString(__key, ""));
				return new JSONArray(preferences.getString(__key, ""));
			} catch (JSONException __e) {
				F.warn("CANNOT READ JSON ARRAY!");
				return new JSONArray();
			}
		}
		*/

		public function remove(__key:String):Boolean {
			if (hasProperty(__key)) {
				delete sharedObject.data[__key];
				return true;
			} else {
				return false;
			}
		}

		public function hasProperty(__key:String):Boolean {
			return sharedObject.data.hasOwnProperty(__key);
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get name():String {
			return _name;
		}
	}
}