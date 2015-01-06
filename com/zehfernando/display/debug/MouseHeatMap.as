package com.zehfernando.display.debug {
	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.display.shapes.Box;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	/**
	 * @author zeh fernando
	 */
	public class MouseHeatMap extends ResizableSprite {

		// Properties
		private var isMouseDown:Boolean;
		private var eventsDrawn:int;
		private var density:Number;								// 1 = normal, 0.5 = half quality

		// Instances
		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;

		private var shapeMouseDown:Shape;
		private var shapeMouseUp:Shape;
		private var background:Box;

		private var matrix:Matrix;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function MouseHeatMap() {
			super();

			isMouseDown = false;
			eventsDrawn = 0;
			density = 0.5;
			matrix = new Matrix();

			shapeMouseDown = new Shape();
			shapeMouseDown.graphics.beginFill(0xff2200, 0.5);
			shapeMouseDown.graphics.drawCircle(0, 0, 10);
			shapeMouseDown.graphics.endFill();

			shapeMouseUp = new Shape();
			shapeMouseUp.graphics.beginFill(0x003399, 0.5);
			shapeMouseUp.graphics.drawCircle(0, 0, 10);
			shapeMouseUp.graphics.endFill();

			background = new Box(100, 100, 0xffffff);
			background.alpha = 0.75;
			addChild(background);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			if (bitmapData != null && bitmapData.width != getDesiredWidth()) recreateBitmapData();
			background.width = _width;
		}

		override protected function redrawHeight():void {
			if (bitmapData != null && bitmapData.height != getDesiredHeight()) recreateBitmapData();
			background.height = _height;
		}

		private function createBitmapData():void {
			bitmapData = new BitmapData(getDesiredWidth(), getDesiredHeight(), true, 0x00000000);
		}

//		private function destroyBitmapData():void {
//			bitmapData.dispose();
//			bitmapData = null;
//		}

		private function getDesiredWidth():Number {
			return Math.ceil(_width * density);
		}

		private function getDesiredHeight():Number {
			return Math.ceil(_height * density);
		}

		private function recreateBitmapData():void {
			// Size has been changed, so need to recreate bitmap data
			destroyBitmap();

			var bmp:BitmapData = bitmapData;
			createBitmapData();
			bitmapData.draw(bmp);
			bmp.dispose();
			bmp = null;

			createBitmap();
		}

		private function createBitmap():void {
			bitmap = new Bitmap(bitmapData);
			bitmap.smoothing = true;
			bitmap.scaleX = bitmap.scaleY = 1/density;
			addChild(bitmap);
		}

		private function destroyBitmap():void {
			if (bitmap != null) {
				bitmap.bitmapData = null;
				removeChild(bitmap);
				bitmap = null;
			}
		}

		private function fadeStep():void {
			// Fades the bitmap a little bit

			// Makes it darker and fades it away
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(0, 0), new ColorMatrixFilter([
				0.98, 0, 0, 0, 0,
				0, 0.98, 0, 0, 0,
				0, 0, 0.98, 0, 0,
				0, 0, 0, 0.98, -1,
			]));

			// Blurs it a bit
			bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(0, 0), new BlurFilter(1 + 2 * density, 1 + 2 * density, 1));

		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onAddedToStage(__e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			createBitmapData();
			createBitmap();

			super.onAddedToStage(__e);
		}

		override protected function onRemovedFromStage(__e:Event):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			destroyBitmap();

			super.onRemovedFromStage(__e);
		}

		private function onMouseMove(__e:MouseEvent):void {
			matrix.identity();
			matrix.scale(density, density);
			matrix.translate(__e.stageX * density, __e.stageY * density);
			bitmapData.draw(isMouseDown ? shapeMouseDown : shapeMouseUp, matrix);

			eventsDrawn = (eventsDrawn+1) % 100;
			if (eventsDrawn == 0) {
				fadeStep();
			}
		}

		private function onMouseDown(__e:MouseEvent):void {
			isMouseDown = true;
			onMouseMove(__e);
		}

		private function onMouseUp(__e:MouseEvent):void {
			isMouseDown = false;
			onMouseMove(__e);
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function clear():void {
			bitmapData.fillRect(bitmapData.rect, 0x00000000);
		}

	}
}
