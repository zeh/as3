package com.zehfernando.net.apis.youtube.services {
	import com.zehfernando.net.apis.BasicServiceRequest;
	import com.zehfernando.net.apis.youtube.YouTubeConstants;
	import com.zehfernando.net.apis.youtube.data.YouTubeVideo;
	import com.zehfernando.net.apis.youtube.events.YouTubeServiceEvent;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequestMethod;

	/**
	 * @author zeh
	 */
	public class YouTubeUserUploadsRequest extends BasicServiceRequest {

		// Properties
		protected var _userId:String;

		// Results
		protected var _videos:Vector.<YouTubeVideo>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function YouTubeUserUploadsRequest() {
			super();

			// Basic service configuration
			requestURL = YouTubeConstants.DOMAIN + YouTubeConstants.SERVICE_USER_UPLOADS;
			requestMethod = URLRequestMethod.GET;

			// Parameters
			// http://developers.facebook.com/docs/reference/api/page

			_userId = "";


		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onSecurityError(e:SecurityErrorEvent):void {
			super.onSecurityError(e);
			dispatchEvent(new YouTubeServiceEvent(YouTubeServiceEvent.ERROR));
		}

		override protected function onIOError(e:IOErrorEvent):void {
			super.onIOError(e);
			dispatchEvent(new YouTubeServiceEvent(YouTubeServiceEvent.ERROR));
		}

		override protected function onComplete(e:Event):void {

			var vidData:XML = (new XML(loader.data));

			/*FDT_IGNORE*/
			var ns:Namespace = vidData.namespace();
			default xml namespace = ns;
			/*FDT_IGNORE*/

			_videos = YouTubeVideo.fromXMLList(vidData.child("entry"));

			default xml namespace = new Namespace(""); // WTF! one needs this otherwise the function below fails!

			super.onComplete(e);
			dispatchEvent(new YouTubeServiceEvent(YouTubeServiceEvent.COMPLETE));
		}


		override public function execute():void {
			requestURL = requestURL.replace(YouTubeConstants.PARAMETER_USER_ID, _userId);
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get userId():String {
			return _userId;
		}
		public function set userId(__value:String):void {
			_userId = __value;
		}

		// Results

		public function get videos(): Vector.<YouTubeVideo> {
			return _videos.concat();
		}
	}
}
