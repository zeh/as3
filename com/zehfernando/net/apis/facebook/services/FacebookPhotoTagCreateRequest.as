package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class FacebookPhotoTagCreateRequest extends BasicFacebookRequest {

		// https://developers.facebook.com/docs/reference/api/photo/
		// Requires publish_stream and user_photos

		// Properties
		protected var _userId:String;
		protected var _photoId:String;
		protected var _x:Number;					// 0-1
		protected var _y:Number;					// 0-1

		// Results
		//protected var _albumId:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookPhotoTagCreateRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_PHOTO_TAG_CREATE;
			requestMethod = URLRequestMethod.POST;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/post/

			_userId = "";
			_photoId = "";
			_x = 0.5;
			_y = 0.5;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getData():Object {
			var vars:URLVariables = super.getData() as URLVariables;

			if (Boolean(_userId)) vars["to"] = _userId;
			vars["x"] = Math.round(_x * 100);
			vars["y"] = Math.round(_y * 100);

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event):void {
			//var response:Object = JSON.decode(loader.data);

			super.onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function execute():void {
			requestURL = requestURL.replace(FacebookConstants.PARAMETER_PHOTO_ID, _photoId);
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

		public function get photoId():String {
			return _photoId;
		}
		public function set photoId(__value:String):void {
			_photoId = __value;
		}

		public function get x():Number {
			return _x;
		}
		public function set x(__value:Number):void {
			_x = __value;
		}

		public function get y():Number {
			return _y;
		}
		public function set y(__value:Number):void {
			_y = __value;
		}
	}
}
