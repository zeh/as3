package com.zehfernando.net.apis.parse.services {
	import com.zehfernando.net.apis.parse.ParseConstants;

	import flash.net.URLRequestMethod;

	/**
	 * @author zeh fernando
	 */
	public class ParseObjectPutRequest extends BasicParseRequest {

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ParseObjectPutRequest(__className:String, __objectId:String) {
			super();

			requestURL = ParseConstants.DOMAIN + "/1/classes/" + __className + "/" + __objectId;
			requestMethod = URLRequestMethod.PUT;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getData():Object {
			return '{"title_put": "Hello World"}';
		}

	}
}
