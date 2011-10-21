package com.zehfernando.net.apis.bitly {

	/**
	 * @author zeh
	 */
	public class BitLyConstants {

		public static const STATUS_CODE_SUCCESS:int = 200;
		public static const STATUS_CODE_ERROR_RATE_LIMITING:int = 403;
		public static const STATUS_CODE_ERROR_REQUEST:int = 500;
		public static const STATUS_CODE_ERROR_UNKNOWN:int = 503;

		public static const DOMAIN:String = "http://api.bit.ly";
		public static const SERVICE_SHORTEN:String = "/v3/shorten";

	}
}
