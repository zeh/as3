package com.zehfernando.display {

	import com.zehfernando.utils.console.error;
	import com.zehfernando.utils.console.log;
	import com.zehfernando.utils.console.logOff;

	import flash.display.BitmapData;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class BitmapPoll {

		// Instances
		protected var availableBitmaps:Vector.<BitmapData>;
		protected var usedBitmaps:Vector.<BitmapData>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BitmapPoll() {
			availableBitmaps = new Vector.<BitmapData>();
			usedBitmaps = new Vector.<BitmapData>();

			logOff();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function borrowBitmap(__width:int, __height:int, __transparent:Boolean = false):BitmapData {
			// Search for a valid bitmapdata
			log("Borrowing a bitmap of "+__width+"x"+__height);
			var i:int;
			for (i = 0; i < availableBitmaps.length; i++) {
				if (availableBitmaps[i].width == __width && availableBitmaps[i].height == __height && availableBitmaps[i].transparent == __transparent) {
					usedBitmaps.push(availableBitmaps[i]);
					availableBitmaps.splice(i, 1);

					log("-->      Used bitmaps: " + usedBitmaps.length);
					log("--> Available bitmaps: " + availableBitmaps.length);

					return usedBitmaps[usedBitmaps.length-1];
				}
			}

			log("  Doesn't exist, need to create first");

			// No valid bitmapdata found, create a new one
			var bmp:BitmapData = new BitmapData(__width, __height, __transparent, 0x00000000);
			usedBitmaps.push(bmp);

			log("-->      Used bitmaps: " + usedBitmaps.length);
			log("--> Available bitmaps: " + availableBitmaps.length);

			return bmp;
		}

		public function returnBitmap(__bitmap:BitmapData): void {
			var i:int = usedBitmaps.indexOf(__bitmap);

			log ("returning bitmap of "+__bitmap.width+"x"+__bitmap.height);

			if (i < 0) {
				error("BitmapData being returned is not listed as used!!");
			} else {
				availableBitmaps.push(usedBitmaps[i]);
				usedBitmaps.splice(i, 1);
			}

			log("-->      Used bitmaps: " + usedBitmaps.length);
			log("--> Available bitmaps: " + availableBitmaps.length);
		}
	}
}
