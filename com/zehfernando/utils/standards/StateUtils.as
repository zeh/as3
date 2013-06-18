package com.zehfernando.utils.standards {

	/**
	 * @author zeh
	 */
	public class StateUtils {

		protected static var stateList:Vector.<StateInfo>;

		protected static var inited:Boolean;

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected static function lazyInit():void {
			if (!inited) {
				stateList = new Vector.<StateInfo>();

				stateList.push(new StateInfo("AL", "Alabama", Vector.<uint>([35000, 36999])));
				stateList.push(new StateInfo("AK", "Alaska", Vector.<uint>([99500, 99999])));
				stateList.push(new StateInfo("AZ", "Arizona", Vector.<uint>([85000, 86999])));
				stateList.push(new StateInfo("AR", "Arkansas", Vector.<uint>([71600, 72999])));
				stateList.push(new StateInfo("CA", "California", Vector.<uint>([90000, 96199])));
				stateList.push(new StateInfo("CO", "Colorado", Vector.<uint>([80000, 81999])));
				stateList.push(new StateInfo("CT", "Connecticut", Vector.<uint>([6000,  6389,  6391,  6999])));
				stateList.push(new StateInfo("DE", "Delaware", Vector.<uint>([19700, 19999])));
				stateList.push(new StateInfo("FL", "Florida", Vector.<uint>([32000, 34999])));
				stateList.push(new StateInfo("GA", "Georgia", Vector.<uint>([30000, 31999, 39800, 39899, 39901, 39901])));
				stateList.push(new StateInfo("HI", "Hawaii", Vector.<uint>([96700, 96899])));
				stateList.push(new StateInfo("ID", "Idaho", Vector.<uint>([83200, 83999])));
				stateList.push(new StateInfo("IL", "Illinois", Vector.<uint>([60000, 62999])));
				stateList.push(new StateInfo("IN", "Indiana", Vector.<uint>([46000, 47999])));
				stateList.push(new StateInfo("IA", "Iowa", Vector.<uint>([50000, 52999])));
				stateList.push(new StateInfo("KS", "Kansas", Vector.<uint>([66000, 67999])));
				stateList.push(new StateInfo("KY", "Kentucky", Vector.<uint>([40000, 42799])));
				stateList.push(new StateInfo("LA", "Louisiana", Vector.<uint>([70000, 71599])));
				stateList.push(new StateInfo("ME", "Maine", Vector.<uint>([ 3900,  4999])));
				stateList.push(new StateInfo("MD", "Maryland", Vector.<uint>([20600, 21999])));
				stateList.push(new StateInfo("MA", "Massachusetts", Vector.<uint>([ 1000,  2799])));
				stateList.push(new StateInfo("MI", "Michigan", Vector.<uint>([48000, 49999])));
				stateList.push(new StateInfo("MN", "Minnesota", Vector.<uint>([55000, 56799])));
				stateList.push(new StateInfo("MS", "Mississippi", Vector.<uint>([38600, 39999])));
				stateList.push(new StateInfo("MO", "Missouri", Vector.<uint>([63000, 65999])));
				stateList.push(new StateInfo("MT", "Montana", Vector.<uint>([59000, 59999])));
				stateList.push(new StateInfo("NE", "Nebraska", Vector.<uint>([68000, 69999, 88900, 89999])));
				stateList.push(new StateInfo("NJ", "New Jersey", Vector.<uint>([ 7000,  8999])));
				stateList.push(new StateInfo("NH", "New Hampshire", Vector.<uint>([ 3000,  3899])));
				stateList.push(new StateInfo("NM", "New Mexico", Vector.<uint>([87000, 88499])));
				stateList.push(new StateInfo("NV", "Nevada", Vector.<uint>([89000, 89899])));
				stateList.push(new StateInfo("NY", "New York", Vector.<uint>([10000, 14999,  544,   544,  501,   501, 6390,  6390])));
				stateList.push(new StateInfo("NC", "North Carolina", Vector.<uint>([27000, 28999])));
				stateList.push(new StateInfo("ND", "North Dakota", Vector.<uint>([58000, 58999])));
				stateList.push(new StateInfo("OH", "Ohio", Vector.<uint>([43000, 45999])));
				stateList.push(new StateInfo("OK", "Oklahoma", Vector.<uint>([73000, 74999])));
				stateList.push(new StateInfo("OR", "Oregon", Vector.<uint>([97000, 97999])));
				stateList.push(new StateInfo("PA", "Pennsylvania", Vector.<uint>([15000, 19699])));
				stateList.push(new StateInfo("RI", "Rhode Island", Vector.<uint>([ 2800,  2999])));
				stateList.push(new StateInfo("SC", "South Carolina", Vector.<uint>([29000, 29999])));
				stateList.push(new StateInfo("SD", "South Dakota", Vector.<uint>([57000, 57999])));
				stateList.push(new StateInfo("TN", "Tennessee", Vector.<uint>([37000, 38599])));
				stateList.push(new StateInfo("TX", "Texas", Vector.<uint>([75000, 79999, 88500, 88599])));
				stateList.push(new StateInfo("UT", "Utah", Vector.<uint>([84000, 84999])));
				stateList.push(new StateInfo("VT", "Vermont", Vector.<uint>([ 5000,  5999])));
				stateList.push(new StateInfo("VA", "Virginia", Vector.<uint>([20100, 20199, 22000, 24699])));
				stateList.push(new StateInfo("WA", "Washington", Vector.<uint>([98000, 99499])));
				stateList.push(new StateInfo("WV", "West Virginia", Vector.<uint>([24700, 26999])));
				stateList.push(new StateInfo("WI", "Wisconsin", Vector.<uint>([53000, 54999])));
				stateList.push(new StateInfo("WY", "Wyoming", Vector.<uint>([82000, 83199])));

				// Not real 'states' but used as such
				stateList.push(new StateInfo("DC", "District of Columbia", Vector.<uint>([20000, 20099, 20200, 20599, 56900, 56999])));
				stateList.push(new StateInfo("PR", "Puerto Rico", Vector.<uint>([  600,   799,  900,   999])));
				stateList.push(new StateInfo("VI", "Virgin Islands", Vector.<uint>([  800,   899])));
				stateList.push(new StateInfo("AA", "AA", Vector.<uint>([34090, 34095,  9000,  9999, 96200, 96699]))); // Army bases

				inited = true;
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function getStateFromZip(__zip:String):String {
			lazyInit();

			var zn:Number = parseInt(__zip, 10);
			var i:int, j:int;
			for (i = 0; i < stateList.length; i++) {
				for (j = 0; j < stateList[i].zipRanges.length; j++) {
					if (zn >= stateList[i].zipRanges[j] && zn <= stateList[i].zipRanges[j+1]) {
						return stateList[i].id;
					}
				}
			}
			return "";
		}

		public static function getStateFromName(__stateName:String):String {
			lazyInit();

			var i:int;
			for (i = 0; i < stateList.length; i++) {
				if (stateList[i].name.toLowerCase() == __stateName.toLowerCase()) return stateList[i].id;
			}
			return "";
		}

	}
}

class StateInfo {

	// Properties
	public var id:String;
	public var name:String;
	public var zipRanges:Vector.<uint>;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	function StateInfo(__stateID:String, __stateName:String, __zipRanges:Vector.<uint>) {
		id = __stateID;
		name = __stateName;
		zipRanges = __zipRanges;
	}
}