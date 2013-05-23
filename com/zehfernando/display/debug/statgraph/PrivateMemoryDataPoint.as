package com.zehfernando.display.debug.statgraph {
	import flash.system.System;

	/**
	 * @author zeh fernando
	 */
	public class PrivateMemoryDataPoint extends AbstractDataPoint {

		/**
		 * Memory used by the player
		 */

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function PrivateMemoryDataPoint() {
			super();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function setDefaultProperties():void {
			super.setDefaultProperties();

			chartMax = 1024 * 1024 * 100;
			valueLabelUnit = 1024 * 1024;
			valueLabelUnitDecimalPoints = 1;
			color = 0x0033ff;
		}

		override protected function getDataPointValue():Number {
			return System.privateMemory;
		}

		override protected function getDataPointLabel():String {
			return "MB (PVT)";
		}
	}
}
