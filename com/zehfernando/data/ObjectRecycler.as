package com.zehfernando.data {
	import com.zehfernando.utils.console.error;
	/**
	 * @author zeh fernando
	 */
	public class ObjectRecycler {

		// Individual objects in a pool; can be marked as used and keys can be repeated

		private var objects:Array;
		private var objectUsed:Vector.<Boolean>;
		private var objectKeys:Vector.<String>;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ObjectRecycler() {
			objects = [];
			objectUsed = new Vector.<Boolean>();
			objectKeys = new Vector.<String>();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function has(__key:String):Boolean {
			// Checks whether an object exists and is available
			var idx:int;
			idx = objectKeys.indexOf(__key);
			while (idx > -1) {
				if (!objectUsed[idx]) return true;
				idx = objectKeys.indexOf(__key, idx+1);
			}

			// Not found!
			return false;
		}

		public function get(__key:String):* {
			// Returns an object
			var idx:int;
			idx = objectKeys.indexOf(__key);
			while (idx > -1) {
				if (!objectUsed[idx]) {
					// Object is not used
					objectUsed[idx] = true;
					return objects[idx];
				}
				idx = objectKeys.indexOf(__key, idx+1);
			}

			// Not found!
			return null;
		}

		public function putNew(__key:String, __object:*):void {
			// Put a new object
			objectUsed.push(false);
			objectKeys.push(__key);
			objects.push(__object);
		}

		public function putBack(__object:*):void {
			// Put an object back in the pool
			var idx:int;
			idx = objects.indexOf(__object);
			if (idx > -1) {
				if (objectUsed[idx]) {
					objects[idx] = __object;
					objectUsed[idx] = false;
				} else {
					error("Error! Tried putting back an object that was not used!");
				}
			}
		}

		public function remove(__object:*):void {
			// Delete an object
			var idx:int;
			idx = objects.indexOf(__object);
			if (idx > -1) {
				objects.splice(idx, 1);
				objectUsed.splice(idx, 1);
				objectKeys.splice(idx, 1);
			}
		}

		public function clear():void {
			objects.length = 0;
			objectUsed.length = 0;
			objectKeys.length = 0;
		}

		public function getNumObjectsFree():int {
			var numObjectsFree:int = 0;
			for (var i:int = 0; i < objectUsed.length; i++) {
				if (!objectUsed[i]) numObjectsFree++;
			}
			return numObjectsFree;
		}

		public function getNumObjects():int {
			return objects.length;
		}

		public function getObjectIds():Vector.<String> {
			// Debug function
			var obj:Object = {};
			var objUsed:Object = {};
			var key:String;
			var i:int;
			for (i = 0; i < objects.length; i++) {
				key = objectKeys[i];
				if (!obj.hasOwnProperty(key)) obj[key] = 0;
				if (!objUsed.hasOwnProperty(key)) objUsed[key] = 0;

				obj[key]++;
				if (objectUsed[i]) objUsed[key]++;
			}

			var strings:Vector.<String> = new Vector.<String>();
			for (var iis:String in obj) {
				strings.push(iis.split("\n").join("\\n").split("\r").join("\\r") + " (" + objUsed[iis] + " used / " + obj[iis] + " total)");
			}
			strings.sort(Array.CASEINSENSITIVE);
			return strings;
		}

		public function getOjectAt(__index:int):* {
			return objects[__index];
		}
	}
}
