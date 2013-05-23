package com.zehfernando.display.debug.statgraph {
	import flash.utils.getTimer;
	/**
	 * @author zeh fernando
	 */
	public class MSDataPoint extends AbstractDataPoint {

		/**
		 * Time spent for code calculation
		 */

		// Properties
		private var timeFrameEntered:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function MSDataPoint() {
			super();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function setDefaultProperties():void {
			super.setDefaultProperties();

			chartMax = (1000 / 60) * 2;
			color = 0x44cc00;

		}

		override protected function getDataPointValue():Number {
			return getTimer() - timeFrameEntered;
		}

		override protected function getDataPointLabel():String {
			return "MS/F";
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function updateValuesEnterFrame():void {
			timeFrameEntered = getTimer();
		}

		override public function updateValuesExitFrame():void {
			addDataPoint();
		}


	}
}
