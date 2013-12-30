package com.zehfernando.ld27.starling.templates {
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	import com.zehfernando.data.starling.TextureBank;

	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class ShapeSprite extends Sprite {

		// A Starling Sprite based on a flash sprite, with customizable site and quality

		// Properties
		private var _width:Number;
		private var _height:Number;

		// Instances
		private var image:Image;

		private var _symbolRectRaw:Rectangle;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ShapeSprite(__class:Class, __worldScale:Number = 1, __quality:Number = 1, __colorTransform:ColorTransform = null, __filters:Array = null, __safetyMargin:Number = 0) {
			// An easier template to create sprites from symbols

			// "Quality" is the texture resolution, based on the original shape size. can be higher than 1!
			// "world scale" is the scale for the symbol (otherwise symbol size is in world units)
			createImage(__class, __worldScale, __quality, __colorTransform, __filters, __safetyMargin);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function createImage(__class:Class, __worldScale:Number, __quality:Number, __colorTransform:ColorTransform, __filters:Array, __safetyMargin:Number):void {
			// Creates bitmap copy
			var symbol:flash.display.Sprite = new (__class as Class)();

			var symbolRect:Rectangle = symbol.getBounds(symbol);
			_symbolRectRaw = symbol.getRect(symbol);

			// Adds the final bitmap to the display
			var textureKey:String = "shape_" + __class + "_" + __quality + "_" + __worldScale + "_" + __safetyMargin + "_" + __colorTransform;
			var texture:Texture;
			if (TextureBank.has(textureKey)) {
				// Texture already exists, so just reuse it
				texture = TextureBank.get(textureKey);
			} else {
				// Texture doesn't exist, does all the necessary resizing

				// Creates bitmap for the sprite
				var bw:Number = Math.round((symbolRect.width + __safetyMargin * 2) * __quality);
				var bh:Number = Math.round((symbolRect.height + __safetyMargin * 2) * __quality);

				// Paints the texture
				var transferMatrix:Matrix = new Matrix();
				transferMatrix.translate(__safetyMargin, __safetyMargin);
				transferMatrix.translate(-symbolRect.x, -symbolRect.y);
				transferMatrix.scale(__quality, __quality);

				var finalBitmap:BitmapData = new BitmapData(bw, bh, true, LD27.DEBUG_DRAW_SPRITE_BOUNDS ? 0x33ff0000 : 0x00000000);
				finalBitmap.draw(symbol, transferMatrix, __colorTransform, null, null, true);

				// TODO: might need to add properties about the filters to the key string otherwise it will reuse the same images and ignore filters
				if (__filters != null) {
					// Applies filters to the image if desired before flattening
					var i:int;
					for (i = 0; i < __filters.length; i++) {
						finalBitmap.applyFilter(finalBitmap, finalBitmap.rect, new Point(0, 0), __filters[i]);
					}
				}

				// Creates texture
				texture = Texture.fromBitmapData(finalBitmap, true, true);
				TextureBank.put(textureKey, texture);

				// Trash everything
				finalBitmap.dispose();

			}
			image = new Image(texture);
			image.x = symbolRect.x - __safetyMargin;
			image.y = symbolRect.y - __safetyMargin;
			addChild(image);

			// Sets visual properties
			scaleX = __worldScale / __quality;
			scaleY = __worldScale / __quality;

			_width = symbol.width * __worldScale;
			_height = symbol.height * __worldScale;

			// End
			//if (__flatten) flatten();
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
			image.scaleX = __value / _width;
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			image.scaleY = __value / _height;
		}

		public function get symbolRectRaw():Rectangle {
			return _symbolRectRaw;
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
