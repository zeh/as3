package com.zehfernando.net.apis.facebook.data {

	/**
	 * @author zeh
	 */
	public class FacebookPage extends FacebookAuthor {

		// http://developers.facebook.com/docs/reference/api/page

		// http://graph.facebook.com/rmstitanicinc
		// http://graph.facebook.com/platform

		// Properties
		public var category:String;

		public var link:String;
		public var username:String;
		public var companyOverview:String;
		public var mission:String;
		public var products:String;
		public var fanCount:int;
		public var founded:String;					// Date?

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookPage() {
			super();
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function fromJSONObject(o:Object): FacebookPage {
			if (!Boolean(o)) return null;

			var page:FacebookPage = new FacebookPage();

			page.id =										o["id"];
			page.name =										o["name"];

			page.category =									o["category"];

			page.picture =									o["picture"]; // Manual setup if supplied
			page.link =										o["link"];
			page.username =									o["username"];
			page.companyOverview =							o["companyOverview"];
			page.mission =									o["mission"];
			page.products =									o["products"];
			page.fanCount =									o["fanCount"];
			page.founded =									o["founded"];
			page.category =									o["category"];

			return page;
		}
	}
}
