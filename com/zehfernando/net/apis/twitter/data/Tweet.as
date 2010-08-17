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
		//protected var geo:String;
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
			id = "";
			profileImageURL = "";
			created = new Date();
			text = "";
			resultType = "";
			source = "";
			fromUserId = "";
			fromUser = "";
			toUserId = "";
			toUser = "";
			language = "";
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object):Tweet {
			var tweet:Tweet = new Tweet();
			
			tweet.profileImageURL	= o["profile_image_url"];
			tweet.created			= TwitterDataUtils.getResultStringAsDate(o["created_at"]);
			tweet.fromUser			= o["from_user"];
			tweet.fromUserId		= o["from_user_id"];
			tweet.toUser			= o["to_user"];
			tweet.toUserId			= o["to_user_id"];
			
			tweet.text				= o["text"];
			tweet.resultType		= o["metadata"]["result_type"];
			tweet.id				= o["id"];
			tweet.text				= o["text"];
			tweet.language			= o["iso_language_code"];
			tweet.source			= o["source"];

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

		public static function fromJSONObjectArray(o:Array):Vector.<Tweet> {
			var tweets:Vector.<Tweet> = new Vector.<Tweet>();

			if (!Boolean(o)) return tweets;

			for (var i:int = 0; i < o.length; i++) {
				tweets.push(Tweet.fromJSONObject(o[i]));
			}

			return tweets;
		}
	}
}
