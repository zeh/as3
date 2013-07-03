package com.zehfernando.net.apis.facebook.services {
	import com.zehfernando.net.apis.facebook.FacebookConstants;
	import com.zehfernando.utils.console.log;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class FacebookPhotoCreateRequest extends BasicFacebookRequest {

		// https://developers.facebook.com/docs/reference/api/album/
		// Requires publish_stream
		// Posts a photo to either an album or a user automatically

		// Properties
		protected var _targetId:String;
		protected var _source:ByteArray;				// multipart/form-data; Required
		protected var _message:String;

		// Results
		protected var _photoId:String;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookPhotoCreateRequest() {
			super();

			// Basic service configuration
			requestURL = FacebookConstants.SERVICE_DOMAIN + FacebookConstants.SERVICE_PHOTO_CREATE;
			requestMethod = URLRequestMethod.POST;
			//requestContentType = "application/octet-stream";
			//requestContentType = "multipart/form-data";
			// U.contentType="application/octet-stream";

			// Parameters

			_targetId = "";
			_source = new ByteArray();
			_message = "";
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function getData():Object {
			var vars:URLVariables = super.getData() as URLVariables;

			//if (Boolean(_source))			vars["source"] = _source;
			if (Boolean(_message))			vars["message"] = _message;

			return vars;
		}

		override protected function getRequestHeaders():Array {
			var headers:Array = super.getRequestHeaders();
			//headers.push(new URLRequestHeader("enctype", "multipart/form-data"));
			return headers;
		}

		protected function getPostData(): ByteArray {
			var postData:ByteArray = new ByteArray();
			postData.endian = Endian.BIG_ENDIAN;

			// Writes vars
			var vars:URLVariables = getData() as URLVariables;
			for (var n:String in vars) {
				writePostData(postData, n, vars[n]);
			}

			// Writes file
			writeBoundary(postData);
			writeLineBreak(postData);

			var bytes:String;
			var l:int;
			var i:uint;
			var filename:String = "photo.png";

			bytes = 'Content-Disposition: form-data; name="'+filename+'"; filename="'+filename+'";';
			l = bytes.length;

			for (i=0; i<l; i++)  {
				postData.writeByte(bytes.charCodeAt(i));
			}

			postData.writeUTFBytes(filename);
			//writeLineBreak(postData);
			//writeLineBreak(postData);
			//postData.writeUTFBytes("Content-Type: image/png");

			postData.writeUTFBytes("\"");
			//writeQuotationMark(postData);
//			writeLineBreak(postData);

			//bytes = "application/octet-stream";
			bytes = "image/png";
			l = bytes.length;
			for (i=0; i<l; i++) {
				postData.writeByte(bytes.charCodeAt(i));
			}

			writeLineBreak(postData);
			writeLineBreak(postData);

			source.position = 0;
			//log ("image size is " + source.length);
			postData.writeBytes(source, 0, source.length);

			writeLineBreak(postData);

			writeBoundary(postData);
			writeDoubleDash(postData);

			postData.position = 0;

			//log("final data size is " + postData.length);
			//log(postData);

			return postData;
		}

		protected function writePostData(__data:ByteArray, name:String, value:String):void {
			var bytes:String;

			//log("writing var: " + name + " as " + value);

			writeBoundary(__data);
			writeLineBreak(__data);

			bytes = 'Content-Disposition: form-data; name="' + name + '"';

			var l:uint = bytes.length;
			for (var i:Number=0; i<l; i++)  {
				__data.writeByte(bytes.charCodeAt(i));
			}

			writeLineBreak(__data);
			writeLineBreak(__data);

			__data.writeUTFBytes(value);

			writeLineBreak(__data);
		}

		protected function writeDoubleDash(__data:ByteArray):void {
			__data.writeShort(0x2d2d);
		}

		protected function writeQuotationMark(__data:ByteArray):void {
			__data.writeShort(0x22);
		}

		protected function writeLineBreak(__data:ByteArray):void {
			__data.writeShort(0x0d0a);
		}

		protected function writeBoundary(__data:ByteArray):void  {
			writeDoubleDash(__data);

			var boundary:String = "-----";

			var l:uint = boundary.length;
			for (var i:uint=0; i<l; i++)  {
				__data.writeByte(boundary.charCodeAt(i));
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onIOError(e:IOErrorEvent):void {
			log("contentType ===> " + urlRequest.contentType);
			super.onIOError(e);
		}

		override protected function onComplete(e:Event):void {
			var response:Object = JSON.parse(loader.data);

			_photoId = response["id"];

			super.onComplete(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function execute():void {
			requestURL = requestURL.replace(FacebookConstants.PARAMETER_TARGET_ID, _targetId);
			//super.execute();

			if (_isLoading) stopLoading();
			if (_isLoaded) clearData();

			//var vars:URLVariables = getURLVariables();

			urlRequest = new URLRequest();

			urlRequest.contentType = 'multipart/form-data; boundary=' + "-----";

			urlRequest.url = requestURL;
			urlRequest.method = requestMethod;
			//urlRequest.data = vars;
			urlRequest.data = getPostData();
			urlRequest.requestHeaders = getRequestHeaders();
			//urlRequest.contentType = requestContentType;

			//log("data size is " + urlRequest.data["length"]);

			loader = new URLLoader();
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onHTTPStatus);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			loader.addEventListener(Event.COMPLETE, onComplete);
			// Event.OPEN, ProgressEvent.PROGRESS
			loader.load(urlRequest);
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get targetId():String {
			return _targetId;
		}
		public function set targetId(__value:String):void {
			_targetId = __value;
		}

		public function get message():String {
			return _message;
		}
		public function set message(__value:String):void {
			_message = __value;
		}

		public function get source(): ByteArray {
			return _source;
		}
		public function set source(__value:ByteArray):void {
			_source = __value;
		}

		// Results

		public function get photoId():String {
			return _photoId;
		}


	}
}
