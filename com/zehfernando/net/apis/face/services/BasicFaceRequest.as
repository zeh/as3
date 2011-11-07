package com.zehfernando.net.apis.face.services {
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.face.FaceConstants;
	import com.zehfernando.net.apis.facebook.events.FacebookServiceEvent;

	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
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

		override protected function onSecurityError(e:SecurityErrorEvent): void {
			super.onSecurityError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}
		
		override protected function onIOError(e:IOErrorEvent): void {
			super.onIOError(e);
			dispatchEvent(new FacebookServiceEvent(FacebookServiceEvent.ERROR));
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get apiKey(): String {
			return _apiKey;
		}
		public function set apiKey(__value:String): void {
			_apiKey = __value;
		}
		
		public function get apiSecret(): String {
			return _apiSecret;
		}
		public function set apiSecret(__value:String): void {
			_apiSecret = __value;
		}
	}
}
