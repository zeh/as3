package com.zehfernando.ld27.starling.templates {
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	import com.zehfernando.data.starling.TextureBank;

	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class MovieClipSprite extends Sprite {

		// A Starling Sprite based on a flash sprite, with customizable site and quality

		// Properties
		private var _width:Number;
		private var _height:Number;

		private var currentFrame:int;
		private var _totalFrames:int;

		private var symbolClass:Class;
		private var worldScale:Number;
		private var quality:Number;
		private var colorTransform:ColorTransform;
		private var filters:Array;
		private var safetyMargin:Number;

		// Instances
		private var images:Vector.<Image>; // Images
		private var symbol:flash.display.MovieClip;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function MovieClipSprite(__class:Class, __worldScale:Number = 1, __quality:Number = 1, __colorTransform:ColorTransform = null, __filters:Array = null, __safetyMargin:Number = 0) {
			// An easier template to create sprites from symbols

			symbolClass = __class;
			worldScale = __worldScale;
			quality = __quality;
			colorTransform = __colorTransform;
			filters = __filters;
			safetyMargin = __safetyMargin;

			images = new Vector.<Image>();

			currentFrame = -1;

			// "Quality" is the texture resolution, based on the original shape size. can be higher than 1!
			// "world scale" is the scale for the symbol (otherwise symbol size is in world units)
			createImage();

			setFrame(0);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function createImage():void {
			// Creates image to be referenced later
			symbol = new (symbolClass as Class)();
			symbol.stop();
			if (Boolean(filters)) symbol.filters = filters;
			_totalFrames = symbol.totalFrames;
		}

		private function activateFrame(__frame:int):void {
			// Creates bitmap copy

			if (__frame == currentFrame) return;

			unflatten();

			if (currentFrame >= 0) {
				// Already has an image visible, hide it
				images[currentFrame].visible = false;
			}

			currentFrame = __frame;

			if (images.length > currentFrame && images[currentFrame] != null) {
				// Image frame already exists, show it
				images[currentFrame].visible = true;
				return;
			}

			// Image doesn't exist, need to create it

			symbol.gotoAndStop(currentFrame+1);
			var symbolRect:Rectangle = symbol.getBounds(symbol);

			// Adds the final bitmap to the display
			var textureKey:String = "shape_" + symbolClass + "_" + quality + "_" + worldScale + "_" + safetyMargin + "_" + currentFrame;
			var texture:Texture;
			if (TextureBank.has(textureKey)) {
				// Texture already exists, so just reuse it
				texture = TextureBank.get(textureKey);
			} else {
				// Texture doesn't exist, does all the necessary resizing

				// Creates bitmap for the sprite
				var bw:Number = Math.round((symbolRect.width + safetyMargin * 2) * quality * worldScale);
				var bh:Number = Math.round((symbolRect.height + safetyMargin * 2) * quality * worldScale);

				// Paints the texture
				var transferMatrix:Matrix = new Matrix();
				transferMatrix.translate(safetyMargin, safetyMargin);
				transferMatrix.translate(-symbolRect.x, -symbolRect.y);
				transferMatrix.scale(quality * worldScale, quality * worldScale);

				var finalBitmap:BitmapData = new BitmapData(bw, bh, true, LD27.DEBUG_DRAW_SPRITE_BOUNDS ? 0x33ff0000 : 0x00000000);
				finalBitmap.draw(symbol, transferMatrix, colorTransform, null, null, true);

				// Creates texture
				texture = Texture.fromBitmapData(finalBitmap, true, true);
				TextureBank.put(textureKey, texture);

				// Trash everything
				finalBitmap.dispose();

			}
			var image:Image = new Image(texture);
			image.x = symbolRect.x - safetyMargin;
			image.y = symbolRect.y - safetyMargin;
			addChild(image);

			for (var i:int = images.length; i < currentFrame; i++) {
				images.push(null);
			}
			images[currentFrame] = image;

			// Sets visual properties
			scaleX = 1 / quality;
			scaleY = 1 / quality;

			_width = symbol.width * worldScale;
			_height = symbol.height * worldScale;

			// End
			flatten();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setFrame(__frame:int):void {
			activateFrame(__frame);
		}

		override public function dispose():void {
			for (var i:int = 0; i < images.length; i++) {
				if (images[i] != null) {
					removeChild(images[i]);
					images[i].dispose();
					images[i] = null;
				}
			}

			super.dispose();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Overrides default values so it's controlled somewhere else

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			//image.width = __value;
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			//image.height = __value;
		}

		public function get totalFrames():int {
			return _totalFrames;
		}

//		public function get color():uint {
//			return image.color;
//		}
//		public function set color(__value:uint):void {
//			if (image.color != __value) {
//				image.color = __value;
//				flatten();
//			}
//		}
	}
}
