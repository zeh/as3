package com.zehfernando.net.apis.face.services {

	import com.zehfernando.data.serialization.json.JSON;
	import com.zehfernando.net.apis.face.FaceConstants;

	import flash.events.Event;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class FaceAccountLimitsRequest extends BasicFaceRequest {

		// Results
		protected var _used:int;
		protected var _limit:int;
		protected var _remaining:int;
		protected var _resetTime:Date;
		protected var _namespaceUsed:int;
		protected var _namespaceLimit:int;
		protected var _namespaceRemaining:int;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FaceAccountLimitsRequest() {
			super();

			// Basic service configuration
			requestURL = FaceConstants.DOMAIN + FaceConstants.SERVICE_ACCOUNT_LIMITS;

		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.decode(loader.data);

			_used					= response["usage"]["used"];
			_limit					= response["usage"]["limit"];
			_remaining				= response["usage"]["remaining"];
			_resetTime				= new Date(response["usage"]["reset_time"]);
			_namespaceUsed			= response["usage"]["namespace_used"];
			_namespaceLimit			= response["usage"]["namespace_limit"];
			_namespaceRemaining		= response["usage"]["namespace_remaining"];

			super.onComplete(e);
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Results

		public function get used():int {
			return _used;
		}

		public function get limit():int {
			return _limit;
		}

		public function get remaining():int {
			return _remaining;
		}

		public function get resetTime():Date {
			return _resetTime;
		}

		public function get namespaceUsed():int {
			return _namespaceUsed;
		}

		public function get namespaceLimit():int {
			return _namespaceLimit;
		}

		public function get namespaceRemaining():int {
			return _namespaceRemaining;
		}
	}
}
