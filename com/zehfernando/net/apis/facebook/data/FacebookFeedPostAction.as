package com.zehfernando.net.apis.facebook.data {
	/**
	 * @author zeh
	 */
	public class FacebookFeedPostAction {

		// Properties
		public var name:String;
		public var link:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookFeedPostAction(__name:String = "", __link:String = "") {
			super();

			name = __name;
			link = __link;
		}
	}
}
