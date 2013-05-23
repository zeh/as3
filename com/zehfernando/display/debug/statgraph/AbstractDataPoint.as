package com.zehfernando.display.debug.statgraph {
	/**
	 * @author zeh fernando
	 */
	public class AbstractDataPoint {
		/**
		 * Controls data passed to the StatGraph
		 */

		// Properties
		protected var min:Number;
		protected var max:Number;
		protected var total:Number;
		protected var samples:int;

		protected var valueLabelUnit:Number;
		protected var valueLabelUnitDecimalPoints:int;
		protected var chartMax:Number;
		protected var color:int;

		protected var minMaxFromAveraged:Boolean;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AbstractDataPoint() {
			setDefaultProperties();
			reset();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function setDefaultProperties():void {
			// Extend!
			min = NaN;
			max = NaN;
			valueLabelUnit = 1;
			valueLabelUnitDecimalPoints = 0;
			chartMax = 1;
			color = 0x666666;
			minMaxFromAveraged = false;
		}

		protected function getDataPointValue():Number {
			// Extend!
			return NaN;
		}

		protected function getDataPointValueAveraged(__timeSpentMS:Number):Number {
			// Extend if needed!
			return (total / samples);
		}

		protected function getDataPointLabel():String {
			// Extend!
			return "?";
		}

		protected function getChartMax():Number {
			// Extend!
			return 1;
		}

		protected function addDataPoint():void {
			var value:Number = getDataPointValue();
			if (!isNaN(value)) {
				total += value;
				samples++;
				if (!minMaxFromAveraged) {
					calculateMinMax(value);
				}
			}
		}

		protected function calculateMinMax(__value:Number):void {
			if (!isNaN(__value)) {
				if (isNaN(min) || __value < min) min = __value;
				if (isNaN(max) || __value > max) max = __value;
			}
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function updateValuesEnterFrame():void {
			// Extend!
			addDataPoint();
		}

		public function updateValuesExitFrame():void {
			// Extend!
		}

		final public function reset():void {
			total = 0;
			samples = 0;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		final public function getValueCurrent(__timeSpentMS:Number):Number {
			// Returns current average number
			var averageValue:Number = getDataPointValueAveraged(__timeSpentMS);
			if (minMaxFromAveraged) calculateMinMax(averageValue);
			return averageValue;
		}

		final public function getValueLabelUnit():Number {
			return valueLabelUnit;
		}

		final public function getValueLabelUnitDecimalPoints():Number {
			return valueLabelUnitDecimalPoints;
		}

		final public function getLabel():String {
			return getDataPointLabel();
		}

		final public function getValueMin():Number {
			return min;
		}

		final public function getValueMax():Number {
			return max;
		}

		final public function getValueMaxChart():Number {
			return chartMax;
		}

		public function getColor():int {
			return color;
		}
	}
}
