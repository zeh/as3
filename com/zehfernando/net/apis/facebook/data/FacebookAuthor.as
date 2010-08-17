package com.zehfernando.net.apis.facebook.data {

	/**
	 * @author zeh
	 */
	public class FacebookAuthor {

		// Properties		
		public var id:String;
		public var name:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookAuthor() {
		}

		// ================================================================================================================
		// STATIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public static function fromJSONObject(o:Object): FacebookAuthor {
			if (!Boolean(o)) return null;
			
			var author:FacebookAuthor;
			
			if (Boolean(o["category"])) {
				// It's a page
				author = FacebookPage.fromJSONObject(o);
			} else {
				// It's a normal user
				author = FacebookUser.fromJSONObject(o);
			}

			return author;
		}
	}
}
