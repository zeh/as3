package com.zehfernando.ld27.starling.templates {

	import starling.display.Image;
	import starling.display.Sprite;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class ImageSprite extends Sprite {

		// A Starling Sprite based on a bitmap, with customizable site and quality

		// Properties
		private var _width:Number;
		private var _height:Number;

		// Instances
		private var image:Image;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ImageSprite(__class:Class, __quality:Number, __width:int = -1, __height:int = -1) {
			// An easier template to create sprites from bitmaps
			// Class is is the bitmap reference; quality is divider (1 = normal, 0.5 = half quality). The size is always maintained
			createImage(__class, __quality, __width, __height);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function createImage(__class:Class, __quality:Number, __width:int, __height:int):void {
			// Creates original bitmap
			var imageBitmap:Bitmap = new (__class as Class)();

			var desiredWidth:int = __width <= 0 ? imageBitmap.width : __width;
			var desiredHeight:int = __height <= 0 ? imageBitmap.height : __height;

			// Creates final bitmap for the texture
			var bw:Number = Math.round(desiredWidth * __quality);
			var bh:Number = Math.round(desiredHeight * __quality);

			// Paints the texture
			var transferMatrix:Matrix = new Matrix();
			transferMatrix.scale(bw / imageBitmap.width, bh / imageBitmap.height);

			var finalBitmap:BitmapData = new BitmapData(bw, bh, true, 0x00000000);
			finalBitmap.draw(imageBitmap, transferMatrix, null, null, null, true);

			// Finally adds the final bitmap to the display
			image = Image.fromBitmap(new Bitmap(finalBitmap));
			//image.smoothing
			addChild(image);

			// Sets visual properties
			scaleX = desiredWidth / bw;
			scaleY = desiredHeight / bh;

			_width = desiredWidth;
			_height = desiredHeight;

			// Trash everything
			finalBitmap.dispose();

			// End
			flatten();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function dispose():void {
			removeChild(image);
			image.dispose();
			image = null;

			super.dispose();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Overrides default values so it's controlled somewhere else

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				scaleX = _width / image.width;
			}
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				scaleY = _height / image.height;
			}
		}

		public function get color():uint {
			return image.color;
		}
		public function set color(__value:uint):void {
			if (image.color != __value) {
				image.color = __value;
				flatten();
			}
		}
	}
}
