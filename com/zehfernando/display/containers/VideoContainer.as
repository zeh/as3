package com.zehfernando.display.containers {

	import com.zehfernando.utils.MathUtils;

	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.geom.Matrix;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class VideoContainer extends DynamicDisplayAssetContainer implements IVideoContainer {

		// Events
		// Common
		public static const EVENT_PLAY_START:String = "onVideoPlay";									// Only at the first play!
		public static const EVENT_SEEK_NOTIFY:String = "onSeekNotify";							// Ok?
		public static const EVENT_PAUSE:String = "onVideoPause";								// Ok apparently
		public static const EVENT_FINISH:String = "onVideoFinish";								// Test?
		public static const EVENT_LOADING_START:String = "onStartedLoading";					// Ok
		public static const EVENT_LOADING_PROGRESS:String = "onProgressLoading";				// Ok
		public static const EVENT_LOADING_ERROR:String = "onProgressLoading";					// Ok
		public static const EVENT_LOADING_COMPLETE:String = "onCompletedLoading";				// Ok

		// Specific
//		public static const EVENT_START:String = "onPlayVideoStart"; // This event is shit
		public static const EVENT_LOOP:String = "onStopVideoEndLoop";							// Test?
		public static const EVENT_BUFFER_EMPTY:String = "onBufferEmpty";						// Ok apparently
		public static const EVENT_BUFFER_FULL:String = "onBufferFull";							// Ok apparently
		public static const EVENT_RECEIVED_METADATA:String = "onReceivedMetaData";				// Ok
		public static const EVENT_CUE_POINT:String = "onReceivedCuePoint";

		// Properties
		protected var _isPlaying:Boolean;
		protected var _hasVideo:Boolean;
		protected var _autoPlay:Boolean;
		protected var _loop:Boolean;
		protected var _bufferTime:Number;					// In seconds
		protected var _volume:Number;						// Volume for this video
		protected var _duration:Number;						// Video duration, in miliseconds
		protected var _framerate:Number;					// Video framerate
		protected var _hasMetaData:Boolean;					// Whether metadata was already received or not
		protected var _maximumTime:Number;
		
		protected var netConnection:NetConnection;
		protected var netStream:NetStream;
		protected var video:Video;
		protected var isMonitoringLoading:Boolean;

		protected var lastCuePoint:Object;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoContainer(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000) {
			super (__width, __height, __color);
		}

		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------

		override protected function setDefaultData(): void {
			super.setDefaultData();
			_maximumTime = 0;
			_autoPlay = true;
			_bufferTime = 3;
			_loop = false;
			_volume = 1;
			isMonitoringLoading = false;
		}

		override protected function applySmoothing(): void {
			if (_hasVideo) video.smoothing = _smoothing;
		}
		
		protected function applyBufferTime(): void {
			if (_hasVideo) netStream.bufferTime = _bufferTime;
		}
		
		protected function applyVolume(): void {
			if (_hasVideo) {
				var st:SoundTransform = netStream.soundTransform;
				st.volume = _volume; 
				netStream.soundTransform = st;
			}
		}

		protected function updateByteCount(): void {
			if (!_hasVideo) {
				_bytesLoaded = 0;
				_bytesTotal = 0;
			} else {
				//var obl:Number = _bytesLoaded;
				_bytesLoaded = netStream.bytesLoaded;
				_bytesTotal = netStream.bytesTotal;
				//if ((isNaN(obl) || obl == 0) && _bytesLoaded > 0) onLoadStart();
				//if (_bytesTotal > 0 && _bytesTotal >= _bytesLoaded && !__skipCompleteDispatch) onLoadComplete();
			}
		}

		protected function startMonitoringLoading(): void {
			// Monitos video loading
			if (!isMonitoringLoading) {
				isMonitoringLoading = true;
				addEventListener(Event.ENTER_FRAME, onEnterFrameMonitorLoading, false, 0, true);
				onLoadProgress();
				//onEnterFrameMonitorLoading(null);
				//updateByteCount();
			}
		}

		protected function stopMonitoringLoading(): void {
			if (isMonitoringLoading) {
				isMonitoringLoading = false;
				removeEventListener(Event.ENTER_FRAME, onEnterFrameMonitorLoading);
			}
		}
		

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		// Crappy netStream 'client' events

		public function	onXMPData(info:Object):void {
			//trace ("VideoContainer :: onXMPData :: " + info);
			// TODO: do something with this data
		} 
	
	    public function onMetaData(info:Object):void {
			//trace("metadata: duration=" + info.duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
			_hasMetaData = true;
			
			_duration = info["duration"];
			_framerate = info["framerate"];
			
			_contentWidth = info["width"];
			_contentHeight = info["height"];
			
			redraw();
			
			dispatchEvent(new Event(EVENT_RECEIVED_METADATA));
	    }
	
	    public function onCuePoint(info:Object):void {
			trace("VideoContainer :: onCuePoint: time=" + info["time"] + " name=" + info["name"] + " type=" + info["type"]);
	    	lastCuePoint = info;
	    	dispatchEvent(new Event(EVENT_CUE_POINT));
		}

		// Other events
		
		protected function onLoadStart(): void {
			// Pseudo-event
			updateStartedLoadingStats();
			dispatchEvent(new Event(EVENT_LOADING_START));
		}

		protected function onEnterFrameMonitorLoading(e:Event): void {
			onLoadProgress();
		}

		protected function onLoadProgress(__skipCompleteDispatch:Boolean = false): void {
			var obl:Number = _bytesLoaded;
			updateByteCount();
			if (_hasVideo && (isNaN(obl) || obl == 0) && _bytesLoaded > 0) onLoadStart();
			
			if (_hasVideo && _bytesLoaded > 0) {
				updateMaximumTime();

				dispatchEvent(new Event(EVENT_LOADING_PROGRESS));
			
				if (_bytesTotal > 0 && _bytesLoaded >= _bytesTotal && !__skipCompleteDispatch) onLoadComplete();
			}
		}

		protected function onLoadComplete(): void {
			// Pseudo-progress event
			//updateByteCount(true);
			//dispatchEvent(new Event(EVENT_LOADING_PROGRESS));
			
			_isLoaded = true;
			updateCompletedLoadingStats();
			stopMonitoringLoading();
			dispatchEvent(new Event(EVENT_LOADING_COMPLETE));
		}

		protected function onNetStatus(event:NetStatusEvent):void {
			//trace ("VideoContainer :: onNetStatus :: "+event.info.code);
			
			/* 
			event.info.code could be:
			
			NetConnection.Connect.Success -- // Fired *immediately* after nc.connect(null)
			NetStream.Play.StreamNotFound
			NetStream.Play.Start - stream starts loading?
			NetStream.Buffer.Full
			NetStream.Buffer.Flush
			NetStream.Seek.Notify
			
			When it finishes:
			NetStream.Buffer.Flush
			NetStream.Buffer.Flush
			NetStream.Play.Stop
			NetStream.Buffer.Empty
			*/
			
			//trace ("videocontainer onNetStatus :: " + event.info.code);
            switch (event.info["code"]) {
				case "NetStream.Play.StreamNotFound":
                	// TODO: add error event here
                    trace("VideoContainer :: Stream [" + _contentURL + "] not found!");
                    break;
                case "NetStream.Seek.Notify":
                	//trace ("netstream.seek.notify " + _contentURL+ " @ " + netStream.time);
                	dispatchEvent(new Event(EVENT_SEEK_NOTIFY));
                	break;
                case "NetStream.Play.Start":
                	//trace ("netstream.play.start " + _contentURL);
//                	//trace ("Play.start @ t = " + time);
//                	if (time == 0) onVideoStart();
////                	onVideoPlay();
					dispatchEvent(new Event(EVENT_PLAY_START));
                	break;
            	case "NetStream.Buffer.Empty":
            		dispatchEvent(new Event(EVENT_BUFFER_EMPTY));
            		break;
            	case "NetStream.Buffer.Full":
            		dispatchEvent(new Event(EVENT_BUFFER_FULL));
            		//trace ("BUFFER FULL FOR " + _contentURL);
					break;
            	case "NetStream.Play.Stop":
            		dispatchEvent(new Event(EVENT_PAUSE));
            		if (time >= duration - 0.1) onVideoFinish(); // ugh
            		break;
            }

			updateMaximumTime();
        }

//        protected function onVideoPlay():void {
//        	// Video has started playing
//    		// Dispatch event
//    		var e:Event = new Event(EVENT_PLAY);
//    		// TODO: add target to event
//    		dispatchEvent(e);
//        }

//        protected function onVideoStart():void {
//        	// Video has started playing at the very start
//    		// Dispatch event
//    		var e:Event = new Event(EVENT_START);
//    		// TODO: add target to event
//    		dispatchEvent(e);
//        }

        protected function onVideoFinish():void {
        	// Video has automatically stopped after the end
       		var e:Event;
       		// TODO: this is still sort of crappy
       		if (_loop) {
        		// Auto restart
        		if (_isPlaying) {
        			e = new Event(EVENT_LOOP); // TODO: add target to event
        			dispatchEvent(e);
        			//position = 0;
        			time = 0;
        			//playVideo();
        		}
        	} else {
        		// Dispatch event
        		_isPlaying = false;
       			e = new Event(EVENT_FINISH); // TODO: add target to event
        		dispatchEvent(e);
			}
        }

        protected function onNetError(event:SecurityErrorEvent):void {
            trace("VideoContainer :: onNetError :: securityErrorHandler: " + event);
        }
        
//        protected function onChangeGlobalVolume(e:Event): void {
//        	applyVolume();
//        }

		override protected function redraw(): void {
			super.redraw();
			if (_hasVideo) {
				video.width = _contentWidth;
				video.height = _contentHeight;
			}
		}
		
		protected function updateMaximumTime(): void {
			_maximumTime = Math.max(time, _maximumTime);
		}

		
		// ================================================================================================================
		// PUBLIC API functions -------------------------------------------------------------------------------------------

		// Instance
		
		public function getFrame(): BitmapData {
			// Captures the current frame as a BitmapData
			var bmp:BitmapData = new BitmapData(_contentWidth, _contentHeight, false, 0x000000);
			
			var mtx:Matrix = new Matrix();
			mtx.scale(_contentWidth/100, _contentHeight/100);
			//mtx.scale(video.width/_contentWidth, video.height/_contentHeight);
			bmp.draw(video, mtx);
			return bmp;
		}

		override public function load(__url:String): void {
			super.load(__url);
			
			_isLoaded = false;

			netConnection = new NetConnection();
			netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
    		netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetError);
			netConnection.connect(null);

			_hasVideo = true;
	
			netStream = new NetStream(netConnection);
			applyBufferTime();
			netStream.checkPolicyFile = true;
			netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			netStream.client = this;

			video = new Video(_width, _height);
			video.attachNetStream(netStream);
			applySmoothing();
			//contentHolder.addChild(video);
			setAsset(video);
			
			netStream.play(_contentURL);
			//netStream.seek(0);

			_contentWidth = video.width;
			_contentHeight = video.height;

			_isLoading = true;

			redraw();
			
			applyVolume();
			
			if (_autoPlay) {
				playVideo();
			} else {
				pauseVideo();
			}

			startMonitoringLoading();
		}

		override public function unload(): void {
			stopMonitoringLoading();

			pauseVideo();

			_hasVideo = false;
			_isLoaded = false;
			_isLoading = false;

			_duration = NaN;
			_framerate = NaN;
			_hasMetaData = false;

			if (Boolean(video)) {
				//contentHolder.removeChild(video);
				removeAsset();
				video = null;
			}

			if (Boolean(netStream)) {
				netStream.close();
				netStream = null;
			}

			if (Boolean(netConnection)) {
				netConnection.close();
				netConnection = null;
			}
			
			super.unload();
		}

		public function playVideo():void {
			_isPlaying = true;
			updateMaximumTime();
			if (_hasVideo) netStream.resume();
		}

		public function pauseVideo():void {
			_isPlaying = false;
			updateMaximumTime();
			if (_hasVideo) netStream.pause();
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

		override public function getLoadingSpeed(): Number {
			updateByteCount();
			return super.getLoadingSpeed();
		}
		
		public function getFullBufferingLevel(): Number { // TODO: ugh, rename this function?
			// Returns a number between 0 and 1 that's the percentage of data that is loaded to provide a full non-stop playback
			// 0 = nothing loaded; 1 = can probably provide a nonstop playback
			//AflactPlayer.getInstance().ttrace(" >> " + _contentURL + " _timeStartedLoading = " + _timeStartedLoading);
			//AflactPlayer.getInstance().ttrace(" >> " + _contentURL + " loaded = " + loaded);
			updateByteCount();
			if (duration == 0 || _bytesTotal == 0 || isNaN(_timeStartedLoading)) return 0;
			//AflactPlayer.getInstance().ttrace(" >> " + _contentURL + " IS OK");
			if (isLoaded) return 1;
			var remainingPlaybackTime:Number = duration - time;									// Remaining video playback time, in seconds
			var remainingLoadingTime:Number = (_bytesTotal - _bytesLoaded) / getLoadingSpeed();	// Time needed to play the remaining data, in seconds
			//return remainingLoadingTime <= remainingPlaybackTime;
			return MathUtils.clamp(remainingPlaybackTime / remainingLoadingTime);
		}
		
		public function getMaximumPositionPlayed(): Number {
			updateMaximumTime();
			return _maximumTime / duration;
		}
		

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		// Additional video data
		public function get duration(): Number {
			if (!_hasVideo) return 0;
			if (!_hasMetaData) return 0;
			return _duration;
		}

		public function get framerate(): Number {
			if (!_hasVideo) return 0;
			if (!_hasMetaData) return 0;
			return _framerate;
		}

		public function get isPlaying(): Boolean {
			if (!_hasVideo) return false;
			return _isPlaying;
		}

		// Time/position control
		public function get time(): Number {
			if (!_hasVideo) return 0;
			return netStream.time;
		}
		public function set time(__value:Number): void {
			if (!_hasVideo) return;
			netStream.seek(__value);
			updateMaximumTime();
		}

		public function get position(): Number {
			if (!_hasVideo) return 0;
			if (!_hasMetaData) return 0;
			return time / duration;
		}
		public function set position(__value:Number): void {
			if (!_hasVideo) return;
			if (!_hasMetaData) return;
			time = __value * duration;
		}

		public function get bufferLength(): Number {
			if (!_hasVideo) return 0;
			return netStream.bufferLength;
		}
		
		public function get autoPlay(): Boolean {
			return _autoPlay;
		}
		public function set autoPlay(__value:Boolean): void {
			_autoPlay = __value;
		}

		public function get bufferTime(): Number {
			return _bufferTime;
		}
		public function set bufferTime(__value:Number): void {
			_bufferTime = __value;
			applyBufferTime();
		}
		
		public function get volume():Number {
			return _volume;
		}
		public function set volume(__value:Number):void {
			_volume = __value;
			applyVolume();
		}

		public function get loop(): Boolean {
			return _loop;
		}
		public function set loop(__value:Boolean): void {
			_loop = __value;
		}
		
		override public function get loadedPercent(): Number {
			if (!_isLoaded) updateByteCount();
			return super.loadedPercent;
		}
		
		public function get hasVideo():Boolean {
			return _hasVideo;
		}
		
		public function get hasMetaData():Boolean {
			return _hasMetaData;
		}

		public function getLastCuePoint(): Object {
			return lastCuePoint;
		}
		public function get droppedFrames(): int {
			return _hasVideo ? netStream.info.droppedFrames : 0;
		}
		public function get decodedFrames(): int {
			return _hasVideo ? netStream.decodedFrames : 0;
		}
		
		public function get fps(): int {
			return _hasVideo ? netStream.currentFPS : 0;
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
	
	public function onXMPData(info:Object): void {
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