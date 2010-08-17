package com.zehfernando.net.apis.twitter {

	/**
	 * @author zeh
	 */
	public class TwitterDataUtils {
		
		// Constants
		
		public static const months:Array = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]; // Redundant so it's locale-agnostic
		
		public static function getDateAsParamString(__date:Date): String {
			return __date.fullYear + "-" + ("00" + (__date.month+1)).substr(-2,2) + "-" + ("00" + __date.date).substr(-2,2);
		}

		public static function getResultStringAsDate(__text:String):Date {
			// Converts 'Mon, 16 Aug 2010 20:15:18 +0000' to a real data
			var date:Date = new Date();
			
			var sText:Array = __text.split(" ");
			
			date.dateUTC = parseInt(sText[1], 10);
			date.monthUTC = months.indexOf((sText[2] as String).toLowerCase());
			date.fullYearUTC = parseInt(sText[3], 10);

			date.hoursUTC = parseInt((sText[4] as String).substr(0, 2), 10);
			date.minutesUTC = parseInt((sText[4] as String).substr(3, 2), 10);
			date.secondsUTC = parseInt((sText[4] as String).substr(6, 2), 10);
			
			return date;
		}
	}
}
