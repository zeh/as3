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

		protected var urlRequest:URLRequest;

		protected var requestURL:String;
		protected var requestMethod:String;
		protected var requestContentType:String;

		protected var _isLoading:Boolean;
		protected var _isLoaded:Boolean;

		protected var _rawResponse:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BasicServiceRequest() {

			requestURL = "";
			requestMethod = URLRequestMethod.GET;
			requestContentType = "application/x-www-form-urlencoded"; // Default

			_isLoading = false;
			_isLoaded = false;
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function getData():Object {
			// Returns the URLVariables needed by this request
			var vars:URLVariables = new URLVariables();
			return vars;
		}

		protected function getRequestHeaders(): Array {
			// Returns the request headers needed by this request
			var headers:Array = [];
			//headers.push(new URLRequestHeader("Content-type", "application/x-www-form-urlencoded"));
			//headers.push(new URLRequestHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"));
			return headers;
		}

		protected function clearData():void {
			// Clear all the loaded data
			if (_isLoaded) {
				_isLoaded = false;
			}
		}

		protected function stopLoading():void {
			// Stop loading everything
			if (_isLoading) {
				loader.close();
				_isLoading = false;
				removeLoader();
			}
		}

		protected function removeLoader():void {
			loader.removeEventListener(Event.COMPLETE, innerOnComplete);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, innerOnIOError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, innerOnSecurityError);
			loader = null;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onHTTPStatus(e:HTTPStatusEvent):void {
		}

		protected function onSecurityError(e:SecurityErrorEvent):void {
			_rawResponse = loader.data;

			_isLoading = false;
			removeLoader();
		}

		protected function innerOnSecurityError(e:SecurityErrorEvent):void {
			onSecurityError(e);
		}

		protected function onIOError(e:IOErrorEvent):void {
			_rawResponse = loader.data;

			_isLoading = false;
			removeLoader();
		}

		protected function innerOnIOError(e:IOErrorEvent):void {
			onIOError(e);
		}

		protected function onComplete(e:Event):void {
			_rawResponse = loader.data;

			_isLoading = false;
			_isLoaded = true;
			removeLoader();
		}

		protected function innerOnComplete(e:Event):void {
			onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function execute():void {

			if (_isLoading) stopLoading();
			if (_isLoaded) clearData();

			urlRequest = new URLRequest();

			urlRequest.url = requestURL;
			urlRequest.method = requestMethod;
			urlRequest.data = getData();
			urlRequest.requestHeaders = getRequestHeaders();
			urlRequest.contentType = requestContentType;

			loader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, innerOnIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, innerOnSecurityError);
			loader.addEventListener(Event.COMPLETE, innerOnComplete);
			// Event.OPEN, ProgressEvent.PROGRESS
			loader.load(urlRequest);
		}

		public function dispose():void {
			if (_isLoading) stopLoading();
			if (_isLoaded) clearData();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get rawResponse():String {
			return _rawResponse;
		}

		public function get rawRequest():Object {
			return urlRequest.data;
		}

		public function get isLoading():Boolean {
			return _isLoading;
		}

		public function get isLoaded():Boolean {
			return _isLoaded;
		}

	}
}
