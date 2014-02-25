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
	}
}
