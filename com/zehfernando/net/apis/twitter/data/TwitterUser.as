package com.zehfernando.net.apis.twitter.data {
	import com.zehfernando.net.apis.twitter.TwitterDataUtils;
	/**
	 * @author zeh
	 */
	public class TwitterUser {

		// Properties
		public var id:int;
		public var screenName:String;
		public var fullName:String;

		public var pictureURL:String;

		public var created:Date;

		public var numFriends:int;
		public var numFollowers:int;
		public var numTweets:int;
		public var numFavorites:int;

		public var timesListed:int;

		public var url:String;
		public var description:String;
		public var language:String;
		public var location:String;

		public var contributorsEnabled:Boolean;
		public var notifications:Boolean;
		public var geoEnabled:Boolean;
		public var showAllInlineMedia:Boolean;

		public var isVerified:Boolean;
		public var isProtected:Boolean;

		public var following:Boolean;
		public var followRequestSent:Boolean;

		public var timeZone:String;
		public var timeZoneOffset:Number;

		public var profileLinkColor:int;
		public var profileUseBackgroundImage:Boolean;
		public var profileSidebarFillColor:int;
		public var profileBackgroundImageURL:String;
		public var profileSidebarBorderColor:int;
		public var profileBackgroundTile:Boolean;
		public var profileBackgroundColor:int;
		public var profileTextColor:int;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TwitterUser() {
			profileLinkColor = -1;
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromStatusesJSONObject(o:Object):TwitterUser {
			var user:TwitterUser = new TwitterUser();

			user.profileImageURL	= o["profile_image_url"];
			user.created			= TwitterDataUtils.getStatusesResultStringAsDate(o["created_at"]);

			// User
			// Missing: coordinates, geo, contributors, place

			return user;
		/*
	}
{
		 "contributors_enabled":false,
		 "notifications":false,
		 "profile_link_color":"088253",
		 "description":"A technology pragmatist who writes code and does other shenanigans at @firstborn_nyc.\r\n\r\nSee @zeh_br for my Brazilian Portuguese account.",
		 "favourites_count":2,
		 "following":true,
		 "profile_use_background_image":true,
		 "time_zone":"Eastern Time (US & Canada)",
		 "profile_sidebar_fill_color":"E3E2DE",
		 "verified":false,
		 "follow_request_sent":false,
		 "profile_background_image_url":"http://a3.twimg.com/profile_background_images/98353237/columbus.jpg",
		 "profile_sidebar_border_color":"D3D2CF",
		 "geo_enabled":false,
		 "profile_image_url":"http://a1.twimg.com/profile_images/680891541/2010-02-06a_small_cropped_normal.jpg",
		 "profile_background_tile":false,
		 "profile_background_color":"717a85",
		 "protected":false,
		 "screen_name":"zeh",
		 "listed_count":102,
		 "followers_count":1207,
		 "url":"http://zehfernando.com",
		 "name":"zeh fernando",
		 "statuses_count":2452,
		 "profile_text_color":"634047",
		 "id":1971791,
		 "show_all_inline_media":false,
		 "lang":"en",
		 "utc_offset":-18000,
		 "created_at":"Fri Mar 23 03:23:53 +0000 2007",
		 "friends_count":151,
		 "location":"New York, NY"
	  }
	   */
	}
}
