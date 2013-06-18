package com.zehfernando.display.progressbars {
	import com.zehfernando.display.shapes.Box;

	/**
	 * @author zeh
	 */
	public class RectangleProgressBar extends AbstractProgressBar {

		// Instances
		protected var foreground:Box;
		protected var background:Box;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RectangleProgressBar(__foregroundColor:int = 0xffffff, __foregroundAlpha:Number = 1, __backgroundColor:int = 0xffffff, __backgroundAlpha:Number = 0.25) {
			super();

			// Create all assets
			background = new Box(100, 100, __backgroundColor);
			background.alpha = __backgroundAlpha;
			background.visible = __backgroundAlpha > 0;
			addChild(background);

			foreground = new Box(100, 100, __foregroundColor);
			foreground.alpha = __foregroundAlpha;
			foreground.visible = __foregroundAlpha > 0;
			addChild(foreground);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawAmount():void {
			// Redraws graphics to represent the correct amount
			//trace ("====> " + _value.current, _value.target);
			foreground.width = 100 * _value.current;

			background.x = foreground.width;
			background.width = 100 - foreground.width;
		}

	}
}
