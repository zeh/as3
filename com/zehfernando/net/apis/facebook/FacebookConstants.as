package com.zehfernando.net.apis.facebook {
	import flash.system.Security;
	/**
	 * @author zeh
	 */
	public class FacebookConstants {

		public static const PARAMETER_AUTHOR_ID:String = "[[author_id]]";
		public static const PARAMETER_USER_ID:String = "[[user_id]]";
		public static const PARAMETER_ALBUM_ID:String = "[[album_id]]";
		
		public static const PARAMETER_APP_ID:String = "[[app_id]]";
		public static const PARAMETER_REDIRECT_URL:String = "[[redirect_url]]";

		public static const SERVICE_DOMAIN:String = "https://graph.facebook.com";
		public static const SERVICE_FEED:String = "/[[author_id]]/feed";
		public static const SERVICE_ALBUMS:String = "/[[author_id]]/albums";
		public static const SERVICE_ALBUM_PHOTOS:String = "/[[album_id]]/photos";
		public static const SERVICE_USER:String = "/[[user_id]]";
		
		public static const SERVICE_FILE_PICTURE:String = "/[[author_id]]/picture";
		
		public static const AUTHORIZE_URL:String = "https://graph.facebook.com/oauth/authorize?client_id=[[app_id]]&redirect_uri=[[redirect_url]]&type=user_agent&display=popup";
		
		// Initializations
		
		{
			Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");
		}
		
		//https://graph.facebook.com/oauth/authorize?client_id=147149585329358&redirect_uri=http://www.facebook.com/connect/login_success.html&type=user_agent&display=popup
	}
}