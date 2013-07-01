package com.zehfernando.net.apis.bitly.services {
	import com.zehfernando.net.apis.bitly.events.BitLyEvent;
	import com.zehfernando.net.apis.bitly.BitLyConstants;
	import com.zehfernando.net.apis.bitly.data.BitLyShortURL;
	import com.zehfernando.utils.XMLUtils;

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
	public class BitLyShortenRequest extends EventDispatcher {

		// Properties
		public var login:String;
		public var apiKey:String;
		public var longURL:String;

		protected var loader:URLLoader;

		protected var _isLoading:Boolean;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function BitLyShortenRequest() {
			// TODO: must extend BasicServiceRequest!
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function execute():void {

			var req:URLRequest = new URLRequest();

			req.url = BitLyConstants.DOMAIN + BitLyConstants.SERVICE_SHORTEN;
			req.method = URLRequestMethod.GET;

			var vars:URLVariables = new URLVariables();

			vars["login"] = login;
			vars["apiKey"] = apiKey;
			vars["longUrl"] = longURL;
			vars["format"] = "xml";

			// http://code.google.com/p/bitly-api/wiki/ApiDocumentation
			// Missing: .domain, .x_login, .x_apiKey

			req.data = vars;

			loader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.addEventListener(Event.COMPLETE, onComplete);
			// Event.OPEN, ProgressEvent.PROGRESS
			loader.load(req);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function clearLoader():void {
			loader.removeEventListener(Event.COMPLETE, onComplete);
			loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader = null;
			_isLoading = false;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onHTTPStatus(e:HTTPStatusEvent):void {
			// Useless: always gets 200?
//			trace ("--> bit.ly -> onHTTPStatus");
//			trace ("--> " + e.status);
		}

		protected function onSecurityError(e:SecurityErrorEvent):void {
//			trace ("--> bit.ly -> onSecurityError");
			dispatchEvent(new BitLyEvent(BitLyEvent.ERROR));
			clearLoader();
		}

		protected function onIOError(e:IOErrorEvent):void {
//			trace ("--> bit.ly -> onIOError");
			dispatchEvent(new BitLyEvent(BitLyEvent.ERROR));
			clearLoader();
		}

		protected function onComplete(e:Event):void {
//			trace ("--> bit.ly -> onComplete");

			var response:XML = new XML(loader.data);

			var statusTxt:String = XMLUtils.getNodeAsString(response, "status_txt", "");
			var statusCode:int = XMLUtils.getNodeAsInt(response, "status_code", 0);

			var ble:BitLyEvent;

			if (statusCode == BitLyConstants.STATUS_CODE_SUCCESS) {
				var dataXML:XML = response.child("data")[0];
				var shortURL:BitLyShortURL = new BitLyShortURL();
				shortURL.url = XMLUtils.getNodeAsString(dataXML, "url");
				shortURL.hash = XMLUtils.getNodeAsString(dataXML, "hash");
				shortURL.globalHash = XMLUtils.getNodeAsString(dataXML, "global_hash");
				shortURL.longURL = XMLUtils.getNodeAsString(dataXML, "long_url");
				shortURL.newHash = XMLUtils.getNodeAsString(dataXML, "new_hash") == "1";

				ble = new BitLyEvent(BitLyEvent.SUCCESS, false, false, shortURL, statusCode, statusTxt);
			} else {
				ble = new BitLyEvent(BitLyEvent.ERROR, false, false, null, statusCode, statusTxt);
			}

			dispatchEvent(ble);

			clearLoader();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function dispose():void {
			if (_isLoading) {
				loader.close();
				clearLoader();
			}
		}
	}
}
