package com.zehfernando.net.apis.twitter.data {
	import com.zehfernando.net.apis.twitter.TwitterDataUtils;

	/**
	 * @author zeh
	 */
	public class Tweet {

		// Properties
		public var id:String;
		public var profileImageURL:String;
		public var created:Date;
		public var text:String;
		//missing geo/coordinates/contributors/place
		public var resultType:String;// popular, recent
		public var source:String;
		public var fromUserId:String;
		public var fromUser:String;
		public var toUserId:String;
		public var toUser:String;
		public var language:String;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Tweet() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromStatusesJSONObject(o:Object):Tweet {
			var tweet:Tweet = new Tweet();

			tweet.profileImageURL	= o["profile_image_url"];
//			tweet.retweeted			= o["retweeted"];
//			tweet.numRetweets		= o["retweet_count"];
//			tweet.favorited			= o["favorited"];
//			tweet.truncated			= o["truncated"];
			tweet.source			= o["source"];

			//tweet.fromUser			= o["from_user"];
			//tweet.fromUserId		= o["from_user_id"];
			tweet.toUser			= o["in_reply_to_screen_name"];
			tweet.toUserId			= o["in_reply_to_user_id"];
//			tweet.inReplyTo			= o["in_reply_to_status_id"];
			tweet.id				= o["in_reply_to_status_id"];
			tweet.text				= o["in_reply_to_status_id"];
			tweet.created			= TwitterDataUtils.getStatusesResultStringAsDate(o["created_at"]);

			// User
			// Missing: coordinates, geo, contributors, place

			return tweet;

			/*
   {
	  "coordinates":null,
	  "retweeted":false,
	  "favorited":false,
	  "truncated":false,
	  "contributors":null,
	  "place":null,
	  "source":"<a href=\"http://www.tweetdeck.com\" rel=\"nofollow\">TweetDeck</a>",
	  "in_reply_to_screen_name":null,
	  "in_reply_to_user_id":null,
	  "retweet_count":0,
	  "in_reply_to_status_id":null,
	  "user":{
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
	  },
	  "id":21599331199,
	  "geo":null,
	  "text":"Confession: as long as you don't have to use Facebook Connect, Facebook's (graph) API is pretty good. Easy, efficient and straighforward.",
	  "created_at":"Thu Aug 19 18:42:23 +0000 2010"
   },
			 */
		}

		public static function fromSearchJSONObject(o:Object):Tweet {
			var tweet:Tweet = new Tweet();

			tweet.profileImageURL	= o["profile_image_url"];
			tweet.created			= TwitterDataUtils.getSearchResultStringAsDate(o["created_at"]);
			tweet.fromUser			= TwitterDataUtils.decodeHTML(o["from_user"]);
			tweet.fromUserId		= o["from_user_id"];
			tweet.toUser			= TwitterDataUtils.decodeHTML(o["to_user"]);
			tweet.toUserId			= o["to_user_id"];

			tweet.resultType		= TwitterDataUtils.decodeHTML(o["metadata"]["result_type"]);
			tweet.id				= o["id"];
			tweet.text				= TwitterDataUtils.decodeHTML(o["text"]);
			tweet.language			= o["iso_language_code"];
			tweet.source			= o["source"];

			// Missing: geo

			return tweet;

			/*
			{
				"profile_image_url":"http://a0.twimg.com/profile_images/1092781896/avatar2_normal.jpg",
				"created_at":"Mon, 16 Aug 2010 20:15:18 +0000",
				"from_user":"OneLag",
				"metadata":{"result_type":"recent"},
				"to_user_id":12872148,
				"text":"@todearaujo nao rapaz, nao to falando do meu BG, to falando de como eu uso o meu twitter mesmo",
				"id":21341803331,
				"from_user_id":201065,
				"to_user":"todearaujo",
				"geo":null,
				"iso_language_code":"pt",
				"source":"&lt;a href=&quot;http://www.tweetdeck.com&quot; rel=&quot;nofollow&quot;&gt;TweetDeck&lt;/a&gt;"
			}
			*/

			/*
			<entry>
				<id>tag:search.twitter.com,2005:19692205228</id>
				<published>2010-07-27T22:50:14Z</published>
				<link type="text/html" href="http://twitter.com/RMS_Titanic_Inc/statuses/19692205228" rel="alternate"/>
				<title>@Technotoaster  Thx!  We have a dream team on board, cutting-edge technology, terrific supporters and a noble cause.</title>
				<content type="html">&lt;a href=&quot;http://twitter.com/Technotoaster&quot;&gt;@Technotoaster&lt;/a&gt;  Thx!  We have a dream team on board, cutting-edge technology, terrific supporters and a noble cause.</content>
				<updated>2010-07-27T22:50:14Z</updated>
				<link type="image/png" href="http://a3.twimg.com/profile_images/1087754811/titanic_avatar_normal.jpg" rel="image"/>
				<twitter:geo>
				</twitter:geo>
				<twitter:metadata>
					<twitter:result_type>recent</twitter:result_type>
				</twitter:metadata>
				<twitter:source>&lt;a href=&quot;http://www.tweetdeck.com&quot; rel=&quot;nofollow&quot;&gt;TweetDeck&lt;/a&gt;</twitter:source>
				<twitter:lang>en</twitter:lang>
				<author>
					<name>RMS_Titanic_Inc (RMS Titanic, Inc.)</name>
					<uri>http://twitter.com/RMS_Titanic_Inc</uri>
				</author>
			</entry>
			*/
		}

		public static function fromSearchJSONObjectArray(o:Array):Vector.<Tweet> {
			var tweets:Vector.<Tweet> = new Vector.<Tweet>();

			if (!Boolean(o)) return tweets;

			for (var i:int = 0; i < o.length; i++) {
				tweets.push(Tweet.fromSearchJSONObject(o[i]));
			}

			return tweets;
		}
	}
}
