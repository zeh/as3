package com.zehfernando.display.shapes {
	import com.zehfernando.utils.MathUtils;

	import flash.display.Sprite;

	/**
	 * @author zeh
	 */
	public class CircleSlice extends Sprite {

		// Constants
		protected static const STEP_SIZE:Number = 3; 			// Drawing steps, in degrees.
		protected static const BASE_ANGLE:Number = 0;			// Where is the actual starting 0°, in degrees
		protected static const A_TO_R:Number = Math.PI / 180;

		// Properties
		protected var _color:Number;
		protected var _radius:Number;
		protected var _innerRadius:Number;
		protected var _startAngle:Number;
		protected var _endAngle:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CircleSlice(__radius:Number = 100, __color:int = 0xff0000, __innerRadius:Number = 0, __startAngle:Number = 0, __endAngle:Number = 360) {

			_color = __color & 0xffffff;
			_radius = __radius;
			_innerRadius = __innerRadius;
			_startAngle = __startAngle;
			_endAngle = __endAngle;

			checkProperties();
			paint();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function paint():void {
			graphics.clear();

			var i:Number;
			var a:Number;							// Temp angle

			graphics.lineStyle();
			graphics.beginFill(_color, 1);

			// Outer arc
			a = (_startAngle + BASE_ANGLE) * A_TO_R;
			graphics.moveTo(Math.cos(a) * _radius, Math.sin(a) * _radius);

			for (i = _startAngle + STEP_SIZE; i < _endAngle; i += STEP_SIZE) {
				a = (i + BASE_ANGLE) * A_TO_R;
				graphics.lineTo(Math.cos(a) * _radius, Math.sin(a) * _radius);
			}

			a = (_endAngle + BASE_ANGLE) * A_TO_R;
			graphics.lineTo(Math.cos(a) * _radius, Math.sin(a) * _radius);

			// Inner arc, inverse
			if (_innerRadius > 0) {
				for (i = _endAngle; i > _startAngle; i -= STEP_SIZE) {
					a = (i + BASE_ANGLE) * A_TO_R;
					graphics.lineTo(Math.cos(a) * _innerRadius, Math.sin(a) * _innerRadius);
				}

				a = (_startAngle + BASE_ANGLE) * A_TO_R;
				graphics.lineTo(Math.cos(a) * _innerRadius, Math.sin(a) * _innerRadius);
			} else {
				graphics.lineTo(0, 0);
			}

			graphics.endFill();

		}

		protected function checkProperties():void {
			if (isNaN(_startAngle)) _startAngle = 0;
			_startAngle = MathUtils.clamp(_startAngle, -65535, 65535);

			if (isNaN(_endAngle)) _endAngle = 360;
			_endAngle = MathUtils.clamp(_endAngle, -65535, 65535);
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get color():int {
			return _color;
		}
		public function set color(__value:int):void {
			if (_color != __value) {
				_color = __value;
				paint();
			}
		}

		public function get radius():Number {
			return _radius;
		}
		public function set radius(__value:Number):void {
			if (_radius != __value) {
				_radius = __value;
				paint();
			}
		}

		public function get innerRadius():Number {
			return _innerRadius;
		}
		public function set innerRadius(__value:Number):void {
			if (_innerRadius != __value) {
				_innerRadius = __value;
				paint();
			}
		}

		public function get startAngle():Number {
			return _startAngle;
		}
		public function set startAngle(__value:Number):void {
			if (_startAngle != __value) {
				_startAngle = __value;
				checkProperties();
				paint();
			}
		}

		public function get endAngle():Number {
			return _endAngle;
		}
		public function set endAngle(__value:Number):void {
			if (_endAngle != __value) {
				_endAngle = __value;
				checkProperties();
				paint();
			}
		}

	}
}
