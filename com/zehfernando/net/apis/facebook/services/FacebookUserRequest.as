package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookUser;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	/**
	 * @author zeh
	 */
	public class FacebookUserRequest extends BasicFacebookRequest {

		// http://developers.facebook.com/docs/reference/api/user
		// https://graph.facebook.com/711322444

		// Properties
		protected var _userId:String;

		// Parameters
		protected var _limit:int;

		// Results
		protected var _user:FacebookUser;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookUserRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_USER;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/page

			_userId = "";

		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

//		override protected function getURLVariables():URLVariables {
//			var vars:URLVariables = super.getURLVariables();
//
//			if (_limit > 0) vars["limit"] = _limit;
//
//			return vars;
//		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.parse(loader.data);

			_user = FacebookUser.fromJSONObject(response);

			super.onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function execute():void {

			// TODO: using the query parameter "ids" here instead of the normal url userId, one can get data for several users at the same time - redo this?
			// 'ids' also accept links!

			requestURL = requestURL.replace(FacebookConstants.PARAMETER_USER_ID, _userId);

			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get userId():String {
			return _userId;
		}
		public function set userId(__value:String):void {
			_userId = __value;
		}

		// Results

		public function get user(): FacebookUser {
			return _user;
		}
	}
}
