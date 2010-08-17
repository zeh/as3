package com.zehfernando.net.apis.facebook.services {
	import com.adobe.serialization.json.JSON;
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookFeedPost;
	import com.zehfernando.net.apis.facebook.events.FacebookServiceEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestMethod;

	/**
	 * @author zeh
	 */
	public class FacebookFeedRequest extends BasicServiceRequest {
		
		// By default, this gets the last 25 posts

		// Properties
		protected var _id:String;
		
		// Results
		protected var _posts:Vector.<FacebookFeedPost>;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookFeedRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.DOMAIN + FacebookConstants.SERVICE_FEED;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/page

			_id = "";
			
			
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

//		override protected function getURLVariables():URLVariables {
//			var vars:URLVariables = super.getURLVariables();
//
//			return vars;
//		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent): void {
			//trace ("twitter --> onSecurityError");
			super.onSecurityError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}
		
		override protected function onIOError(e:IOErrorEvent): void {
			//trace ("twitter --> onIOError");
			super.onIOError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}

		override protected function onComplete(e:Event): void {
			//trace ("twitter --> onComplete");

			var response:Object = JSON.decode(loader.data);
			
			_posts = FacebookFeedPost.fromJSONObjectArray(response["data"]);
			
			super.onComplete(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.COMPLETE));
		}

		
		override public function execute():void {
			requestURL = requestURL.replace(FacebookConstants.PARAMETER_AUTHOR_ID, _id);
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get id():String {
			return _id;
		}
		public function set id(__value:String):void {
			_id = __value;
		}
		
		// Results
		
		public function get posts(): Vector.<FacebookFeedPost> {
			return _posts.concat();
		}
	}
}
