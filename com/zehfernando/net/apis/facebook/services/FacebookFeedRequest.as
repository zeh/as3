package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookFeedPost;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author zeh
	 */
	public class FacebookFeedRequest extends BasicFacebookRequest {

		// By default, this gets the last 25 posts

		// Properties
		protected var _authorId:String;

		// Parameters
		protected var _limit:int;

		// Results
		protected var _posts:Vector.<FacebookFeedPost>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookFeedRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_FEED;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/page

			_authorId = "";

		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getData():Object {
			var vars:URLVariables = super.getData() as URLVariables;

			if (_limit > 0) vars["limit"] = _limit;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.parse(loader.data);

			_posts = FacebookFeedPost.fromJSONObjectArray(response["data"]);

			super.onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function execute():void {
			requestURL = requestURL.replace(FacebookConstants.PARAMETER_AUTHOR_ID, _authorId);
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get authorId():String {
			return _authorId;
		}
		public function set authorId(__value:String):void {
			_authorId = __value;
		}

		// Hard parameters

		public function get limit():int {
			return _limit;
		}
		public function set limit(__value:int):void {
			if (_limit != __value) {
				_limit = __value;
			}
		}

		// Results

		public function get posts(): Vector.<FacebookFeedPost> {
			return _posts.concat();
		}
	}
}
