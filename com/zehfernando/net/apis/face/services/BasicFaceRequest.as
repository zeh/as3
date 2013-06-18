package com.zehfernando.net.apis.face.services {

	import com.zehfernando.data.serialization.json.JSON;
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.face.FaceConstants;
	import com.zehfernando.net.apis.face.events.FaceServiceEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author zeh
	 */
	public class BasicFaceRequest extends BasicServiceRequest {

		// Properties
		protected var _apiKey:String;
		protected var _apiSecret:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BasicFaceRequest() {
			super();

			requestMethod = URLRequestMethod.POST;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getURLVariables():URLVariables {
			var vars:URLVariables = super.getURLVariables();

			vars[FaceConstants.PARAMETER_NAME_API_KEY] = _apiKey;
			vars[FaceConstants.PARAMETER_NAME_API_SECRET] = _apiSecret;

			vars[FaceConstants.PARAMETER_NAME_FORMAT] = FaceConstants.PARAMETER_VALUE_FORMAT_JSON;

			return vars;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent):void {
			super.onSecurityError(e);
			dispatchEvent(new FaceServiceEvent(FaceServiceEvent.ERROR));
		}

		override protected function onIOError(e:IOErrorEvent):void {
			super.onIOError(e);
			dispatchEvent(new FaceServiceEvent(FaceServiceEvent.ERROR));
		}

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.decode(loader.data);

			if (response[FaceConstants.PARAMETER_NAME_STATUS] == FaceConstants.STATUS_FAILURE) {
				// Response is successfull, but it was instead an error
				onIOError(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, response[FaceConstants.PARAMETER_NAME_ERROR_MESSAGE]));
				return;
			}

			super.onComplete(e);
			dispatchEvent(new FaceServiceEvent(FaceServiceEvent.COMPLETE));
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get apiKey():String {
			return _apiKey;
		}
		public function set apiKey(__value:String):void {
			_apiKey = __value;
		}

		public function get apiSecret():String {
			return _apiSecret;
		}
		public function set apiSecret(__value:String):void {
			_apiSecret = __value;
		}
	}
}
