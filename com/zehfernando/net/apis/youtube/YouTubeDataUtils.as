package com.zehfernando.net.apis.youtube {

	/**
	 * @author zeh
	 */
	public class YouTubeDataUtils {

		public static function fromStringToSeconds(__time:String):Number {
			// Converts from "00:00:13.750" to a number of seconds

			var hours:int = parseInt(__time.substr(0, 2));
			var minutes:int = parseInt(__time.substr(3, 2));
			var seconds:int = parseInt(__time.substr(6, 2));
			var milliSeconds:int = parseInt(__time.substr(9, 3));
			return hours * 60 * 60 + minutes * 60 + seconds + milliSeconds/1000;
		}
	}
}
