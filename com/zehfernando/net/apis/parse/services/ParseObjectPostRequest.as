package com.zehfernando.net.apis.parse.services {
	import com.zehfernando.net.apis.parse.ParseConstants;

	import flash.net.URLRequestMethod;

	/**
	 * @author zeh fernando
	 */
	public class ParseObjectPostRequest extends BasicParseRequest {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ParseObjectPostRequest(__className:String) {
			super();

			requestURL = ParseConstants.DOMAIN + "/1/classes/" + __className;
			requestMethod = URLRequestMethod.POST;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getData():Object {
			return '{"title_post": "Oh hai there"}';
		}
	}
}
