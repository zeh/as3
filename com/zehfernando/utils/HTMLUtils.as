package com.zehfernando.utils {
	import flash.external.ExternalInterface;

	/**
	 * @author zeh
	 */
	public class HTMLUtils {

		public static function setCookie(__name:String, __value:String = "", __expireDays:Number = 0): void {

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function(__name, __value, __expireDays) {
					var expDate = new Date();
					expDate.setDate(expDate.getDate() + __expireDays);
					document.cookie = escape(__name) + "=" + escape(__value) + ((__expireDays == 0) ? "" : ";expires=" + expDate.toGMTString()) + "; path=/";
				}
			]]></script>;
			/*FDT_IGNORE*/

    		ExternalInterface.call(js, __name, __value, __expireDays);
		}

		public static function getCookie(__name:String): String {

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function(__name) {
					var exp = new RegExp(escape(__name) + "=([^;]+)");
					if (exp.test (document.cookie + ";")) {
						exp.exec (document.cookie + ";");
						return unescape(RegExp.$1);
					} else {
						return "";
					}
//					if (document.cookie.length > 0) {
//				  		c_start = document.cookie.indexOf(__name + "=");
//				  		if (c_start != -1) {
//				    		c_start = c_start + __name.length + 1;
//				    		c_end = document.cookie.indexOf(";", c_start);
//				    		if (c_end == -1) c_end = document.cookie.length;
//				    		return unescape(document.cookie.substring(c_start,c_end));
//				    	}
//				    }
//					return "";
			  	}
			]]></script>;
			/*FDT_IGNORE*/

    		return ExternalInterface.call(js, __name);
		}

//		public static function setSessionCookie(__name:String, __value:String = ""): void {
//
//			var js:XML;
//			/*FDT_IGNORE*/
//			js = <script><![CDATA[
//				function(__name, __value) {
//					document.cookie = escape(__name) + "=" + escape(__value) + "; path=/";
//				}
//			]]></script>;
//			/*FDT_IGNORE*/
//
//    		ExternalInterface.call(js, __name, __value);
//		}
//
//		public static function getSessionCookie(__name:String): String {
//
//			var js:XML;
//			/*FDT_IGNORE*/
//			js = <script><![CDATA[
//				function(__name) {
//					var exp = new RegExp(escape(__name) + "=([^;]+)");
//					if (exp.test (document.cookie + ";")) {
//						exp.exec (document.cookie + ";");
//						return unescape(RegExp.$1);
//					} else {
//  						return "";
//					}
//			  	}
//			]]></script>;
//			/*FDT_IGNORE*/
//
//    		return ExternalInterface.call(js, __name);
//		}
	}
}
