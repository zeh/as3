package com.zehfernando.display.shapes {
	import flash.display.Sprite;

	/**
	 * @author zeh
	 */
	public class Circle extends Sprite {

		// Properties
		protected var _color:Number;
		protected var _radius:Number;
		protected var _innerRadius:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Circle(__radius:Number = 100, __color:int = -1, __innerRadius:Number = 0) {

			_color = (__color < 0 ? Math.random() * 0xffffff : __color) & 0xffffff;
			_radius = __radius;
			_innerRadius = __innerRadius;

			paint();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function paint():void {
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill(_color);
			graphics.drawCircle(0, 0, _radius);

			if (_innerRadius > 0) graphics.drawCircle(0, 0, _innerRadius);

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

	}
}
