package com.zehfernando.net.apis {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author zeh
	 */
	public class BasicServiceRequest extends EventDispatcher {

		// Properties
		protected var loader:URLLoader;

		protected var requestURL:String;
		protected var requestMethod:String;

		protected var _isLoading:Boolean;
		protected var _isLoaded:Boolean;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BasicServiceRequest() {

			requestURL = "";
			requestMethod = URLRequestMethod.GET;

			_isLoading = false;
			_isLoaded = false;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function getURLVariables(): URLVariables {
			// Returns the URLVariables needed by this request
			var vars:URLVariables = new URLVariables();
			return vars;
		}

		protected function clearData(): void {
			// Clear all the loaded data
			if (_isLoaded) {
				_isLoaded = false;
			}
		}

		protected function stopLoading(): void {
			// Stop loading everything
			if (_isLoading) {
				loader.close();
				_isLoading = false;
				removeLoader();
			}
		}

		protected function removeLoader(): void {
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader = null;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onHTTPStatus(e:HTTPStatusEvent): void {
		}

		protected function onSecurityError(e:SecurityErrorEvent): void {
			_isLoading = false;
			removeLoader();
		}

		protected function onIOError(e:IOErrorEvent): void {
			_isLoading = false;
			removeLoader();
		}

		protected function onComplete(e:Event): void {
			_isLoading = false;
			_isLoaded = true;
			removeLoader();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function execute(): void {

			if (_isLoading) stopLoading();
			if (_isLoaded) clearData();

			var vars:URLVariables = getURLVariables();

			var req:URLRequest = new URLRequest();

			req.url = requestURL;
			req.method = requestMethod;
			req.data = vars;

			req.requestHeaders = new Array();
			//req.requestHeaders.push(new URLRequestHeader("Content-type", "application/x-www-form-urlencoded"));
			//req.requestHeaders.push(new URLRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"));

			loader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.addEventListener(Event.COMPLETE, onComplete);
			// Event.OPEN, ProgressEvent.PROGRESS
			loader.load(req);
		}

		public function dispose():void {
			if (_isLoading) stopLoading();
			if (_isLoaded) clearData();
		}
	}
}
