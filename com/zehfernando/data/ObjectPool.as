package com.zehfernando.data {
	/**
	 * @author zeh fernando
	 */
	public class ObjectPool {

		private var objects:Array;
		private var objectsUsed:Vector.<Boolean>;

		private var numObjectsFree:int;

		public var create:Function;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ObjectPool() {
			objects = [];
			objectsUsed = new Vector.<Boolean>();
			numObjectsFree = 0;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function get():* {
			// Returns an unused object from the existing pool, or creating a new if none is available
			if (numObjectsFree == 0) {
				// No objects free, create a new one
				if (create != null) {
					var obj:* = create();
					objects.push(obj);
					objectsUsed.push(true);
					return obj;
				} else {
					return null;
				}
			} else {
				// Find first unused object
				for (var i:int = 0; i < objectsUsed.length; i++) {
					if (!objectsUsed[i]) {
						// This is not used
						objectsUsed[i] = true;
						numObjectsFree--;
						return objects[i];
					}
				}
			}
			return null;
		}

		public function put(__object:*):void {
			// Put an object back in the pool
			var index:int = objects.indexOf(__object);
			if (index > -1) {
				// Object is in the pool, just put it back
				objectsUsed[index] = false;
				numObjectsFree++;
			} else {
				// Object is not in the pool yet, add it
				objects.push(__object);
				objectsUsed.push(false);
				numObjectsFree++;
			}
		}

		public function clear():void {
			objects.length = 0;
			objectsUsed.length = 0;
			numObjectsFree = 0;
		}

		public function getNumObjectsFree():int {
			return numObjectsFree;
		}

		public function getNumObjects():int {
			return objects.length;
		}

	}
}