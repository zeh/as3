package com.zehfernando.display.shapes {
	import flash.display.Sprite;

	/**
	 * @author Zeh Fernando
	 */
	public class Box extends Sprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;
		protected var _color:uint;

		protected var _outlineWidth:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Box(__width:Number = 100, __height:Number = 100, __color:int = -1, __outlineWidth:Number = 0) {

			_width = __width;
			_height = __height;
			_color = (__color < 0 ? Math.random() * 0xffffff : __color) & 0xffffff;

			_outlineWidth = __outlineWidth;

			paint();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function paint():void {
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill(_color);
			graphics.drawRect(0, 0, _width, _height);

			if (_outlineWidth != 0) graphics.drawRect(_outlineWidth, _outlineWidth, _width - _outlineWidth * 2, _height - _outlineWidth * 2);

			graphics.endFill();
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get color():uint { return _color; }
		public function set color(__value:uint):void {
			if (_color != __value) {
				_color = __value & 0xffffff;
				paint();
			}
		}

		public function get colorR():Number { return ((_color & 0xff0000) >> 16)/255; }
		public function set colorR(__value:Number):void {
			_color = (_color & 0x00ffff) | (Math.round(__value * 255) << 16);
			paint();
		}

		public function get colorG():Number { return ((_color & 0xff00) >> 8)/255; }
		public function set colorG(__value:Number):void {
			_color = (_color & 0xff00ff) | (Math.round(__value * 255) << 8);
			paint();
		}

		public function get colorB():Number { return (_color & 0xff) / 255; }
		public function set colorB(__value:Number):void {
			_color = (_color & 0xffff00) | Math.round(__value * 255);
			paint();
		}

		override public function get width():Number { return _width; }
		override public function set width(__value:Number):void {
			if (isNaN(__value)) __value = 0;
			if (_width != __value) {
				_width = __value;
				paint();
			}
		}

		override public function get height():Number { return _height; }
		override public function set height(__value:Number):void {
			if (isNaN(__value)) __value = 0;
			if (_height != __value) {
				_height = __value;
				paint();
			}
		}

		public function get outlineWidth():Number { return _outlineWidth; }
		public function set outlineWidth(__value:Number):void {
			if (isNaN(__value)) __value = 0;
			if (_outlineWidth != __value) {
				_outlineWidth = __value;
				paint();
			}
		}
	}
}
