package com.zehfernando.net.apis.youtube {

	/**
	 * @author zeh
	 */
	public class YouTubeConstants {

		public static const SCHEMA_KEYWORD:String = "http://gdata.youtube.com/schemas/2007/keywords.cat";
		public static const SCHEMA_CATEGORY:String = "http://gdata.youtube.com/schemas/2007/categories.cat";

		public static const NAMESPACE_GD:String = "gd";
		public static const NAMESPACE_YT:String = "yt";
		public static const NAMESPACE_MEDIA:String = "media";

		public static const DOMAIN:String = "http://gdata.youtube.com";
		public static const SERVICE_VIDEO_INFO:String = "/feeds/api/videos/[[video_id]]";
		public static const SERVICE_USER_UPLOADS:String = "/feeds/api/users/[[user_id]]/uploads";

		public static const PARAMETER_VIDEO_ID:String = "[[video_id]]";
		public static const PARAMETER_USER_ID:String = "[[user_id]]";
	}
}
