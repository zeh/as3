package com.zehfernando.net.apis.facebook.data {

	import com.zehfernando.net.apis.facebook.FacebookDataUtils;
	/**
	 * @author zeh
	 */
	public class FacebookTag {

		/*
		"tags": {
   			"data": [
		   		{
					"id": "711322444",
					"name": "Zeh Fernando",
					"x": 50,
					"y": 49,
					"created_time": "2011-01-24T00:11:19+0000"
				},
				{
					"id": "13610420",
					"name": "Meagan Palatino",
					"x": 37,
					"y": 40,
					"created_time": "2011-01-24T00:11:19+0000"
				}
			]
		},
		*/

		// Properties
		public var id:String;
		public var name:String;
		public var x:int;			// From 0-100
		public var y:int;			// From 0-100
		public var created:Date;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookTag() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object): FacebookTag {
			if (!Boolean(o)) return null;

			var tag:FacebookTag = new FacebookTag();

			tag.id =										o["id"];
			tag.name =										o["name"];
			tag.x =											o["x"];
			tag.y =											o["y"];
			tag.created=									FacebookDataUtils.getResultStringAsDate(o["created_time"]);

			return tag;
		}

		public static function fromJSONObjectArray(o:Array): Vector.<FacebookTag> {
			var tags:Vector.<FacebookTag> = new Vector.<FacebookTag>();

			if (!Boolean(o)) return tags;

			for (var i:int = 0; i < o.length; i++) {
				tags.push(FacebookTag.fromJSONObject(o[i]));
			}

			return tags;
		}
	}
}
