package com.zehfernando.data {
	import flash.utils.Dictionary;
	/**
	 * @author zeh fernando
	 */
	public class ObjectPoolStatic {

		// Properties
		private static var lists:Dictionary;

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		{
			reset();
		}

		public static function reset():void {
			lists = new Dictionary(false);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private static function getList(__class:Class):ObjectList {
			var objectList:ObjectList = lists[__class];
			if (objectList == null) {
				// Doesn't exist yet
				objectList = new ObjectList(__class);
				lists[__class] = objectList;
			}
			return objectList;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function get(__class:Class):* {
			return getList(__class).get();
		}

		public static function put(__class:Class, __object:*):void {
			getList(__class).put(__object);
		}

		// For debugging purposes
		public static function getNumObjects(__class:Class = null):Number {
			if (__class == null) {
				// All objects
				var c:Number = 0;
				for (var ii:* in lists) {
					c += getList(ii).getNumObjects();
				}
				return c;
			} else {
				// One specific object
				return getList(__class).getNumObjects();
			}
		}

		public static function getNumObjectsFree(__class:Class = null):Number {
			if (__class == null) {
				// All objects
				var c:Number = 0;
				for (var ii:* in lists) {
					c += getList(ii).getNumObjectsFree();
				}
				return c;
			} else {
				// One specific object
				return getList(__class).getNumObjectsFree();
			}
		}

	}

}
import com.zehfernando.utils.console.warn;
class ObjectList {

	private var _class:Class;
	private var objects:Array;
	private var objectsUsed:Vector.<Boolean>;

	private var numObjectsFree:int;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function ObjectList(__class:Class) {
		_class = __class;
		objects = [];
		objectsUsed = new Vector.<Boolean>();
		numObjectsFree = 0;
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function get(): * {
		// Returns an unused object from the existing pool, or creating a new if none is available
		if (numObjectsFree == 0) {
			// No objects free, create a new one
			var obj:* = new _class();
			objects.push(obj);
			objectsUsed.push(true);
			return obj;
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
	}

	public function put(__object:*):void {
		// Put an object back in the pool
		var index:int = objects.indexOf(__object);
		if (index > -1) {
			objectsUsed[index] = false;
			numObjectsFree++;
		} else {
			warn("Trying to put an object [" + __object + "] back into a pool of [" + _class + "] where it doesn't exist");
		}
	}

	public function getNumObjectsFree():int {
		return numObjectsFree;
	}

	public function getNumObjects():int {
		return objects.length;
	}

}
