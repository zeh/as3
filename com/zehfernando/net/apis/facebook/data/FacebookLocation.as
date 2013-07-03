package com.zehfernando.net.apis.facebook.data {

	/**
	 * @author zeh
	 */
	public class FacebookLocation {

		// https://graph.facebook.com/112047398814697
		// https://graph.facebook.com/108424279189115

		// Properties
		public var id:String;
		public var name:String;
		public var link:String;
		public var category:String;
		public var isCommunityPage:Boolean;
		public var description:String;
		public var fanCount:int;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookLocation() {
			super();
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object): FacebookLocation {
			if (!Boolean(o)) return null;

			var location:FacebookLocation = new FacebookLocation();

			location.id =								o["id"];
			location.name =								o["name"];
			location.link =								o["link"];
			location.category =							o["category"];
			location.isCommunityPage =					Boolean(o["is_community_page"]);
			location.description =						o["description"];
			location.fanCount =							o["fan_count"];

			return location;
		}
	}
}
