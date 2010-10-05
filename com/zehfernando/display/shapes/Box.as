package com.zehfernando.display.shapes {
	import flash.display.Sprite;	
	
	/**
	 * @author Zeh Fernando
	 */
	public class Box extends Sprite {
		
		// Properties
		protected var _color:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Box(__width:Number = 100, __height:Number = 100, __color:int = 0xff0000) {
			
			_color = __color & 0xffffff;
			
			scaleX = __width/100;
			scaleY = __height/100;

			paint();
		}

		
		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function paint(): void {
			graphics.clear();
			graphics.lineStyle();
			graphics.beginFill(_color);
			graphics.drawRect(0, 0, 100, 100);
			graphics.endFill();
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
