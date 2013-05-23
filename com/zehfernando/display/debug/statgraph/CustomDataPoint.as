package com.zehfernando.display.debug.statgraph {
	/**
	 * @author zeh fernando
	 */
	public class CustomDataPoint extends AbstractDataPoint {

		/**
		 * A data point for anything
		 */

		// Properties
		private var label:String;
		private var value:Number;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CustomDataPoint(__label:String, __color:int, __chartMax:Number) {
			super();
			label = __label;
			color = __color;
			chartMax = __chartMax;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getDataPointValue():Number {
			return value;
		}

		override protected function getDataPointLabel():String {
			return label;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function setValue(__value:Number):void {
			value = __value;
		}

		public function setChartMax(__value:Number):void {
			chartMax = __value;
		}
	}
}
