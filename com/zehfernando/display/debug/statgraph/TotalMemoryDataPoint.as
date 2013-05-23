package com.zehfernando.display.debug.statgraph {
	import flash.system.System;

	/**
	 * @author zeh fernando
	 */
	public class TotalMemoryDataPoint extends AbstractDataPoint {

		/**
		 * Memory used by the SWF
		 */

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TotalMemoryDataPoint() {
			super();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function setDefaultProperties():void {
			super.setDefaultProperties();

			chartMax = 1024 * 1024 * 40;
			valueLabelUnit = 1024 * 1024;
			valueLabelUnitDecimalPoints = 1;
			color = 0x0066ff;
		}

		override protected function getDataPointValue():Number {
			return System.totalMemory;
		}

		override protected function getDataPointLabel():String {
			return "MB";
		}
	}
}
