package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookFeedPost;
	import com.zehfernando.utils.console.log;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class FacebookFeedItemRequest extends BasicFacebookRequest {

		// Gets data on one single wall item

		// Properties
		protected var _itemId:String;

		// Results
		protected var _item:FacebookFeedPost;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookFeedItemRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_FEED_ITEM;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/page

			_itemId = "";

		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.parse(loader.data);

			log ("--> " + response);
			//_item = FacebookFeedPost.fromJSONObject(response["data"]);

			super.onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function execute():void {
			requestURL = requestURL.replace(FacebookConstants.PARAMETER_ITEM_ID, _itemId);
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get itemId():String {
			return _itemId;
		}
		public function set itemId(__value:String):void {
			_itemId = __value;
		}

		// Results

		public function get item(): FacebookFeedPost {
			return _item;
		}
	}
}
