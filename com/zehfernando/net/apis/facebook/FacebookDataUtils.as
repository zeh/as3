package com.zehfernando.net.apis.facebook {
	import com.zehfernando.utils.DateUtils;

	/**
	 * @author zeh
	 */
	public class FacebookDataUtils {

		public static function getResultStringAsDate(__text:String):Date {
			// Converts '2010-08-13T21:12:40+0000' to a real date
			return DateUtils.xsdDateTimeToDateUniversal(__text);
		}
	}
}
