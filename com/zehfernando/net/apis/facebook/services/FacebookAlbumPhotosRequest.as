package com.zehfernando.net.apis.facebook.services {
	import com.adobe.serialization.json.JSON;
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.net.apis.facebook.data.FacebookPhoto;
	import com.zehfernando.net.apis.facebook.events.FacebookServiceEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author zeh
	 */
	public class FacebookAlbumPhotosRequest extends BasicServiceRequest {
		
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
			requestURL = FacebookConstants.DOMAIN + FacebookConstants.SERVICE_ALBUM_PHOTOS;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/page

			_albumId = "";
			
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getURLVariables():URLVariables {
			var vars:URLVariables = super.getURLVariables();

			if (_limit > 0)					vars["limit"] = _limit;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent): void {
			super.onSecurityError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}
		
		override protected function onIOError(e:IOErrorEvent): void {
			super.onIOError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}

		override protected function onComplete(e:Event): void {
			var response:Object = JSON.decode(loader.data);
			
			_photos = FacebookPhoto.fromJSONObjectArray(response["data"]);
			
			super.onComplete(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.COMPLETE));
		}

		
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
		
		public function get limit(): int {
			return _limit;
		}
		public function set limit(__value:int): void {
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
