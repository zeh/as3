package com.zehfernando.display.debug.statgraph {
	import com.zehfernando.utils.getTimerUInt;
	/**
	 * @author zeh fernando
	 */
	public class MSDataPoint extends AbstractDataPoint {

		/**
		 * Time spent for code calculation
		 */

		// Properties
		private var timeFrameEntered:uint;

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
			return getTimerUInt() - timeFrameEntered;
		}

		override protected function getDataPointLabel():String {
			return "MS/F";
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function updateValuesEnterFrame():void {
			timeFrameEntered = getTimerUInt();
		}

		override public function updateValuesExitFrame():void {
			addDataPoint();
		}


	}
}
