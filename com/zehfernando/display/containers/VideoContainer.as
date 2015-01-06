package com.zehfernando.display.containers {
	import com.zehfernando.net.loaders.VideoLoader;
	import com.zehfernando.net.loaders.VideoLoaderCuePointEvent;
	import com.zehfernando.net.loaders.VideoLoaderEvent;
	import com.zehfernando.utils.console.log;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;


	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class VideoContainer extends DynamicDisplayAssetContainer implements IVideoContainer {

		// Events
		// Common
		public static const EVENT_PLAY_START:String = "onVideoPlayStart";						// Test! Only at the first play?
		public static const EVENT_PLAY_STOP:String = "onVideoStop";								// Test!
		public static const EVENT_RESUME:String = "onVideoResume";								// Test!
		public static const EVENT_PAUSE:String = "onVideoPause";								// Test!
		public static const EVENT_PLAY_FINISH:String = "onVideoPlayFinish";						// Test!
		public static const EVENT_SEEK_NOTIFY:String = "onSeekNotify";							// Test!
		public static const EVENT_LOADING_START:String = "onStartedLoading";					// Test!
		public static const EVENT_LOADING_PROGRESS:String = "onProgressLoading";				// Test!
		public static const EVENT_LOADING_ERROR:String = "onProgressLoading";					// Test!
		public static const EVENT_LOADING_COMPLETE:String = "onCompletedLoading";				// Test!
		public static const EVENT_VOLUME_CHANGE:String = "onVolumeChanged";

		// Specific
		public static const EVENT_LOOP:String = "onStopVideoEndLoop";							// Test!
		public static const EVENT_BUFFER_EMPTY:String = "onBufferEmpty";						// Test!
		public static const EVENT_BUFFER_FLUSH:String = "onBufferFlush";						// Test!
		public static const EVENT_BUFFER_FULL:String = "onBufferFull";							// Test!
		public static const EVENT_RECEIVED_METADATA:String = "onReceivedMetaData";				// Test!
		public static const EVENT_CUE_POINT:String = "onReceivedCuePoint";
		public static const EVENT_TIME_CHANGE:String = "onTimeChanged";

		// Properties
		protected var _isPlaying:Boolean;
		protected var _hasVideo:Boolean;
		protected var _autoPlay:Boolean;
		protected var _loop:Boolean;
		protected var _bufferTime:Number;					// In seconds
		protected var _volume:Number;						// Volume for this video
		protected var _maximumTime:Number;

		protected var videoLoader:VideoLoader;
		protected var isMonitoringLoading:Boolean;

		protected var lastCuePoint:Object;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoContainer(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000) {
			super (__width, __height, __color);
		}

		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------

		override protected function setDefaultData():void {
			super.setDefaultData();
			_maximumTime = 0;
			_autoPlay = true;
			_bufferTime = 3;
			_loop = false;
			_volume = 1;
			isMonitoringLoading = false;
		}

		override protected function applySmoothing():void {
			if (_hasVideo) videoLoader.smoothing = _smoothing;
		}

		protected function applyBufferTime():void {
			if (_hasVideo) videoLoader.bufferTime = _bufferTime;
		}

		protected function applyVolume():void {
			if (_hasVideo) {
				var st:SoundTransform = videoLoader.soundTransform;
				st.volume = _volume;
				videoLoader.soundTransform = st;
			}
		}

		protected function updateByteCount():void {
			if (!_hasVideo) {
				_bytesLoaded = 0;
				_bytesTotal = 0;
			} else {
				_bytesLoaded = videoLoader.bytesLoaded;
				_bytesTotal = videoLoader.bytesTotal;
			}
		}

		override protected function redraw():void {
			super.redraw();
			if (_hasVideo) {
				videoLoader.width = _contentWidth;
				videoLoader.height = _contentHeight;
			}
		}

		protected function updateMaximumTime():void {
			_maximumTime = Math.max(time, _maximumTime);
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onXMPData(e:Event):void {
			//trace ("VideoContainer :: onXMPData :: " + info);
			// TODO: do something with this data
		}

		protected function onMetaData(e:VideoLoaderEvent):void {
			//trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
			_contentWidth = videoLoader.customMetaData["width"];
			_contentHeight = videoLoader.customMetaData["height"];

			redraw();

			dispatchEvent(new Event(EVENT_RECEIVED_METADATA));
		}

		protected function onCuePoint(e:VideoLoaderCuePointEvent):void {
			//log("CUE POINT -- time=" + e.cuePointTime + " name=" + e.cuePointName + " type=" + e.cuePointType);
			//log("===" + time);
			lastCuePoint = {time:e.cuePointTime, name:e.cuePointName, type:e.cuePointType, parameters:e.cuePointParameters};
			dispatchEvent(new Event(EVENT_CUE_POINT));
		}

		protected function onSecurityError(e:SecurityError):void {
			log("securityErrorHandler: " + e);
			dispatchEvent(new Event(EVENT_LOADING_ERROR));
		}

		protected function onStreamNotFound(e:VideoLoaderEvent):void {
			dispatchEvent(new Event(EVENT_LOADING_ERROR));
		}

		protected function onLoadingStart(e:Event):void {
			updateStartedLoadingStats();
			dispatchEvent(new Event(EVENT_LOADING_START));
		}

		protected function onLoadingProgress(e:ProgressEvent):void {
			updateByteCount();
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_LOADING_PROGRESS));
		}

		protected function onLoadingComplete(e:Event):void {
			_isLoaded = true;
			updateCompletedLoadingStats();
			dispatchEvent(new Event(EVENT_LOADING_COMPLETE));
		}

		protected function onSeekNotify(e:VideoLoaderEvent):void {
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_SEEK_NOTIFY));
		}

		protected function onBufferEmpty(e:VideoLoaderEvent):void {
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_BUFFER_EMPTY));
		}

		protected function onBufferFlush(e:VideoLoaderEvent):void {
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_BUFFER_FLUSH));
		}

		protected function onBufferFull(e:VideoLoaderEvent):void {
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_BUFFER_FULL));
		}

		protected function onPlayStart(e:VideoLoaderEvent):void {
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_PLAY_START));
		}

		protected function onPlayStop(e:VideoLoaderEvent):void {
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_PLAY_STOP));
		}

		protected function onResume(e:VideoLoaderEvent):void {
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_RESUME));
		}

		protected function onPause(e:VideoLoaderEvent):void {
			updateMaximumTime();
			dispatchEvent(new Event(EVENT_PAUSE));
		}

		protected function onTimeChange(e:VideoLoaderEvent):void {
			dispatchEvent(new Event(EVENT_TIME_CHANGE));
		}

		protected function onPlayFinish(e:VideoLoaderEvent):void {

			if (_loop) {
				// Finished; loop
				if (_isPlaying) {
					time = 0;
					//playVideo();
					//Console.log("loop");
					dispatchEvent(new Event(EVENT_LOOP));
				}
			} else {
				// Finished; dispatch event
				_isPlaying = false;
				updateMaximumTime();
				dispatchEvent(new Event(EVENT_PLAY_FINISH));
			}
		}

		protected function setVideoLoaderInternal(__videoLoader:VideoLoader):void {
			videoLoader = __videoLoader;

			videoLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

			videoLoader.addEventListener(Event.OPEN, onLoadingStart);
			videoLoader.addEventListener(ProgressEvent.PROGRESS, onLoadingProgress);
			videoLoader.addEventListener(Event.COMPLETE, onLoadingComplete);

			videoLoader.addEventListener(VideoLoaderEvent.SEEK_NOTIFY, onSeekNotify);
			videoLoader.addEventListener(VideoLoaderEvent.STREAM_NOT_FOUND, onStreamNotFound);
			videoLoader.addEventListener(VideoLoaderEvent.BUFFER_EMPTY, onBufferEmpty);
			videoLoader.addEventListener(VideoLoaderEvent.BUFFER_FULL, onBufferFull);
			videoLoader.addEventListener(VideoLoaderEvent.BUFFER_FLUSH, onBufferFlush);
			videoLoader.addEventListener(VideoLoaderEvent.PLAY_START, onPlayStart);
			videoLoader.addEventListener(VideoLoaderEvent.PLAY_STOP, onPlayStop);
			videoLoader.addEventListener(VideoLoaderEvent.RESUME, onResume);
			videoLoader.addEventListener(VideoLoaderEvent.PAUSE, onPause);
			videoLoader.addEventListener(VideoLoaderEvent.PLAY_FINISH, onPlayFinish);
			videoLoader.addEventListener(VideoLoaderEvent.RECEIVED_METADATA, onMetaData);
			videoLoader.addEventListener(VideoLoaderEvent.RECEIVED_XMP_DATA, onXMPData);
			videoLoader.addEventListener(VideoLoaderEvent.TIME_CHANGE, onTimeChange);
			videoLoader.addEventListener(VideoLoaderCuePointEvent.CUE_POINT, onCuePoint);

			setAsset(videoLoader);
		}

		protected function removeVideoLoaderInternal(__disposeVideoLoader:Boolean = true):void {
			if (Boolean(videoLoader)) {
				videoLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);

				videoLoader.removeEventListener(Event.OPEN, onLoadingStart);
				videoLoader.removeEventListener(ProgressEvent.PROGRESS, onLoadingProgress);
				videoLoader.removeEventListener(Event.COMPLETE, onLoadingComplete);

				videoLoader.removeEventListener(VideoLoaderEvent.SEEK_NOTIFY, onSeekNotify);
				videoLoader.removeEventListener(VideoLoaderEvent.STREAM_NOT_FOUND, onStreamNotFound);
				videoLoader.removeEventListener(VideoLoaderEvent.BUFFER_EMPTY, onBufferEmpty);
				videoLoader.removeEventListener(VideoLoaderEvent.BUFFER_FULL, onBufferFull);
				videoLoader.removeEventListener(VideoLoaderEvent.BUFFER_FLUSH, onBufferFlush);
				videoLoader.removeEventListener(VideoLoaderEvent.PLAY_START, onPlayStart);
				videoLoader.removeEventListener(VideoLoaderEvent.PLAY_STOP, onPlayStop);
				videoLoader.removeEventListener(VideoLoaderEvent.RESUME, onResume);
				videoLoader.removeEventListener(VideoLoaderEvent.PAUSE, onPause);
				videoLoader.removeEventListener(VideoLoaderEvent.PLAY_FINISH, onPlayFinish);
				videoLoader.removeEventListener(VideoLoaderEvent.RECEIVED_METADATA, onMetaData);
				videoLoader.removeEventListener(VideoLoaderEvent.RECEIVED_XMP_DATA, onXMPData);
				videoLoader.removeEventListener(VideoLoaderEvent.TIME_CHANGE, onTimeChange);
				videoLoader.removeEventListener(VideoLoaderCuePointEvent.CUE_POINT, onCuePoint);

				removeAsset();

				if (__disposeVideoLoader) videoLoader.dispose();
				videoLoader = null;
			}
		}

		protected function loadVideoLoader(__videoLoader:VideoLoader):void {
			// Dangerously duplicated from load()!!!
			// TODO: get rid of load() altogether and only use this one?
			super.load(__videoLoader.url);

			_isLoaded = false;
			_hasVideo = true;

			setVideoLoaderInternal(__videoLoader);

			applyBufferTime();
			applySmoothing();
			applyVolume();

			if (videoLoader.hasMetaData) {
				_contentWidth = videoLoader.customMetaData["width"];
				_contentHeight = videoLoader.customMetaData["height"];
			} else {
				_contentWidth = _width;
				_contentHeight = _height;
			}

			_isLoading = true;

			redraw();

			if (_autoPlay) {
				playVideo();
			} else {
				pauseVideo();
			}
		}


		// ================================================================================================================
		// PUBLIC API functions -------------------------------------------------------------------------------------------

		// Instance

		public function getFrame():BitmapData {
			// Captures the current frame as a BitmapData
			var bmp:BitmapData = new BitmapData(_contentWidth, _contentHeight, false, 0x000000);

			var mtx:Matrix = new Matrix();
			mtx.scale(_contentWidth/100, _contentHeight/100);
			//mtx.scale(video.width/_contentWidth, video.height/_contentHeight);
			bmp.draw(videoLoader, mtx);
			return bmp;
		}

		override public function load(__url:String):void {
			super.load(__url);

			_isLoaded = false;
			_hasVideo = true;

			setVideoLoaderInternal(new VideoLoader());

			videoLoader.load(new URLRequest(_contentURL));

			applyBufferTime();
			applySmoothing();
			applyVolume();

			setAsset(videoLoader);

			_contentWidth = _width;
			_contentHeight = _height;

			_isLoading = true;

			redraw();

			if (_autoPlay) {
				playVideo();
			} else {
				pauseVideo();
			}
		}

		public function setVideoLoader(__videoLoader:VideoLoader):void {
			// Replaces the current video loader with another video loader
			if (videoLoader != __videoLoader) {
				unload();
				loadVideoLoader(__videoLoader);
			}
		}

		public function detachVideoLoader():void {
			// Removes the video loader without disposing -- temp!
			// TODO: make this better

			pauseVideo();

			_hasVideo = false;
			_isLoaded = false;
			_isLoading = false;

			removeVideoLoaderInternal(false);

			super.unload();
		}

		override public function unload():void {

			pauseVideo();

			_hasVideo = false;
			_isLoaded = false;
			_isLoading = false;

			removeVideoLoaderInternal();

			super.unload();
		}

		public function playVideo():void {
			_isPlaying = true;
			updateMaximumTime();
			if (_hasVideo) videoLoader.resume();
		}

		public function pauseVideo():void {
			_isPlaying = false;
			updateMaximumTime();
			if (_hasVideo) videoLoader.pause();
		}

		public function stopVideo():void {
			pauseVideo();
			time = 0;
		}

		public function playPauseVideo():void {
			if (_isPlaying) {
				pauseVideo();
			} else {
				playVideo();
			}
		}

		override public function getLoadingSpeed():Number {
			//updateByteCount();
			//return super.getLoadingSpeed();
			return videoLoader.getLoadingSpeed();
		}

		public function getFullBufferingLevel():Number {
			updateByteCount();
			return videoLoader.getFullBufferingLevel();
		}

		public function getMaximumPositionPlayed():Number {
			updateMaximumTime();
			return _maximumTime / duration;
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		// Additional video data
		public function get duration():Number {
			if (!_hasVideo) return 0;
			if (!hasMetaData) return 0;
			return videoLoader.duration;
		}

		public function get framerate():Number {
			if (!_hasVideo) return 0;
			if (!hasMetaData) return 0;
			return videoLoader.framerate;
		}

		public function get isPlaying():Boolean {
			if (!_hasVideo) return false;
			return _isPlaying;
		}

		// Time/position control
		public function get time():Number {
			if (!_hasVideo) return 0;
			return videoLoader.time;
		}
		public function set time(__value:Number):void {
			if (!_hasVideo) return;
			videoLoader.seek(__value);
			updateMaximumTime();
		}

		public function get position():Number {
			if (!_hasVideo) return 0;
			if (!hasMetaData) return 0;
			return time / duration;
		}
		public function set position(__value:Number):void {
			if (!_hasVideo) return;
			if (!hasMetaData) return;
			time = __value * duration;
		}

		public function get bufferLength():Number {
			if (!_hasVideo) return 0;
			return videoLoader.bufferLength;
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
			applyBufferTime();
		}

		public function get volume():Number {
			return _volume;
		}
		public function set volume(__value:Number):void {
			_volume = __value;
			applyVolume();
			// TODO: move this to video loader?
			dispatchEvent(new Event(EVENT_VOLUME_CHANGE));
		}

		public function get loop():Boolean {
			return _loop;
		}
		public function set loop(__value:Boolean):void {
			_loop = __value;
		}

		override public function get loadedPercent():Number {
			if (!_isLoaded) updateByteCount();
			return super.loadedPercent;
		}

		public function get hasVideo():Boolean {
			return _hasVideo;
		}

		public function get hasMetaData():Boolean {
			return videoLoader.hasMetaData;
		}

		public function getLastCuePoint(): Object {
			return lastCuePoint;
		}
		public function get droppedFrames():int {
			//return _hasVideo ? videoLoader.metaData["droppedFrames"] : 0;
			return _hasVideo ? videoLoader.droppedFrames : 0;
		}
		public function get decodedFrames():int {
			return _hasVideo ? videoLoader.decodedFrames : 0;
		}

		public function get currentFPS():int {
			return _hasVideo ? videoLoader.currentFPS : 0;
		}
	}
}

/*
class VideoData {

	public var duration:Number;
	public var width:Number;
	public var height:Number;
	public var framerate:Number;
	public var videoContainer:Object;

	public function VideoData(__videoContainer:Object) {
		duration = NaN;
		width = NaN;
		height = NaN;
		framerate = NaN;
		videoContainer = __videoContainer;
	}

	public function onXMPData(info:Object):void {
		//trace ("VideoContainer :: VideoData :: onXMPData :: " + info);
		// TODO: do something with this data
	}

	public function onMetaData(info:Object):void {
		//trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
		duration = info["duration"];
		width = info["width"];
		height = info["height"];
		framerate = info["framerate"];
		videoContainer["postMetaData"]();
	}

	public function onCuePoint(info:Object):void {
		trace("VideoContainer :: VideoData :: cuepoint: time=" + info["time"] + " name=" + info["name"] + " type=" + info["type"]);
	}
}
*/