package com.zehfernando.display.abstracts {

	import com.zehfernando.display.shapes.Box;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class SmartBitmap extends Sprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;

		// Properties
		protected var _roundDimensions:Boolean;
		protected var _borderInside:Boolean;

		protected var _borderAlpha:Number;
		protected var _borderColor:int;
		protected var _border:Number;

		protected var _maintainAspectRatio:Boolean;

		// Instances
		protected var bitmap:Bitmap;
		protected var borderBox:Box;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function SmartBitmap(__bitmap:Bitmap) {
			_width = __bitmap.width;
			_height = __bitmap.height;

			_roundDimensions = true;
			_borderInside = true;

			_border = 1;
			_borderAlpha = 0.5;
			_borderColor = 0x000000;

			_maintainAspectRatio = true;

			bitmap = __bitmap;
			bitmap.smoothing = true;
			addChild(bitmap);

			borderBox = new Box(_width, _height, _borderColor, _border);
			borderBox.alpha = _borderAlpha;
			addChild(borderBox);

			redraw();
			redrawBorderState();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function redraw():void {
			var w:Number = _roundDimensions ? Math.round(_width) : _width;
			var h:Number = _roundDimensions ? Math.round(_height) : _height;

			var borderOff:Number = getBorderOffset();
			bitmap.x = borderOff;
			bitmap.y = borderOff;
			bitmap.width = w - borderOff * 2;
			bitmap.height = h - borderOff * 2;

			borderBox.width = w;
			borderBox.height = h;
			borderBox.outlineWidth = _border;
		}

		protected function getBorderOffset():Number {
			return _borderInside ? 0 : _border;
		}

		protected function redrawBorderState():void {
			borderBox.alpha = _borderAlpha;
			borderBox.visible = _borderAlpha > 0;
			borderBox.color = _borderColor;
		}

		protected function setHeightFromWidth():void {
			_height = (_width - getBorderOffset() * 2) / (bitmap.bitmapData.width / bitmap.bitmapData.height);
		}

		protected function setWidthFromHeight():void {
			_width = (_height - getBorderOffset() * 2) * (bitmap.bitmapData.width / bitmap.bitmapData.height);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function dispose():void {
			removeChild(bitmap);
			bitmap.bitmapData.dispose();
			bitmap.bitmapData = null;
			bitmap = null;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				if (_maintainAspectRatio) setHeightFromWidth();
				redraw();
			}
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				if (_maintainAspectRatio) setWidthFromHeight();
				redraw();
			}
		}

		public function get border():Number {
			return _border;
		}
		public function set border(__value:Number):void {
			if (_border != __value) {
				_border = __value;
				redraw();
			}
		}

		public function get borderColor():int {
			return _borderColor;
		}
		public function set borderColor(__value:int):void {
			if (_borderColor != __value) {
				_borderColor = __value;
				redrawBorderState();
			}
		}

		public function get borderAlpha():Number {
			return _borderAlpha;
		}
		public function set borderAlpha(__value:Number):void {
			if (_borderAlpha != __value) {
				_borderAlpha = __value;
				redrawBorderState();
			}
		}

		public function get maintainAspectRatio():Boolean {
			return _maintainAspectRatio;
		}
		public function set maintainAspectRatio(__value:Boolean):void {
			if (_maintainAspectRatio != __value) {
				_maintainAspectRatio = __value;
				if (_maintainAspectRatio) setHeightFromWidth();
			}
		}

		public function get borderInside():Boolean {
			return _borderInside;
		}
		public function set borderInside(__value:Boolean):void {
			if (_borderInside != __value) {
				_borderInside = __value;
				redraw();
			}
		}
	}
}
