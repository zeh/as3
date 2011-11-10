package com.zehfernando.net.apis.face.services {
	import com.zehfernando.data.serialization.json.JSON;
	import com.zehfernando.net.apis.face.FaceConstants;
	import com.zehfernando.net.apis.face.data.FacePhoto;

	import flash.events.Event;
	import flash.net.URLVariables;
	/**
	 * @author zeh
	 */
	public class FaceFacesDetectRequest extends BasicFaceRequest {
		
		// Properties
		protected var _urls:Vector.<String>;
		protected var _attributes:Vector.<String>;
		
		// Results
		protected var _photos:Vector.<FacePhoto>;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FaceFacesDetectRequest() {
			super();

			// Basic service configuration
			requestURL = FaceConstants.DOMAIN + FaceConstants.SERVICE_FACES_DETECT;

			// Parameters
			// http://developers.face.com/docs/api/faces-detect/
			_urls = new Vector.<String>();
			_attributes = new Vector.<String>();
			
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getURLVariables():URLVariables {
			var vars:URLVariables = super.getURLVariables();

			if (_urls.length > 0) vars[FaceConstants.PARAMETER_NAME_URLS] = _urls.join(FaceConstants.PARAMETER_LIST_CONCATENATOR);
			if (_attributes.length > 0) vars[FaceConstants.PARAMETER_NAME_ATTRIBUTES] = _attributes.join(FaceConstants.PARAMETER_LIST_CONCATENATOR);

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event): void {
			var response:Object = JSON.decode(loader.data);
			
			_photos = FacePhoto.fromJSONObjectArray(response["photos"]);
			
			super.onComplete(e);
		}

		
		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get urls():Vector.<String> {
			return _urls;
		}
		public function set urls(__value:Vector.<String>):void {
			_urls = __value;
		}

		public function get attributes():Vector.<String> {
			return _attributes;
		}
		public function set attributes(__value:Vector.<String>):void {
			_attributes = __value;
		}

		// Results
		
		public function get photos(): Vector.<FacePhoto> {
			return _photos.concat();
		}
	}
}
