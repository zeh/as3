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
	public class YouTubeVideoInfoRequest extends BasicServiceRequest {

		// Properties
		protected var _videoId:String;

		// Results
		protected var _video:YouTubeVideo;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function YouTubeVideoInfoRequest() {
			super();

			// Basic service configuration
			requestURL = YouTubeConstants.DOMAIN + YouTubeConstants.SERVICE_VIDEO_INFO;
			requestMethod = URLRequestMethod.GET;

			// Parameters

			_videoId = "";
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
			_video = YouTubeVideo.fromXML(new XML(loader.data));

			super.onComplete(e);
			dispatchEvent(new YouTubeServiceEvent(YouTubeServiceEvent.COMPLETE));
		}


		override public function execute():void {
			requestURL = requestURL.replace(YouTubeConstants.PARAMETER_VIDEO_ID, _videoId);
			super.execute();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// Parameters

		public function get videoId():String {
			return _videoId;
		}
		public function set videoId(__value:String):void {
			_videoId = __value;
		}

		// Results

		public function get video(): YouTubeVideo {
			// TODO: clone?
			return _video;
		}
	}
}
