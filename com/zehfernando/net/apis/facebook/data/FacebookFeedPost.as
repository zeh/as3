package com.zehfernando.net.apis.facebook.data {
	import com.zehfernando.net.apis.facebook.FacebookDataUtils;

	/**
	 * @author zeh
	 */
	public class FacebookFeedPost {

		// http://developers.facebook.com/docs/reference/api/post
		// https://graph.facebook.com/19292868552_118464504835613

		// Properties
		public var id:String;
		public var from:FacebookAuthor;
		public var message:String;
		public var type:String; // FacebookPostType
		public var created:Date;
		public var updated:Date;
		public var likes:int;
		public var numComments:int;
		public var comments:Vector.<FacebookComment>;
		public var picture:String;			// Attachment image (for links, pictures; for videos, it's also the thumb)
		public var link:String;				// For videos, external page link; for photos, internal(?) link
		public var name:String;				// Title for attachment
		public var description:String;		// Description for attachment
		public var icon:String;				// Icon for the application that did the post
		public var source:String;			// Links to the video (embedded one)
		public var caption:String;			// Goes below "name", for videos (with link)

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookFeedPost() {
		}

		/*
	  {
		 "id": "136208713078882_146368762058100",
		 "from": {
			"name": "RMS Titanic, Inc.",
			"category": "Products_other",
			"id": "136208713078882"
		 },
		 "message": "St. John's was selected as the departure point for this expedition due to its proximity to the wreck site - Titanic lies 375 miles to the South East. Commonly referred to as the oldest city in North America, St. John's is a place with a rich and unique history.",
		 "type": "status",
		 "created_time": "2010-08-16T22:29:28+0000",
		 "updated_time": "2010-08-16T22:29:28+0000",
		 "likes": 28,
		 "comments": {
			"count": 33
		 }
	  },

		{
		 "id": "19292868552_118873641497101",
		 "from": {
			"name": "Facebook Platform",
			"category": "Technology",
			"id": "19292868552"
		 },
		 "message": "Interested in learning more about the Facebook Developer Garage program? Like the official Page to find out about upcoming events and share thoughts with fellow developers.",
		 "picture": "http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs167.ash2/41598_266673776502_2388_t.jpg",
		 "link": "http://www.facebook.com/FacebookDevGarage",
		 "name": "Facebook Developer Garage Program",
		 "description": "Immediately following the Platform launch on May 24, 2007, informal, community-driven developer events began emerging around the world. In an effort to support the ecosystem, the events, and the developers involved in them, the concept of the Facebook Developer Garage was conceived.\n\nWe hope you use this Page to collaborate with other developers, post content from your Facebook Developer Garages, and learn about upcoming events.\n\nIf you're a Garage Host and have questions, ask your fellow developers on the \"Discussions\" tab.",
		 "icon": "http://static.ak.fbcdn.net/rsrc.php/zB010/hash/9yvl71tw.gif",
		 "type": "link",
		 "created_time": "2010-08-16T22:33:24+0000",
		 "updated_time": "2010-08-17T13:57:29+0000",
		 "likes": 114,
		 "comments": {
			"data": [
			   {
				  "id": "19292868552_118873641497101_506281",
				  "from": {
					 "name": "Shanmugasundaram Ganghaa",
					 "id": "100000880244252"
				  },
				  "message": "eeeeeeeeeeee.................",
				  "created_time": "2010-08-17T11:54:20+0000"
			   },
			   {
				  "id": "19292868552_118873641497101_506934",
				  "from": {
					 "name": "Gary Ballard",
					 "id": "100001524180486"
				  },
				  "message": "hu",
				  "created_time": "2010-08-17T13:57:29+0000"
			   }
			],
			"count": 15
		 }
	  },

	  {
		 "id": "19292868552_121168791261322",
		 "from": {
			"name": "Facebook Platform",
			"category": "Technology",
			"id": "19292868552"
		 },
		 "message": "Blippy, a site integrated with Facebook, enables you to share purchases of your choosing with friends to spark interesting conversations. Find out what it's all about in this video.",
		 "picture": "http://external.ak.fbcdn.net/safe_image.php?d=1db8ca8e3c157f0dc11c0c6520bac987&w=130&h=130&url=http%3A%2F%2Fi.ytimg.com%2Fvi%2FiplMMTzoj9U%2F0.jpg",
		 "link": "http://www.youtube.com/watch?v=iplMMTzoj9U&eurl=http%3A%2F%2Fblippy.com%2F&feature=player_embedded",
		 "source": "http://www.youtube.com/v/iplMMTzoj9U&autoplay=1",
		 "name": "Blippy Salutations, Fine Sirs and Madams",
		 "caption": "www.youtube.com",
		 "description": "Blippy is a fun, free and safe site that lets you share your purchases and see what your friends are buying online and in real life. Sign up on http://blippy.com",
		 "icon": "http://static.ak.fbcdn.net/rsrc.php/z9XZ8/hash/976ulj6z.gif",
		 "type": "video",
		 "created_time": "2010-07-06T21:37:23+0000",
		 "updated_time": "2010-07-06T21:37:23+0000",
		 "likes": 101,
		 "comments": {
			"count": 39
		 }
	  },
	  {
	  // 142415832458170
		 "id": "136208713078882_142415842458169",
		 "from": {
			"name": "RMS Titanic, Inc.",
			"category": "Products_other",
			"id": "136208713078882"
		 },
		 "message": "Even by today's standards, Titanic was massive. At 250 feet in length, the RV Jean Charcot--the ship being used on Expedition Titanic--could fit within Titanic more than 3 and a half times.\n\nCopyright 2010 RMS Titanic, Inc.",
		 "picture": "http://photos-d.ak.fbcdn.net/hphotos-ak-snc4/hs298.snc4/41260_142415832458170_136208713078882_266415_2353156_s.jpg",
		 "link": "http://www.facebook.com/photo.php?pid=266415&id=136208713078882",
		 "icon": "http://static.ak.fbcdn.net/rsrc.php/z2E5Y/hash/8as8iqdm.gif",
		 "type": "photo",
		 "created_time": "2010-08-13T21:12:40+0000",
		 "updated_time": "2010-08-16T23:22:57+0000",
		 "likes": 24,
		 "comments": {
			"data": [
			   {
				  "id": "136208713078882_142415842458169_149917",
				  "from": {
					 "name": "Michael Ryan",
					 "id": "500753064"
				  },
				  "message": "naw, but this ship could fit two side by side, four long, and two high in the mary also :D",
				  "created_time": "2010-08-16T18:23:50+0000"
			   },
			   {
				  "id": "136208713078882_142415842458169_150114",
				  "from": {
					 "name": "Liam Gillan",
					 "id": "1059687858"
				  },
				  "message": "i would have loved to have experienced the titanic, yeah it was an amazing loss but yet would have been amazing",
				  "created_time": "2010-08-16T23:22:57+0000"
			   }
			],
			"count": 19
		 }



		*/

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object): FacebookFeedPost {
			if (!Boolean(o)) return null;

			var post:FacebookFeedPost = new FacebookFeedPost();

			post.id =								o["id"];
			post.from =								FacebookAuthor.fromJSONObject(o["from"]); /// *************
			post.message =							o["message"];
			post.type =								o["type"];
			post.created =							FacebookDataUtils.getResultStringAsDate(o["created_time"]);
			post.updated =							FacebookDataUtils.getResultStringAsDate(o["updated_time"]);
			post.likes =							o["likes"];
			post.numComments =						Boolean(o["comments"]) ? o["comments"]["count"] : 0;
			post.comments =							Boolean(o["comments"]) ? FacebookComment.fromJSONObjectArray(o["comments"]["data"]) : new Vector.<FacebookComment>();
			post.picture =							o["picture"];
			post.link =								o["link"];
			post.name =								o["name"];
			post.description =						o["description"];
			post.icon =								o["icon"];
			post.source =							o["source"];
			post.caption =							o["caption"];

			return post;
		}

		public static function fromJSONObjectArray(o:Array): Vector.<FacebookFeedPost> {
			var posts:Vector.<FacebookFeedPost> = new Vector.<FacebookFeedPost>();

			if (!Boolean(o)) return posts;

			for (var i:int = 0; i < o.length; i++) {
				posts.push(FacebookFeedPost.fromJSONObject(o[i]));
			}

			return posts;
		}
	}
}
