package com.zehfernando.display.debug {
	import com.zehfernando.data.types.Color;
	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.display.shapes.Box;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	/**
	 * @author zeh fernando
	 */
	public class MultiTouchHeatMap extends ResizableSprite {

		// Constants
		private var pointerColors:Dictionary;

		// Properties
		//private var isMouseDown:Boolean;
		private var eventsDrawn:int;
		private var density:Number;								// 1 = normal, 0.5 = half quality

		// Instances
		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;

		private var shapePointerDown:Shape;
		private var shapePointerDrag:Shape;
		private var shapePointerUp:Shape;
		private var background:Box;

		private var matrix:Matrix;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function MultiTouchHeatMap() {
			super();

			//isMouseDown = false;
			eventsDrawn = 0;
			density = 0.5;
			matrix = new Matrix();

			pointerColors = new Dictionary();

			shapePointerDown = new Shape();
			shapePointerDown.graphics.beginFill(0xffffff, 0.5);
			shapePointerDown.graphics.drawTriangles(Vector.<Number>([-30, -30, 30, -30, 0, 30]), Vector.<int>([0, 1, 2]));
			shapePointerDown.graphics.endFill();

			shapePointerDrag = new Shape();
			shapePointerDrag.graphics.beginFill(0xffffff, 0.5);
			shapePointerDrag.graphics.drawCircle(0, 0, 30);
			shapePointerDrag.graphics.endFill();

			shapePointerUp = new Shape();
			shapePointerUp.graphics.beginFill(0xffffff, 0.5);
			shapePointerUp.graphics.drawTriangles(Vector.<Number>([-30, 30, 0, -30, 30, 30]), Vector.<int>([0, 1, 2]));
			shapePointerUp.graphics.endFill();

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

		private function drawShape(__x:Number, __y:Number, __shape:Shape, __color:Color):void {
			// Draws directly to the bitmap
			matrix.identity();
			matrix.scale(density, density);
			matrix.translate(__x * density, __y * density);
			bitmapData.draw(__shape, matrix, __color.toColorTransform());
		}

		private function countEventDrawn():void {
			// Counts as one draw even, fading if needed
			eventsDrawn = (eventsDrawn+1) % 100;
			if (eventsDrawn == 0) fadeStep();
		}

		private function getTouchColor(__index:int):Color {
			// Return a color for a given touch id
			if (!pointerColors.hasOwnProperty(__index)) pointerColors[__index] = Color.fromHSV(__index * 36, 1, 0.5);
			return pointerColors[__index] as Color;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onAddedToStage(__e:Event):void {
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);

			createBitmapData();
			createBitmap();

			super.onAddedToStage(__e);
		}

		override protected function onRemovedFromStage(__e:Event):void {
			stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);

			destroyBitmap();

			super.onRemovedFromStage(__e);
		}

		private function onTouchBegin(__e:TouchEvent):void {
			//isMouseDown = false;
			drawShape(__e.stageX, __e.stageY, shapePointerDown, getTouchColor(__e.touchPointID));
			countEventDrawn();
		}

		private function onTouchMove(__e:TouchEvent):void {
			drawShape(__e.stageX, __e.stageY, shapePointerDrag, getTouchColor(__e.touchPointID));
			countEventDrawn();
		}

		private function onTouchEnd(__e:TouchEvent):void {
			drawShape(__e.stageX, __e.stageY, shapePointerUp, getTouchColor(__e.touchPointID));
			countEventDrawn();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function clear():void {
			bitmapData.fillRect(bitmapData.rect, 0x00000000);
		}

	}
}
