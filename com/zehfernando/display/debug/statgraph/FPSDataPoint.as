package com.zehfernando.display.debug.statgraph {

	/**
	 * @author zeh fernando
	 */
	public class FPSDataPoint extends AbstractDataPoint {

		/**
		 * Memory used by the SWF
		 */

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FPSDataPoint() {
			super();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function setDefaultProperties():void {
			super.setDefaultProperties();

			chartMax = 60;
			color = 0xff2200;
			minMaxFromAveraged = true;
		}

		override protected function getDataPointValue():Number {
			return 1;
		}

		override protected function getDataPointValueAveraged(__timeSpentMS:Number):Number {
			return samples / (__timeSpentMS / 1000);
		}

		override protected function getDataPointLabel():String {
			return "FPS";
		}
	}
}
