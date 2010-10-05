package com.zehfernando.net.apis.facebook {

	/**
	 * @author zeh
	 */
	public class FacebookConstants {

		public static const PARAMETER_AUTHOR_ID:String = "[[author_id]]";
		public static const PARAMETER_ALBUM_ID:String = "[[album_id]]";

		public static const DOMAIN:String = "https://graph.facebook.com";
		public static const SERVICE_FEED:String = "/[[author_id]]/feed";
		public static const SERVICE_ALBUM_PHOTOS:String = "/[[album_id]]/photos";
		public static const SERVICE_ALBUMS:String = "/[[author_id]]/albums";
		
		public static const SERVICE_FILE_PICTURE:String = "/[[author_id]]/picture";
	}
}