package com.zehfernando.net.apis.parse.services {
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.parse.ParseConstants;
	import com.zehfernando.net.apis.parse.events.ParseServiceEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	/**
	 * @author zeh fernando
	 */
	public class BasicParseRequest extends BasicServiceRequest {

		// Properties
		protected var _applicationId:String;
		protected var _restAPIKey:String;

		protected var _response:Object;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BasicParseRequest() {
			super();

			requestURL = ParseConstants.DOMAIN;
			requestMethod = URLRequestMethod.POST;
			requestContentType = "application/json";
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getData():Object {
			return "";
		}

		override protected function getRequestHeaders():Array {
			// Returns the request headers needed by this request
			var headers:Array = [];
			headers.push(new URLRequestHeader("X-Parse-Application-Id", _applicationId));
			headers.push(new URLRequestHeader("X-Parse-REST-API-Key", _restAPIKey));
			return headers;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent):void {
			super.onSecurityError(e);
			dispatchEvent(new ParseServiceEvent(ParseServiceEvent.ERROR));
		}

		override protected function onIOError(e:IOErrorEvent):void {
			super.onIOError(e);
			dispatchEvent(new ParseServiceEvent(ParseServiceEvent.ERROR));
		}

		override protected function onComplete(e:Event):void {
			_response = JSON.parse(loader.data);
			// {"createdAt":"2013-06-02T01:34:10.542Z","objectId":"VXPbC2gzcw"}

//			if (response[FaceConstants.PARAMETER_NAME_STATUS] == FaceConstants.STATUS_FAILURE) {
//				// Response is successfull, but it was instead an error
//				onIOError(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, response[FaceConstants.PARAMETER_NAME_ERROR_MESSAGE]));
//				return;
//			}

			super.onComplete(e);
			dispatchEvent(new ParseServiceEvent(ParseServiceEvent.COMPLETE));
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get applicationId():String {
			return _applicationId;
		}
		public function set applicationId(__value:String):void {
			_applicationId = __value;
		}

		public function get restAPIKey():String {
			return _restAPIKey;
		}
		public function set restAPIKey(__value:String):void {
			_restAPIKey = __value;
		}

		public function get response():Object {
			return _response;
		}
	}
}
