package com.zehfernando.display.shapes {
	import flash.display.Sprite;

	/**
	 * @author Zeh
	 */
	public class RegistrationMark extends Sprite {

		// Properties
		protected var _color:Number;
		protected var _circleRadius:Number; 
		protected var _lineRadius:Number; 

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RegistrationMark(__color:Number = 0xff00ff) {
			_color = __color & 0xffffff;
			_circleRadius = 20;
			_lineRadius = 30;
			
			paint();
		}

		
		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------

		protected function paint(): void {
			graphics.clear();
			graphics.lineStyle(1, _color);
			graphics.drawCircle(0, 0, _circleRadius);
			graphics.moveTo(0, -_lineRadius);
			graphics.lineTo(0, _lineRadius);
			graphics.moveTo(-_lineRadius, 0);
			graphics.lineTo(_lineRadius, 0);
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get color(): int {
			return _color;
		}
		public function set color(__value:int): void {
			if (_color != __value) {
				_color = __value;
				paint();
			}
		}
	}
}
