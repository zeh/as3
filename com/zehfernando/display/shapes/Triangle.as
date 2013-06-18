package com.zehfernando.display.shapes {
	import flash.display.Sprite;

	/**
	 * @author zeh
	 */
	public class Triangle extends Sprite {

		// Properties
		protected var _color:Number;
		protected var _length:Number;
		protected var _weight:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Triangle(__length:Number = 100, __weight:Number = 100, __color:int = 0xff0000, __rotation:Number = 0) {

			_color = __color & 0xffffff;
			_length = __length;
			_weight = __weight;

			rotation = __rotation;

			paint();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function paint():void {
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill(_color);
			graphics.moveTo(0, -_weight/2);
			graphics.lineTo(_length, 0);
			graphics.lineTo(0, _weight/2);
			graphics.endFill();
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

		public function get length():Number {
			return _length;
		}

		public function set length(__value:Number):void {
			if (_length != __value) {
				_length = __value;
				paint();
			}
		}

		public function get weight():Number {
			return _weight;
		}

		public function set weight(__value:Number):void {
			if (_weight != __value) {
				_weight = __value;
				paint();
			}
		}

	}
}
