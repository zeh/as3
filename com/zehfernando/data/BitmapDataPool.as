package com.zehfernando.data {
	import com.zehfernando.utils.console.warn;

	import flash.display.BitmapData;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class BitmapDataPool {

		// Properties
		private var _name:String;

		// Instances
		private var availableBitmaps:Vector.<BitmapData>;
		private var usedBitmaps:Vector.<BitmapData>;

		// Static properties
		private static var pools:Vector.<BitmapDataPool>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BitmapDataPool(__name:String = "") {
			_name = __name;
			availableBitmaps = new Vector.<BitmapData>();
			usedBitmaps = new Vector.<BitmapData>();

			addPool(this);
		}


		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		{
			pools = new Vector.<BitmapDataPool>();
		}

		protected static function addPool(__pool:BitmapDataPool):void {
			if (pools.indexOf(__pool) == -1) {
				pools.push(__pool);
			}
		}

		protected static function removePool(__pool:BitmapDataPool):void {
			if (pools.indexOf(__pool) != -1) {
				pools.splice(pools.indexOf(__pool), 1);
			}
		}

		public static function getPool(__name:String = "", __canCreate:Boolean = true):BitmapDataPool {
			var i:int;
			for (i = 0; i < pools.length; i++) {
				if (pools[i].name == __name) return pools[i];
			}

			// Not found
			if (__canCreate) {
				// Create a new, empty list
				return new BitmapDataPool(__name);
			}

			// Error
			return null;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function get(__width:int, __height:int, __transparent:Boolean = false, __fillColor:uint = 0x00000000):BitmapData {
			// Search for a valid bitmapdata
			//log("Borrowing a bitmap of "+__width+"x"+__height);
			var i:int;
			var bmp:BitmapData;
			for (i = 0; i < availableBitmaps.length; i++) {
				if (availableBitmaps[i].width == __width && availableBitmaps[i].height == __height && availableBitmaps[i].transparent == __transparent) {
					usedBitmaps.push(availableBitmaps[i]);
					availableBitmaps.splice(i, 1);

					//log("-->      Used bitmaps: " + usedBitmaps.length);
					//log("--> Available bitmaps: " + availableBitmaps.length);

					bmp = usedBitmaps[usedBitmaps.length-1];

					bmp.fillRect(bmp.rect, __fillColor);

					return bmp;
				}
			}

			//log("  Doesn't exist, need to create first");

			// No valid bitmapdata found, create a new one
			bmp = new BitmapData(__width, __height, __transparent, __fillColor);
			usedBitmaps.push(bmp);

			//log("-->      Used bitmaps: " + usedBitmaps.length);
			//log("--> Available bitmaps: " + availableBitmaps.length);

			return bmp;
		}

		public function put(__bitmap:BitmapData):void {
			var i:int = usedBitmaps.indexOf(__bitmap);

			//log ("returning bitmap of "+__bitmap.width+"x"+__bitmap.height);

			if (i < 0) {
				warn("BitmapData being returned is not listed as used: will dispose of it instead");
				__bitmap.dispose();
			} else {
				availableBitmaps.push(usedBitmaps[i]);
				usedBitmaps.splice(i, 1);
			}

			//log("-->      Used bitmaps: " + usedBitmaps.length);
			//log("--> Available bitmaps: " + availableBitmaps.length);
		}

		public function clean(__aggressive:Boolean = false):void {
			// Removes everything in a non-destructive way (allows borrowed objects to still be used, and upon returning they're disposed of)

			// If aggressive, disposes of all unused objects immediately - effect is the same, but aggressive mode may clear memory earlier
			if (__aggressive) {
				for (var i:int = 0; i < availableBitmaps.length; i++) {
					availableBitmaps[i].dispose();
				}
			}

			availableBitmaps.length = 0;
			usedBitmaps.length = 0;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get name():String {
			return _name;
		}

		public function getNumAvailableBitmaps():uint {
			return availableBitmaps.length;
		}

		public function getNumUsedBitmaps():uint {
			return usedBitmaps.length;
		}

		// Static

		public static function getNumPools():uint {
			return pools.length;
		}

		public static function getNumUsedBitmaps():uint {
			var total:uint = 0;
			for (var i:int = 0; i < pools.length; i++) total += pools[i].getNumUsedBitmaps();
			return total;
		}

		public static function getNumAvailableBitmaps():uint {
			var total:uint = 0;
			for (var i:int = 0; i < pools.length; i++) total += pools[i].getNumAvailableBitmaps();
			return total;
		}
	}
}
