package com.zehfernando.utils {

	/**
	 * @author zeh
	 */
	public class DateUtils {

		public static function subtraction(__date1:Date, __date2:Date): Date {
			var dateResult:Date = new Date();
			dateResult.time = __date1.time - __date2.time;
			return dateResult;
		}

		public static function addition(__date1:Date, __date2:Date): Date {
			var dateResult:Date = new Date();
			dateResult.time = __date1.time + __date2.time;
			return dateResult;
		}

		public static function stringSecondsToSeconds(__time:String): Number {
			// Returns number of seconds based on a string
			// Examples:
			// 01:30 -> returns 90
			// 30 -> returns 30
			// 90 -> returns 90
			
			var num:Number = 0;
			var cs:Array = __time.split(":");
			for (var i:int = 0; i < cs.length; i++) {
				num += parseFloat(cs[i]) * Math.pow(60, cs.length - i - 1);
			}
			
			return num;
		}

		public static function simpleDateToDate(__date:String): Date {
			// Converts 2010-01-01 to a date
			var tt:Date = new Date();
			tt.fullYearUTC = parseInt(__date.substr(0, 4), 10);
			tt.monthUTC = parseInt(__date.substr(5, 2), 10) - 1;
			tt.dateUTC = parseInt(__date.substr(8, 2), 10);
			tt.hoursUTC = 0;
			tt.secondsUTC = 0;
			tt.millisecondsUTC = 0;
			return tt;
		}

		public static function xsdDateTimeToDate(__date:String): Date {
			// Converts a data from DateTime XML format to a normal Date
			// This is the same format that comes from .NET database dumps as XML
			// Example: 2009-10-19T17:20:08-04:00
			// Reference: http://www.w3schools.com/Schema/schema_dtypes_date.asp
			if (!Boolean(__date) || __date.length < 25) return null;
			
			var tt:Date = new Date();
			tt.fullYear = parseInt(__date.substr(0, 4), 10);
			tt.month = parseInt(__date.substr(5, 2), 10) - 1;
			tt.date = parseInt(__date.substr(8, 2), 10);
			tt.hours = parseInt(__date.substr(11, 2), 10);
			tt.minutes = parseInt(__date.substr(14, 2), 10);
			tt.seconds = parseInt(__date.substr(17, 2), 10);
			
			// Timezone is ignored
			//tt.timezoneOffset = parseInt(__date.substr(20, 2), 10) * 60 + parseInt(__date.substr(23, 2), 10);
			//if (__date.substr(19, 1) == "-") tt.timezoneOffset *= -1;
			
			return tt;
		}

		public static function xsdDateTimeToDateUniversal(__date:String): Date {
			// Converts a data from DateTime XML format to a normal Date
			// This should be the final, universal one
			// Example: 2010-06-30T21:19:01.000Z
			// Or:      2002-05-30T09:30:10.5
			// Or:      2002-05-30T09:30:10Z
			// Or:      2002-05-30T09:30:10-06:00
			// Or:      2002-05-30T09:30:10+06:00
			// Or:      2010-08-13
			// Reference: http://www.w3schools.com/Schema/schema_dtypes_date.asp
			// http://books.xmlschemata.org/relaxng/ch19-77049.html
			// [-]CCYY-MM-DDThh:mm:ss[Z|(+|-)hh:mm]
			
			// RFC3339 = "2006-01-02T15:04:05Z07:00"

			if (!Boolean(__date) || __date.length < 10) return null;

			var year:int = 0;
			var month:int = 0;
			var day:int = 0;
			var hours:int = 0;
			var minutes:int = 0;
			var seconds:Number = 0;
			
			var timeZoneHour:int = 0;
			var timeZoneMinutes:int = 0;

			var readOffset:Number = 0;

			// Finally, parses the date

			year = parseInt(__date.substr(0, 4), 10);
			month = parseInt(__date.substr(5, 2), 10) - 1;
			day = parseInt(__date.substr(8, 2), 10);
			
			readOffset = 10;

			// Parses the time if available
			if (__date.length > readOffset && __date.substr(readOffset, 1).toUpperCase() == "T") {
				hours = parseInt(__date.substr(11, 2), 10);
				minutes = parseInt(__date.substr(14, 2), 10);
				
				var secondsSize:int = 0;
				var cutPos:int = __date.length;
				var zPos:int = __date.toUpperCase().indexOf("Z", 19);
				var plusPos:int = __date.indexOf("+", 19);
				var minusPos:int = __date.indexOf("-", 19);
				
				if (zPos > -1) cutPos = Math.min(cutPos, zPos);
				if (plusPos > -1) cutPos = Math.min(cutPos, plusPos);
				if (minusPos > -1) cutPos = Math.min(cutPos, minusPos);
				
				secondsSize = cutPos - 17;
				seconds = parseFloat(__date.substr(17, secondsSize));
				
				readOffset = 17 + secondsSize;
			}
			
			if (__date.length > readOffset) {
				var lastSymbol:String = __date.substr(readOffset, 1).toUpperCase();
				
				if (lastSymbol == "Z") {
					// Universal time
				} else {
					if (lastSymbol == "+" || lastSymbol == "-") {
						// Time adjustments
						var hourSize:int = __date.indexOf(":", readOffset) - readOffset;
						if (readOffset > 0) {
							timeZoneHour = parseInt(__date.substr(readOffset, hourSize), 10);
							timeZoneMinutes = parseInt(__date.substr(readOffset + hourSize + 1), 10);
						}
					}
				}
			}

			// Set the date
			var tt:Date = new Date(0);

			tt.fullYearUTC = year;
			tt.monthUTC = month;
			tt.dateUTC = day;
			tt.hoursUTC = hours;
			tt.minutesUTC = minutes;
			tt.secondsUTC = Math.floor(seconds);
			tt.millisecondsUTC = (seconds - Math.floor(seconds)) * 1000;

//			tt.fullYearUTC = year;
//			tt.monthUTC = month;
//			tt.dateUTC = day;
//			tt.hoursUTC = hours;
//			tt.minutesUTC = minutes;
//			tt.secondsUTC = Math.floor(seconds);
//			tt.millisecondsUTC = (seconds - Math.floor(seconds)) * 1000;

			var minutesOffset:int = timeZoneHour * 60 + timeZoneMinutes;

			tt.time -= minutesOffset * 60 * 1000;
			
			return tt;
		}

		public static function xsdDateTimeToDateUniversalOld(__date:String): Date {
			// Converts a data from DateTime XML format to a normal Date
			// This is the same format that comes from YouTube dumps?

			if (!Boolean(__date) || __date.length < 24) return null;
			
			var tt:Date = new Date();
			tt.fullYearUTC = parseInt(__date.substr(0, 4), 10);
			tt.monthUTC = parseInt(__date.substr(5, 2), 10) - 1;
			tt.dateUTC = parseInt(__date.substr(8, 2), 10);
			tt.hoursUTC = parseInt(__date.substr(11, 2), 10);
			tt.minutesUTC = parseInt(__date.substr(14, 2), 10);
			tt.secondsUTC = parseInt(__date.substr(17, 2), 10);
			tt.millisecondsUTC = parseInt(__date.substr(20, 3), 10);
			
			// TODO: it's ignoring time zone!
			
			return tt;
		}

		public static function descriptiveDifference(__date:Date): String {
			// Ugh, rename this?
			// Returns a friendly description of a time difference ("2 hours", "1 day", "10 seconds", "1 year" etc)
			
			// Full data
			var seconds:Number = __date.time / 1000;
			var minutes:Number = seconds / 60;
			var hours:Number = minutes / 60;
			var days:Number = hours / 24;
			//var weeks:Number = days / 7;
			var months:Number = days / (365.25 / 12);
			var years:Number = days / 365.25;
			
			seconds = Math.floor(seconds);
			minutes = Math.floor(minutes);
			hours = Math.floor(hours);
			days = Math.floor(days);
			months = Math.floor(months); 
			years = Math.floor(years);
			
			if (years > 1)		return years + " years";
			if (years == 1)		return years + " year";
			if (months > 1)		return months + " months";
			if (months == 1)	return months + " month";
			//if (weeks > 1)		return weeks + " weeks";
			//if (weeks == 1)		return weeks + " week";
			if (days > 1)		return days + " days";
			if (days == 1)		return days + " day";
			if (hours > 1)		return hours + " hours";
			if (hours == 1)		return hours + " hour";
			if (minutes > 1)	return minutes + " minutes";
			if (minutes == 1)	return minutes + " minute";
			if (seconds > 1)	return seconds + " seconds";
			if (seconds == 1)	return seconds + " second";
			
			return "";
		}

	}
}
