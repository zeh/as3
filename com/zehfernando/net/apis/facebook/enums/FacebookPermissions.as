package com.zehfernando.net.apis.facebook.enums {
	/**
	 * @author zeh
	 */
	public class FacebookPermissions {

		// Full list: http://developers.facebook.com/docs/authentication/permissions
		// Must be asked during login! http://developers.facebook.com/docs/authentication/

		public static const READ_STREAM:String = "read_stream";								// Provides access to all the posts in the user's News Feed and enables your application to perform searches against the user's News Feed

		public static const USER_PHOTO_VIDEO_TAGS:String = "user_photo_video_tags";			// Provides access to the photos the user has been tagged in as the `photos` connection
		public static const FRIENDS_PHOTO_VIDEO_TAGS:String = "friends_photo_video_tags";

		public static const USER_PHOTOS:String = "user_photos";								// Provides access to the photos the user has uploaded
		public static const FRIENDS_PHOTOS:String = "friends_photos";

		public static const USER_LOCATION:String = "user_location";							// Provides access to the user's current location as the location property
		public static const FRIENDS_LOCATION:String = "friends_location";

		public static const PUBLISH_STREAM:String = "publish_stream";						// Enables your application to post content, comments, and likes to a user's stream and to the streams of the user's friends. With this permission, you can publish content to a user's feed at any time, without requiring offline_access. However, please note that Facebook recommends a user-initiated sharing model.

	}
}
