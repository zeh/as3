package com.zehfernando.utils {
	
	public function getStateFromZip(__zip:String): String {

		var stateList:Array = [];
		stateList.push(["AL", 35000, 36999]);
		stateList.push(["AK", 99500, 99999]);
		stateList.push(["AZ", 85000, 86999]);
		stateList.push(["AR", 71600, 72999]);
		stateList.push(["CA", 90000, 96199]);
		stateList.push(["CO", 80000, 81999]);
		stateList.push(["CT",  6000,  6389]);
		stateList.push(["CT",  6391,  6999]);
		stateList.push(["DE", 19700, 19999]);
		stateList.push(["DC", 20000, 20099]);
		stateList.push(["DC", 20200, 20599]);
		stateList.push(["DC", 56900, 56999]);
		stateList.push(["FL", 32000, 34999]);
		stateList.push(["GA", 30000, 31999]);
		stateList.push(["GA", 39800, 39899]);
		stateList.push(["GA", 39901, 39901]);
		stateList.push(["HI", 96700, 96899]);
		stateList.push(["ID", 83200, 83999]);
		stateList.push(["IL", 60000, 62999]);
		stateList.push(["IN", 46000, 47999]);
		stateList.push(["IA", 50000, 52999]);
		stateList.push(["KS", 66000, 67999]);
		stateList.push(["KY", 40000, 42799]);
		stateList.push(["LA", 70000, 71599]);
		stateList.push(["ME",  3900,  4999]);
		stateList.push(["MD", 20600, 21999]);
		stateList.push(["MA",  1000,  2799]);
		stateList.push(["MI", 48000, 49999]);
		stateList.push(["MN", 55000, 56799]);
		stateList.push(["MS", 38600, 39999]);
		stateList.push(["MO", 63000, 65999]);
		stateList.push(["MT", 59000, 59999]);
		stateList.push(["NE", 68000, 69999]);
		stateList.push(["NE", 88900, 89999]);
		stateList.push(["NJ",  7000,  8999]);
		stateList.push(["NH",  3000,  3899]);
		stateList.push(["NM", 87000, 88499]);
		stateList.push(["NY", 10000, 14999]);
		stateList.push(["NY",   544,   544]);
		stateList.push(["NY",   501,   501]);
		stateList.push(["NY",  6390,  6390]);
		stateList.push(["NC", 27000, 28999]);
		stateList.push(["ND", 58000, 58999]);
		stateList.push(["OH", 43000, 45999]);
		stateList.push(["OK", 73000, 74999]);
		stateList.push(["OR", 97000, 97999]);
		stateList.push(["PA", 15000, 19699]);
		stateList.push(["PR",   600,   799]);
		stateList.push(["PR",   900,   999]);
		stateList.push(["RI",  2800,  2999]);
		stateList.push(["SC", 29000, 29999]);
		stateList.push(["SD", 57000, 57999]);
		stateList.push(["TN", 37000, 38599]);
		stateList.push(["TX", 75000, 79999]);
		stateList.push(["TX", 88500, 88599]);
		stateList.push(["VI",   800,   899]);
		stateList.push(["UT", 84000, 84999]);
		stateList.push(["VT",  5000,  5999]);
		stateList.push(["VA", 20100, 20199]);
		stateList.push(["VA", 22000, 24699]);
		stateList.push(["WA", 98000, 99499]);
		stateList.push(["WV", 24700, 26999]);
		stateList.push(["WI", 53000, 54999]);
		stateList.push(["WY", 82000, 83199]);
		stateList.push(["AA", 34090, 34095]);
		stateList.push(["AA",  9000,  9999]);
		stateList.push(["AA", 96200, 96699]);

		var zn:Number = parseInt(__zip, 10);
		for (var i:Number = 0; i < stateList.length; i++) {
			if (zn >= Number(stateList[i][1]) && zn <= Number(stateList[i][2])) {
				return (stateList[i][0] as String);
			}
		}
		
		return "";

	}

}
