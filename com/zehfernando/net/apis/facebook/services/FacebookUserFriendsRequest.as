package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookUser;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * @author zeh
	 */
	public class FacebookUserFriendsRequest extends BasicFacebookRequest {

		// http://developers.facebook.com/docs/reference/api/user
		// https://graph.facebook.com/711322444

		// Properties
		protected var _userId:String;
		protected var _fields:Vector.<String>;

		// Parameters
		protected var _limit:int;

		// Results
		protected var _friends:Vector.<FacebookUser>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookUserFriendsRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_USER_FRIENDS;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/user

			_userId = "";
			_fields = new Vector.<String>();

		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getData():Object {
			var vars:URLVariables = super.getData() as URLVariables;

			if (_limit > 0) vars[FacebookConstants.PARAMETER_LIMIT_NAME] = _limit;
			if (_fields.length > 0) vars[FacebookConstants.PARAMETER_FIELDS_NAME] = _fields.join(FacebookConstants.PARAMETER_LIST_SEPARATOR);

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.parse(loader.data);

			_friends = FacebookUser.fromJSONObjectArray(response["data"]);

			super.onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function execute():void {

			// TODO: using the query parameter "ids" here instead of the normal url userId, one can get data for several users at the same time - redo this?
			// 'ids' also accept links!
			// TODO: test whether one can get data for several different users for /friends too

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

		public function get fields():Vector.<String> {
			return _fields; // id, name, location
		}
		public function set fields(__value:Vector.<String>):void {
			_fields = __value;
		}

		// Results

		public function get friends(): Vector.<FacebookUser> {
			return _friends.concat();
		}
	}
}
