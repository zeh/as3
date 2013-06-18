package com.zehfernando.display.containers {

	import com.zehfernando.net.apis.youtube.data.YouTubeVideo;
	import com.zehfernando.net.apis.youtube.events.YouTubeServiceEvent;
	import com.zehfernando.net.apis.youtube.services.YouTubeVideoInfoRequest;

	import flash.system.Security;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class YouTubeImageContainer extends ImageContainer {

		// Properties
		protected var _youTubeID:String;

		protected var _isGettingYouTubeInfo:Boolean;
		protected var videoInfo:YouTubeVideo;
		protected var videoInfoRequest:YouTubeVideoInfoRequest;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function YouTubeImageContainer(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000) {
			super(__width, __height, __color);

			Security.loadPolicyFile("http://s.ytimg.com/");
			Security.loadPolicyFile("http://i2.ytimg.com/crossdomain.xml");
			Security.loadPolicyFile("http://i.ytimg.com/crossdomain.xml");
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function cancelGetYouTubeInfo():void {
			if (_isGettingYouTubeInfo) {
				videoInfoRequest.removeEventListener(YouTubeServiceEvent.COMPLETE, onLoadVideoInfoComplete);
				videoInfoRequest.removeEventListener(YouTubeServiceEvent.ERROR, onLoadVideoInfoError);
				videoInfoRequest.dispose();
				videoInfoRequest = null;
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onLoadVideoInfoComplete(e:YouTubeServiceEvent):void {
			videoInfo = (e.target as YouTubeVideoInfoRequest).video;

			cancelGetYouTubeInfo();
			videoInfoRequest = null;

			super.load(videoInfo.thumbnails[2].url);
			//super.load(videoInfo.getHighestResolutionThumbnailURL());
		}

		protected function onLoadVideoInfoError(e:YouTubeServiceEvent):void {
			cancelGetYouTubeInfo();

			trace("YouTubeImageContainer :: Error when trying to load image info for " + _youTubeID);
			dispatchEvent(e);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		override public function load(__id:String):void {
			cancelGetYouTubeInfo();

			_youTubeID = __id;

			videoInfoRequest = new YouTubeVideoInfoRequest();
			videoInfoRequest.videoId = _youTubeID;
			videoInfoRequest.addEventListener(YouTubeServiceEvent.COMPLETE, onLoadVideoInfoComplete);
			videoInfoRequest.addEventListener(YouTubeServiceEvent.ERROR, onLoadVideoInfoError);
			videoInfoRequest.execute();
		}

		override public function dispose():void {
			cancelGetYouTubeInfo();
			videoInfo = null;

			super.dispose();
		}
	}
}
