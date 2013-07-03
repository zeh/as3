package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookPhoto;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * @author zeh
	 */
	public class FacebookUserPhotosRequest extends BasicFacebookRequest {

		// http://developers.facebook.com/docs/reference/api/user
		// https://graph.facebook.com/711322444

		// Requires the user_photo_video_tags, friend_photo_video_tags, user_photos or friend_photos permissions
		// https://graph.facebook.com/me/photos?access_token=2227470867|2.AtoDa6J_7K5Mhbs8Z__htQ__.3600.1295989200-711322444|Ocyc32KDWSciM_ALC1BeQVLQd5w

		// Properties
		protected var _userId:String;

		// Parameters
		protected var _limit:int;

		// Results
		protected var _photos:Vector.<FacebookPhoto>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookUserPhotosRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_USER_PHOTOS;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/user

			_userId = "";

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

			_photos = FacebookPhoto.fromJSONObjectArray(response["data"]);

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
		public function set userId(__value: String):void {
			_userId = __value;
		}

		public function get limit():int {
			return _limit;
		}
		public function set limit(__value:int):void {
			_limit = __value;
		}

		// Results

		public function get photos(): Vector.<FacebookPhoto> {
			return _photos.concat();
		}
	}
}
