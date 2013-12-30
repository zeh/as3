package com.zehfernando.display.starling {
	import starling.display.Image;
	import starling.textures.Texture;

	import com.zehfernando.utils.MathUtils;

	import flash.geom.Rectangle;
	/**
	 * @author zeh fernando
	 */
	public class ClipImage extends Image {

		// Instances
		private var clipRect:Rectangle;
		private var bounds:Rectangle;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ClipImage(__texture:Texture) {
			super(__texture);

			clipRect = null;
			bounds = new Rectangle(super.x, super.y, super.width, super.height);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function adjustDimensions():void {
			// Based on the bounds and clip rect, adjust position and texture mappings

			if (clipRect == null) {
				// No clipping
				super.x = bounds.x;
				super.y = bounds.y;
				super.width = bounds.width;
				super.height = bounds.height;

				setTexCoordsTo(0, 0, 0);
				setTexCoordsTo(1, 1, 0);
				setTexCoordsTo(2, 0, 1);
				setTexCoordsTo(3, 1, 1);
			} else {
				// Clips

				super.x = Math.max(bounds.left, clipRect.left);
				super.y = clipRect.top;
				//super.y = Math.max(bounds.top, clipRect.top);
				super.width = Math.min(bounds.right, clipRect.right) - super.x;
				super.height = Math.min(bounds.bottom, clipRect.bottom) - super.y;

				// Adjust maps
				var l:Number = MathUtils.map(super.x, bounds.left, bounds.right, 0, 1);
				var r:Number = MathUtils.map(super.x + super.width, bounds.left, bounds.right, 0, 1);
				var t:Number = MathUtils.map(super.y, bounds.top, bounds.bottom, 0, 1);
				var b:Number = MathUtils.map(super.y + super.height, bounds.top, bounds.bottom, 0, 1);

				setTexCoordsTo(0, l, t);
				setTexCoordsTo(1, r, t);
				setTexCoordsTo(2, l, b);
				setTexCoordsTo(3, r, b);
			}
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setClipRect(__rect:Rectangle):void {
			clipRect = __rect;
			adjustDimensions();
		}

		override public function dispose():void {
			super.dispose();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function set x(__value:Number):void {
			if (bounds.x != __value) {
				bounds.x = __value;
				adjustDimensions();
			}
		}

		override public function set y(__value:Number):void {
			if (bounds.y != __value) {
				bounds.y = __value;
				adjustDimensions();
			}
		}

		override public function set width(__value:Number):void {
			if (bounds.width != __value) {
				bounds.width = __value;
				adjustDimensions();
			}
		}

		override public function set height(__value:Number):void {
			if (bounds.height != __value) {
				bounds.height = __value;
				adjustDimensions();
			}
		}
	}
}
