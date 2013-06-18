package com.zehfernando.display {

	import com.zehfernando.display.abstracts.ResizableSprite;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;

	/**
	 * @author zeh
	 */
	public class BitmapGhost extends ResizableSprite {

		// A bitmap copy of something

		// Properties
		protected var _transparent:Boolean;

		protected var _redrawFilter:BitmapFilter;								// TODO: use array of filters?
		protected var _redrawColorTransform:ColorTransform;
		protected var _isRunning:Boolean;
		protected var _margins:Number;
		protected var _smoothing:Boolean;

		// Instances
		protected var bitmapData:BitmapData;
		protected var bitmap:Bitmap;

		protected var bufferBitmapData:BitmapData;

		protected var _target:IBitmapDrawable;

		// Buffer used when resizing

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BitmapGhost(__target:IBitmapDrawable, __width:Number, __height:Number, __margins:Number = 10, __transparent:Boolean = false) {
			super();

			_target = __target;
			_width = __width;
			_height = __height;
			_transparent = __transparent;
			_margins = __margins;
			_smoothing = false;

			createBitmap();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			createBufferBitmap();
			createBitmap();
		}

		override protected function redrawHeight():void {
			createBufferBitmap();
			createBitmap();
		}

		protected function createBufferBitmap():void {
			destroyBufferBitmap();

			bufferBitmapData = new BitmapData(bitmapData.width, bitmapData.height, bitmapData.transparent, 0x00000000);
			bufferBitmapData.copyPixels(bitmapData, bitmapData.rect, new Point(0,0));
		}

		protected function destroyBufferBitmap():void {
			if (Boolean(bufferBitmapData)) {
				bufferBitmapData.dispose();
				bufferBitmapData = null;
			}
		}

		protected function createBitmap():void {
			destroyBitmap();

			bitmapData = new BitmapData(_width + _margins * 2, _height + _margins * 2, _transparent, 0x00000000);
			bitmap = new Bitmap(bitmapData, PixelSnapping.AUTO, _smoothing);
			bitmap.x = bitmap.y = -_margins;
			addChild(bitmap);

			if (Boolean(bufferBitmapData)) {
				bitmapData.copyPixels(bufferBitmapData, bufferBitmapData.rect, new Point(0,0));
				destroyBufferBitmap();
			}
		}

		protected function destroyBitmap():void {
			if (Boolean(bitmapData)) {
				bitmapData.dispose();
				bitmapData = null;

				bitmap.bitmapData = null;
				removeChild(bitmap);
				bitmap = null;
			}
		}

		protected function applySmoothing():void {
			if (Boolean(bitmap)) {
				bitmap.smoothing = _smoothing;
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onEnterFrameDraw(e:Event):void {
			draw();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function start():void {
			if (!_isRunning) {
				addEventListener(Event.ENTER_FRAME, onEnterFrameDraw, false, 0, true);
				_isRunning = true;
			}
		}

		public function stop():void {
			if (_isRunning) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrameDraw);
				_isRunning = false;
			}
		}

		public function draw():void {
			//bitmapData.draw(_target, null, _redrawColorTransform);
			//var bitmapDataTemp:BitmapData = new BitmapData(bitmapData.width, bitmapData.height, bitmapData.transparent, 0x000000);
			var bitmapDataTemp:BitmapData = bitmapData.clone();

			var mtx:Matrix = new Matrix();
			mtx.translate(_margins, _margins);
			bitmapDataTemp.draw(_target, mtx);
			if (Boolean(_redrawFilter)) bitmapDataTemp.applyFilter(bitmapDataTemp, bitmapData.rect, new Point(0,0), _redrawFilter);

			bitmapData.fillRect(bitmapData.rect, 0x000000);
			bitmapData.draw(bitmapDataTemp, null, _redrawColorTransform);

			bitmapDataTemp.dispose();

//			bitmapData.draw(_target);
//			if (Boolean(_redrawFilter)) bitmapData.applyFilter(bitmapData, bitmapData.rect, new Point(0,0), _redrawFilter);
		}

		public function dispose():void {
			destroyBufferBitmap();
			destroyBitmap();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get redrawColorTransform():ColorTransform {
			return _redrawColorTransform;
		}

		public function set redrawColorTransform(__value:ColorTransform):void {
			_redrawColorTransform = __value;
		}

		public function get redrawFilter():BitmapFilter {
			return _redrawFilter;
		}

		public function set redrawFilter(__value:BitmapFilter):void {
			_redrawFilter = __value;
		}

		public function get smoothing():Boolean {
			return _smoothing;
		}
		public function set smoothing(__value:Boolean):void {
			if (_smoothing != __value) {
				_smoothing = __value;
				applySmoothing();
			}
		}

	}
}
