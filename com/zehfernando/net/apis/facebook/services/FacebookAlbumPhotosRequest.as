package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookPhoto;

	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author zeh
	 */
	public class FacebookAlbumPhotosRequest extends BasicFacebookRequest {

		// http://developers.facebook.com/docs/reference/api/photo
		// http://developers.facebook.com/docs/reference/api/album

		// https://graph.facebook.com/143423629024057/photos

		// Properties
		protected var _albumId:String;

		// Parameters
		protected var _limit:int;

		// Results
		protected var _photos:Vector.<FacebookPhoto>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookAlbumPhotosRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_ALBUM_PHOTOS;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/page

			_albumId = "";

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
			requestURL = requestURL.replace(FacebookConstants.PARAMETER_ALBUM_ID, _albumId);
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get albumId():String {
			return _albumId;
		}
		public function set albumId(__value:String):void {
			_albumId = __value;
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

		public function get photos(): Vector.<FacebookPhoto> {
			return _photos.concat();
		}
	}
}
