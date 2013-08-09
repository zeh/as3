package com.zehfernando.display.containers {
	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.geom.GeomUtils;
	import com.zehfernando.utils.AppUtils;
	import com.zehfernando.utils.console.info;
	import com.zehfernando.utils.console.log;

	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;
	import flash.events.VideoEvent;
	import flash.geom.Rectangle;
	import flash.media.StageVideo;
	import flash.media.StageVideoAvailability;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	/**
	 * @author zeh fernando
	 */
	public class StageVideoSprite extends ResizableSprite {

		// http://www.adobe.com/devnet/flashplayer/articles/stage_video.html
		// http://help.adobe.com/en_US/as3/dev/WSe9ecd9e6b89aefd2-68d5ef8f12cc8511f6c-7ffe.html

		// Constants
		public static const EVENT_PLAY_FINISH:String = "StageVideoSprite.playFinish";
		public static const EVENT_PLAY_LOOP:String = "StageVideoSprite.playLoop";

		// Properties
		private var _hasVideo:Boolean;
		private var _url:String;
		private var _needToPlay:Boolean;
		private var _isPlaying:Boolean;

		private var _loop:Boolean;
		private var _bufferTime:Number;
		private var _autoPlay:Boolean;

		// Instances
		private var _netConnection:NetConnection;
		private var _netStream:NetStream;
		private var _stageVideo:StageVideo;
		private var _video:Video;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StageVideoSprite(__width:Number = 100, __height:Number = 100) {
			super();

			_width = __width;
			_height = __height;
			_needToPlay = false;
			_isPlaying = false;
			_bufferTime = 0.1; // Netstream default is 0.1

			_loop = false;
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			resizeVideo();
		}

		override protected function redrawHeight():void {
			resizeVideo();
		}

		private function createAssets():void {
			// Creates all needed assets

			if (_hasVideo) unload();

			_hasVideo = true;

			// Connections
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetConnectionError);
			_netConnection.connect(null);

			_netStream = new NetStream(_netConnection);
			_netStream.checkPolicyFile = true;
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_netStream.client = {};
			_netStream.client["onCuePoint"] = onCuePoint;
			_netStream.client["onImageData"] = onImageData;
			_netStream.client["onMetaData"] = onMetaData;
			_netStream.client["onPlayStatus"] = onPlayStatus;
			_netStream.client["onSeekPoint"] = onSeekPoint;
			_netStream.client["onTextData"] = onTextData;
			_netStream.client["onXMPData"] = onXMPData;

			applyNetStreamBufferTime();

			// This is fired once, right after registering
			AppUtils.getStage().addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailability);

//			addEventListener(Event.ENTER_FRAME, function(__e:Event):void {
//				log("dropped frames = " + _netStream.info.droppedFrames);
//			});
		}

		private function attachToStageVideo():void {
			// Attach existing netstream to existing StageVideo
			log("Attaching to StageVideo");

			_stageVideo = AppUtils.getStage().stageVideos[0];
			_stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, onStageVideoRenderStateChange);
			_stageVideo.attachNetStream(_netStream);

			// depth:int: Depth of the StageVideo object. This property allows you to handle z-ordering among multiple StageVideo objects.
			// pan:Point: Panning (similar to x and y); a Point object must be specified. By default, the value of pan is (0,0).
			// videoHeight:int: Native height of the video stream; a read-only property.
			// videoWidth int: Native width of the video stream; a read-only property.
			// viewport:Rectangle: Visible surface (similar to width and height); a Rectangle object must be specified.
			// zoom:Point: Zooming factor; a Point object must be specified. By default, the value of zoom is (1,1).

			// Stage videos are rendered in order. Use .depth to change the order:
