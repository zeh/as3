package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class FacebookAlbumCreateRequest extends BasicFacebookRequest {

		// https://developers.facebook.com/docs/reference/api/album/

		// Properties
		protected var _name:String;					// Album name (required)
		protected var _description:String;			// Album description
		protected var _location:String;				// Album location
		protected var _privacy:String;				// Album privacy: everyone (default) (FacebookPrivacyType)
		protected var _type:String;					// Album type: profile, mobile, wall, normal (default) or album (FacebookAlbumType)

		// Results
		protected var _albumId:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookAlbumCreateRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_ALBUMS;
			requestMethod = URLRequestMethod.POST;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/post/

			_name = "";
			_description = "";
			_location = "";
			_privacy = "";
			_type = "";
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getData():Object {
			var vars:URLVariables = super.getData() as URLVariables;

			if (Boolean(_name))				vars["name"] = _name;
			if (Boolean(_description))		vars["description"] = _description;
			if (Boolean(_location))			vars["location"] = _location;
			if (Boolean(_privacy))			vars["privacy"] = _privacy;
			if (Boolean(_type))				vars["type"] = _type;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.parse(loader.data);

			_albumId = response["id"];

			super.onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function execute():void {
			requestURL = requestURL.replace(FacebookConstants.PARAMETER_AUTHOR_ID, FacebookConstants.ID_USER_OWN);
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get name():String {
			return _name;
		}
		public function set name(__value:String):void {
			_name = __value;
		}

		public function get description():String {
			return _description;
		}
		public function set description(__value:String):void {
			_description = __value;
		}

		public function get location():String {
			return _location;
		}
		public function set location(__value:String):void {
			_location = __value;
		}

		public function get privacy():String {
			return _privacy;
		}
		public function set privacy(__value:String):void {
			_privacy = __value;
		}

		public function get type():String {
			return _type;
		}
		public function set type(__value:String):void {
			_type = __value;
		}

		// Results

		public function get albumId():String {
			return _albumId;
		}


	}
}
