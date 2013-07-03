package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookUser;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * @author zeh
	 */
	public class FacebookUsersRequest extends BasicFacebookRequest {

		// Properties
		protected var _userIds:Vector.<String>;

		// TODO: THIS IS NOT USED NOW

		// Parameters
		protected var _limit:int;

		// Results
		protected var _users:Vector.<FacebookUser>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookUsersRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_USERS;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/page

			_userIds = new Vector.<String>();

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

		override protected function getData():Object {
			var vars:URLVariables = super.getData() as URLVariables;

			vars[FacebookConstants.PARAMETER_IDS_NAME] = _userIds.join(FacebookConstants.PARAMETER_LIST_SEPARATOR);

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.parse(loader.data);

			_users = FacebookUser.fromJSONObjectObject(response);

			super.onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function execute():void {
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get userIds(): Vector.<String> {
			return _userIds;
		}
		public function set userIds(__value:Vector.<String>):void {
			_userIds = __value;
		}

		// Results

		public function get users(): Vector.<FacebookUser> {
			return _users;
		}
	}
}