//			sv.depth = 0;
//			sv2.depth = 1;
		}

		private function detachFromStageVideo():void {
			if (_stageVideo != null) {
				log("Detaching from StageVideo");
				_stageVideo.removeEventListener(StageVideoEvent.RENDER_STATE, onStageVideoRenderStateChange);
				_stageVideo.attachNetStream(null);
				_stageVideo = null;
			}
		}

		private function attachToVideo():void {
			// Attach existing netstream to fallback Video
			log("Attaching to fallback Video");

			// Create a fallback video
			_video = new Video();
			_video.addEventListener(VideoEvent.RENDER_STATE, onVideoRenderStateChange);
			_video.smoothing = true;
			_video.attachNetStream(_netStream);
			AppUtils.getStage().addChildAt(_video, 0);
		}

		private function detachFromVideo():void {
			if (_video != null) {
				log("Detaching from fallback Video");
				AppUtils.getStage().removeChild(_video);
				_video.removeEventListener(VideoEvent.RENDER_STATE, onVideoRenderStateChange);
				_video.attachNetStream(null);
				_video = null;
			}
		}

		private function getVideoRect(__contentWidth:Number, __contentHeight:Number, __round:Boolean):Rectangle {
			// Based on the video size, get the expected rectangle for video playback

			// TODO: return with values that respect x, y, width and height?
			// TODO: allow other resizing modes?

			var rectContent:Rectangle = new Rectangle(0, 0, __contentWidth, __contentHeight);
			var rectContainer:Rectangle = new Rectangle(0, 0, _width, _height);

			// Find size of the final rectangle
			var scale:Number = GeomUtils.fitRectangle(rectContent, rectContainer, false);

			var finalRect:Rectangle = new Rectangle(0, 0, __contentWidth * scale, __contentHeight * scale);
			if (__round) {
				finalRect.width = Math.round(finalRect.width);
				finalRect.height = Math.round(finalRect.height);
			}

			// Center
			finalRect.x = rectContainer.width * 0.5 - finalRect.width * 0.5;
			finalRect.y = rectContainer.height * 0.5 - finalRect.height * 0.5;
			if (__round) {
				finalRect.x = Math.round(finalRect.x);
				finalRect.y = Math.round(finalRect.y);
			}

			return finalRect;
		}

		private function applyNetStreamBufferTime():void {
			if (_netStream != null) _netStream.bufferTime = _bufferTime;
		}

		private function resizeVideo():void {
			// Resize video to fit the screen
			if (_video != null) {
				log("Resizing Video to " + _video.videoWidth + "x" + _video.videoHeight);
				var rect:Rectangle = getVideoRect(_video.videoWidth, _video.videoHeight, true);
				_video.x = rect.x;
				_video.y = rect.y;
				_video.width = rect.width;
				_video.height = rect.height;
			}

			if (_stageVideo != null) {
				log("Resizing StageVideo to " + _stageVideo.videoWidth + "x" + _stageVideo.videoHeight);
				try {
					_stageVideo.viewPort = getVideoRect(_stageVideo.videoWidth, _stageVideo.videoHeight, true);
				} catch (__e:Error) {
					log("Error resizing StageVideo: " + __e);
				}
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onStageVideoAvailability(__e:StageVideoAvailabilityEvent):void {
			log("StageVideo availability state is " + __e.availability);

			if (__e.availability == StageVideoAvailability.AVAILABLE) {
				// StageVideo is available
				if (_stageVideo == null) {
					detachFromVideo();
					attachToStageVideo();
				}
			} else {
				// StageVideo is not available
				if (_video == null) {
					detachFromStageVideo();
					attachToVideo();
				}
			}

			_netStream.play(_url);
			if (_needToPlay) {
				_needToPlay = false;
				_isPlaying = true;
			} else {
				pauseVideo();
			}
		}

		private function onVideoRenderStateChange(__e:VideoEvent):void {
			info("Video state has changed to " + __e.status + ", codec info " + __e.codecInfo);
			resizeVideo();
		}

		private function onStageVideoRenderStateChange(__e:StageVideoEvent):void {
			info("StageVideo state has changed to " + __e.status + ", color space " + __e.colorSpace +", codec info " + __e.codecInfo);
			resizeVideo();
			// Use StageVideoEvent.RENDER_STATE to know how the video frames are being rendered:
			// VideoStatus.ACCELERATED: The video is being decoded and composited through the GPU
			// VideoStatus.SOFTWARE: The video is being decoded though software and composited by the GPU, if dispatched by StageVideo, or through software, if dispatched by Video.
			// VideoStatus.UNAVAILABLE: The video hardware has stopped decoding and compositing the video

			// As you can see, you can also use this event to handle video resize, as this new event also tells you when the video size can be retrieved from the Video or StageVideo objects and final width and height calculated depending on the constraints.
		}

//		private function onStageVideoState(event:StageVideoAvailabilityEvent):void {
//			var available:Boolean = (event.availability == StageVideoAvailability.AVAILABLE);
//			log("stage video available = " + available);
//		}

		private function onNetConnectionStatus(__e:NetStatusEvent):void {
			log("##### NET CONNECTION STATUS CODE: " + __e.info["code"]);
		}

		protected function onNetConnectionError(__e:SecurityErrorEvent):void {
			log("##### NET CONNECTION ERROR: " + __e);
		}

		private function onNetStatus(__e:NetStatusEvent):void {
//			log("##### NET STREAM STATUS CODE: " + __e.info["code"]);
		}

		private function onPlayStatus(__newData:Object):void {
//			log("##### NET STREAM PLAY STATUS DATA : " + JSON.stringify(__newData));

			// When play starts:
//			##### NET STREAM STATUS CODE: NetStream.Play.Start
//			##### NET STREAM METADATA DATA : []
//			##### NET STREAM STATUS CODE: NetStream.Buffer.Full

			// When play ends:
//			##### NET STREAM STATUS CODE: NetStream.Buffer.Flush
//			##### NET STREAM STATUS CODE: NetStream.Play.Stop
//			##### NET STREAM PLAY STATUS DATA : {"code":"NetStream.Play.Complete","level":"status"}

			// When seeks to beginning again:
//			##### NET STREAM STATUS CODE: NetStream.SeekStart.Notify
//			##### NET STREAM STATUS CODE: NetStream.Seek.Notify
//			##### NET STREAM STATUS CODE: NetStream.Buffer.Full
//			##### NET STREAM METADATA DATA : []
//			##### NET STREAM STATUS CODE: NetStream.Seek.Complete

			// {"code":"NetStream.Play.Complete","level":"status"}
			switch (__newData["code"]) {
				case "NetStream.Play.Complete":
					if (_loop) {
						dispatchEvent(new Event(EVENT_PLAY_LOOP));
						_netStream.seek(0);
					} else {
						dispatchEvent(new Event(EVENT_PLAY_FINISH));
					}
					break;
			}
		}

		private function onCuePoint(__cueInfo:Object):void {
			log("##### NET STREAM CUE POINT DATA : " + JSON.stringify(__cueInfo));
		}

		private function onXMPData(__newData:Object):void {
			log("##### NET STREAM XMP DATA : " + JSON.stringify(__newData));
		}

		public function onTextData(__newData:Object):void {
			log("##### NET STREAM TEXT DATA : " + JSON.stringify(__newData));
		}

		public function onSeekPoint(__newData:Object):void {
			log("##### NET STREAM SEEK POINT DATA : " + JSON.stringify(__newData));
		}

		public function onImageData(__newData:Object):void {
			log("##### NET STREAM IMAGE DATA : " + JSON.stringify(__newData));
		}

		public function onMetaData(__newData:Object):void {
//			log("##### NET STREAM METADATA DATA : " + JSON.stringify(__newData));
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function load(__url:String):void {
			_url = __url;
			_needToPlay = _autoPlay;
			createAssets();
		}

		public function unload():void {
			if (_hasVideo) {
				pauseVideo();

				AppUtils.getStage().removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onStageVideoAvailability);

				detachFromStageVideo();
				detachFromVideo();

				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_netStream.pause();
				_netStream.close();
				_netStream = null;

				_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
				_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetConnectionError);
				_netConnection.close();
				_netConnection = null;

				_hasVideo = false;
			}
		}

		public function playVideo():void {
			if (_hasVideo) {
				_netStream.resume();
				_isPlaying = true;
			}
		}

		public function pauseVideo():void {
			if (_hasVideo) {
				_isPlaying = false;
				_netStream.pause();
			}
		}

		public function stopVideo():void {
			if (_hasVideo) {
				pauseVideo();
				_netStream.seek(0);
			}
		}

		public function dispose():void {
			if (_hasVideo) unload();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get loop():Boolean {
			return _loop;
		}
		public function set loop(__value:Boolean):void {
			if (_loop != __value) {
				_loop = __value;
			}
		}

		public function get autoPlay():Boolean {
			return _autoPlay;
		}
		public function set autoPlay(__value:Boolean):void {
			_autoPlay = __value;
		}

		public function get bufferTime():Number {
			return _bufferTime;
		}
		public function set bufferTime(__value:Number):void {
			_bufferTime = __value;
			applyNetStreamBufferTime();
		}
	}
}
