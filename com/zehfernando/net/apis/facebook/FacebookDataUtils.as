package com.zehfernando.net.apis.facebook {

	import com.zehfernando.utils.DateUtils;

	/**
	 * @author zeh
	 */
	public class FacebookDataUtils {

		public static function getResultStringAsDate(__text:String):Date {
			// Converts '2010-08-13T21:12:40+0000' to a real date
			return DateUtils.xsdDateTimeToDate(__text);
		}

		public static function getImageURLSafeReplacement(__url:String):String {
			// Given an static image URL, replaces domains that don't work (https domains) with the http counterpart

			var i:int;
			var newDomain:String;
			var reps:Array = FacebookConstants.IMAGE_DOMAIN_REPLACEMENTS;

			for (i = 0; i < reps.length; i++) {
				newDomain = reps[i][1+Math.floor(Math.random() * ((reps[i] as Array).length-1))];
				__url = __url.split(reps[i][0]).join(newDomain);
			}

			return __url;
		}
	}
}
