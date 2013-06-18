package com.zehfernando.display.progressbars {
	import com.zehfernando.display.shapes.CircleSlice;

	/**
	 * @author zeh
	 */
	public class CircularProgressBar extends AbstractProgressBar {

		// Properties
		protected var angleOffset:Number;

		// Instances
		protected var baseCircle:CircleSlice;
		protected var loadingCircle:CircleSlice;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CircularProgressBar(__innerRadius:Number = 5, __outerRadius:Number = 10, __color:int = 0xffffff, __backgroundAlpha:Number = 0.25, __foregroundAlpha:Number = 1, __angleOffset:Number = -90) {
			super();

			angleOffset = __angleOffset;

			// Create all assets
			baseCircle = new CircleSlice(__outerRadius, __color, __innerRadius);
			baseCircle.alpha = __backgroundAlpha;
			baseCircle.visible = __backgroundAlpha > 0;
			addChild(baseCircle);

			loadingCircle = new CircleSlice(__outerRadius, __color, __innerRadius, angleOffset);
			loadingCircle.alpha = __foregroundAlpha;
			loadingCircle.visible = __foregroundAlpha > 0;
			addChild(loadingCircle);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawAmount():void {
			// Redraws graphics to represent the correct amount
			loadingCircle.endAngle = angleOffset + _value.current * 360;
		}

	}
}
