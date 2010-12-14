package com.zehfernando.display {

	import com.zehfernando.display.abstracts.ResizableSprite;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	/**
	 * @author zeh
	 */
	public class BitmapFillBox extends ResizableSprite {
		
		// Instances
		protected var bitmapData:BitmapData;
		protected var bitmap:Bitmap;
		
		protected var source:BitmapData;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BitmapFillBox() {
			super();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth(): void {
			redraw();
		}

		override protected function redrawHeight(): void {
			redraw();
		}
		
		protected function redraw(): void {
			removeBitmap();
			
			if (Boolean(source)) {
				
				var w:Number = Math.round(_width);
				var h:Number = Math.round(_height);
				
				var i:int, j:int;
			
				bitmapData = new BitmapData (w, h, true, 0x00000000);
				for (i = 0; i < w; i += source.width) {
					for (j = 0; j < h; j += source.height) {
						bitmapData.copyPixels(source, source.rect, new Point(i, j));
					}
				}
			
				bitmap = new Bitmap(bitmapData);
				addChild(bitmap);
			}
		}
		
		protected function removeBitmap(): void {
			if (Boolean(bitmap)) {
				removeChild(bitmap);
				bitmap.bitmapData = null;
				bitmap = null;
			}
				
			if (Boolean(bitmapData)) {
				bitmapData.dispose();
				bitmapData = null;
			}
		}
		
		protected function removeSource(): void {
			if (Boolean(source)) {
				source.dispose();
				source = null;
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setBitmap(__bitmap:Bitmap):void {
			removeSource();
			
			source = __bitmap.bitmapData.clone();
			
			__bitmap.bitmapData.dispose();
			
			redraw();
		}
		
		public function dispose(): void {
			removeBitmap();
			removeSource();
		}
	}
}
