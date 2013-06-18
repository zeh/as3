package com.zehfernando.net.apis.twitter {

	/**
	 * @author zeh
	 */
	public class TwitterDataUtils {

		// Constants

		public static const months:Array = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]; // Redundant so it's locale-agnostic

		public static function getDateAsParamString(__date:Date):String {
			return __date.fullYear + "-" + ("00" + (__date.month+1)).substr(-2,2) + "-" + ("00" + __date.date).substr(-2,2);
		}

		public static function getSearchResultStringAsDate(__text:String):Date {
			// Converts 'Mon, 16 Aug 2010 20:15:18 +0000' to a real date
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

		public static function getStatusesResultStringAsDate(__text:String):Date {
			// Converts 'Thu Aug 19 18:42:23 +0000 2010' to a real date
			var date:Date = new Date();

			var sText:Array = __text.split(" ");

			date.dateUTC = parseInt(sText[2], 10);
			date.monthUTC = months.indexOf((sText[1] as String).toLowerCase());
			date.fullYearUTC = parseInt(sText[5], 10);

			date.hoursUTC = parseInt((sText[3] as String).substr(0, 2), 10);
			date.minutesUTC = parseInt((sText[3] as String).substr(3, 2), 10);
			date.secondsUTC = parseInt((sText[3] as String).substr(6, 2), 10);

			return date;
		}

		public static function decodeHTML(__text:String):String {
			if (__text == null) return null;
			return __text.split("&quot;").join("\"").split("&amp;").join("&");
		}
	}
}
