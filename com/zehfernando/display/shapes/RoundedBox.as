package com.zehfernando.display.shapes {
	import flash.display.Sprite;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class RoundedBox extends Sprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;
		protected var _color:Number;

		protected var _radius:Number;
		protected var _borderSize:Number; 
		protected var _topLeftRadius:Number;
		protected var _topRightRadius:Number;
		protected var _bottomLeftRadius:Number;
		protected var _bottomRightRadius:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RoundedBox(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000, __radius:Number = 0, __outlineWidth:Number = 0) {
			_color = __color;
			_width = __width;
			_height = __height;
			
			_radius = _topLeftRadius = _topRightRadius = _bottomLeftRadius = _bottomRightRadius = __radius;
			_borderSize = __outlineWidth;
			
			paint();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function paint(): void {
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill(_color, 1);
			graphics.drawRoundRectComplex(0, 0, _width, _height, _topLeftRadius, _topRightRadius, _bottomLeftRadius, _bottomRightRadius);
			
			if (_borderSize != 0) graphics.drawRoundRectComplex(_borderSize, _borderSize, _width - _borderSize * 2, _height - _borderSize * 2, _topLeftRadius - _borderSize, _topRightRadius - _borderSize, _bottomLeftRadius - _borderSize, _bottomRightRadius - _borderSize);

			graphics.endFill();
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------
		
		// TODO: use invalidate
		// The repetitive redraws don't look good but impact in rendering is virtually none

		override public function get width(): Number { return _width; }
		override public function set width(__value:Number): void {
			if (_width != __value) {
				_width = __value;
				paint();
			}
		}

		override public function get height(): Number { return _height; }
		override public function set height(__value:Number): void {
			if (_height != __value) {
				_height = __value;
				paint();
			}
		}

		public function get color(): Number { return _color; }
		public function set color(__value:Number): void {
			if (_color != __value) {
				_color = __value;
				paint();
			}
		}

		public function get radius(): Number {
			return _radius;
		}
		public function set radius(__value:Number): void {
			_radius = _topLeftRadius = _topRightRadius = _bottomLeftRadius = _bottomRightRadius = __value;
			paint();
		}

		public function get topLeftRadius(): Number { return _topLeftRadius; }
		public function set topLeftRadius(__value:Number): void {
			if (_topLeftRadius != __value) {
				_topLeftRadius = __value;
				paint();
			}
		}

		public function get topRightRadius(): Number { return _topRightRadius; }
		public function set topRightRadius(__value:Number): void {
			if (_topRightRadius != __value) {
				_topRightRadius = __value;
				paint();
			}
		}

		public function get bottomLeftRadius(): Number { return _bottomLeftRadius; }
		public function set bottomLeftRadius(__value:Number): void {
			if (_bottomLeftRadius != __value) {
				_bottomLeftRadius = __value;
				paint();
			}
		}

		public function get bottomRightRadius(): Number { return _bottomRightRadius; }
		public function set bottomRightRadius(__value:Number): void {
			if (_bottomRightRadius != __value) {
				_bottomRightRadius = __value;
				paint();
			}
		}

		public function get borderSize(): Number { return _borderSize; }

		public function set borderSize(__value:Number): void {
			if (_borderSize != __value) {
				_borderSize = __value;
				paint();
			}
		}

	}
}
