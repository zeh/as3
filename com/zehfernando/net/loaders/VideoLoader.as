package com.zehfernando.net.loaders {

	import com.zehfernando.utils.Console;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;

	/**
	 * @author zeh
	 */
	public class VideoLoader extends Sprite {

		/* Dispatches:

		SecurityErrorEvent.SECURITY_ERROR
		
		Event.OPEN
		ProgressEvent.PROGRESS
		Event.COMPLETE
		
		VideoLoaderEvent.*

		VideoLoaderCuePointEvent.CUE_POINT

		*/

		// Properties
		protected var _netConnection:NetConnection;
		protected var _netStream:NetStream;
		protected var _video:Video;

		protected var isMonitoringLoading:Boolean;
		protected var _metaData:Object;
		
		protected var _hasStartedLoading:Boolean;

		protected var _hasMetaData:Boolean;
		protected var _isLoading:Boolean;
		protected var _isLoaded:Boolean;
		
		protected var _hasVideo:Boolean;

		protected var lastCuePoint:Object;
		protected var _request:URLRequest;

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function VideoLoader() {
			isMonitoringLoading = false;

			_metaData = {};

			_hasMetaData = false;
			_isLoading = false;
			_isLoaded = false;
			
			_netConnection = new NetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
    		_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetError);
			_netConnection.connect(null);

			_netStream = new NetStream(_netConnection);
			_netStream.checkPolicyFile = true;
			_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_netStream.client = this;

			_video = new Video(100, 100);
			_video.attachNetStream(_netStream);
			addChild(_video);

			_hasVideo = true;
		}
			

		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------
		
		protected function startMonitoringLoading(): void {
			if (!isMonitoringLoading) {
				isMonitoringLoading = true;
				addEventListener(Event.ENTER_FRAME, onEnterFrameMonitorLoading, false, 0, true);
				//onEnterFrameMonitorLoading(null);
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

		public function	onXMPData(__newData:Object):void {
//			Log.echo(" --> " + __newData);
			__newData; // ugh, to remove warning
//			for (var iis:String in __newData) {
//	    		Log.echo(" --> " + iis + " = " + __newData[iis]);
//	    	}
			dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.RECEIVED_XMP_DATA));
		} 
	
	    public function onMetaData(__newData:Object):void {
	    	for (var iis:String in __newData) {
	    		//Log.echo(" --> " + iis + " = " + __newData[iis]);
	    		_metaData[iis] = __newData[iis];
	    	}
			_hasMetaData = true;
			dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.RECEIVED_METADATA));
			
			/* Examples of metadata (received from a f4v video encoded in after effects):
			aacaot = 2
			audiochannels = 2
			audiocodecid = 10
			audiocodecid = mp4a
			audiodatarate = 128
			audiodelay = 0.036
			audiosamplerate = 44100
			avclevel = 51
			avcprofile = 100
			canSeekToEnd = true
			duration = 15
			duration = 15.000090702947846
			framerate = 24
			height = 720
			moovposition = 36
			seekpoints = [object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object],[object Object]
			trackinfo = [object Object],[object Object],[object Object]
			videocodecid = 7
			videocodecid = avc1
			videodatarate = 1000
			videoframerate = 24
			width = 1280
			*/
	    }
	
	    public function onCuePoint(__cueInfo:Object):void {
			Console.log(" --> time=" + __cueInfo["time"] + " name=" + __cueInfo["name"] + " type=" + __cueInfo["type"]);
	    	//lastCuePoint = info;
	    	dispatchEvent(new VideoLoaderCuePointEvent(VideoLoaderCuePointEvent.CUE_POINT, __cueInfo["time"], __cueInfo["name"], __cueInfo["type"]));
		}

		// Other events
		protected function onLoadStart(): void {
			// Pseudo-event
			_hasStartedLoading = true;
			//Log.echo(url);
			dispatchEvent(new Event(Event.OPEN));
		}

		protected function onLoadProgress(): void {
			// Pseudo-event
			//Log.echo("bytes = " + bytesLoaded + " / " + bytesTotal);
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal));
		}

		protected function onLoadComplete(): void {
			// Pseudo-event
			//Log.echo();

			_isLoaded = true;
			stopMonitoringLoading();

			dispatchEvent(new Event(Event.COMPLETE));
		}

		protected function onEnterFrameMonitorLoading(e:Event): void {
			// Some load progress has been made
			
			if (!_hasStartedLoading) {
				// First loading event
				onLoadStart();
			}
			
			// Continue loading
			onLoadProgress();
			
			if (bytesLoaded > 0) {
				if (bytesTotal > 0 && bytesLoaded >= bytesTotal && _hasMetaData) {
					// Completed loading
					onLoadComplete();
				}
			}
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
                	Console.log("Stream location [" + _request.url + "] not found!");
                	dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.STREAM_NOT_FOUND));
                	stopMonitoringLoading();
                    break;
                case "NetStream.Seek.Notify":
                	dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.SEEK_NOTIFY));
                	break;
                case "NetStream.Play.Start":
                	//trace ("netstream.play.start " + _contentURL);
                	dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.PLAY_START));
                	break;
            	case "NetStream.Buffer.Empty":
            		dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.BUFFER_EMPTY));
            		break;
            	case "NetStream.Buffer.Full":
            		dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.BUFFER_FULL));
					break;
            	case "NetStream.Buffer.Flush":
            		dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.BUFFER_FLUSH));
					break;
            	case "NetStream.Play.Stop":
            		dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.PLAY_STOP));
            		if (time > duration - 0.1) dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.PLAY_FINISH));
            		break;
            }
        }

        protected function onNetError(e:SecurityErrorEvent):void {
			Console.log("securityErrorHandler: " + e);
			dispatchEvent(e);
			
			stopMonitoringLoading();
		}
		
		// ================================================================================================================
		// PUBLIC API functions -------------------------------------------------------------------------------------------
		
		public function load(__request:URLRequest): void {
			
			_request = __request;
			_isLoaded = false;
			_isLoading = true;
			_hasStartedLoading = false;

			_netStream.play(__request.url);
			_netStream.pause();

			startMonitoringLoading();
		}

		public function dispose(): void {
			stopMonitoringLoading();

			_isLoaded = false;
			_isLoading = false;
			_hasMetaData = false;
			
			_metaData = {};

			if (_hasVideo) {
				removeChild(_video);
				_video = null;

				_netStream.pause();
				_netStream.close();
				_netStream = null;

				_netConnection.close();
				_netConnection = null;

				_hasVideo = false;
			}
		}

		// Functions that extend the existing objects
		
		public function resume(): void {
			if (_hasVideo) _netStream.resume();
		}

		public function pause(): void {
			if (_hasVideo) _netStream.pause();
		}
		
		public function seek(__time:Number): void {
			if (_hasVideo) _netStream.seek(__time);
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		// Self properties

		public function get hasMetaData(): Boolean {
			return _hasMetaData;
		}

		public function get metaData(): Object {
			return _metaData;
		}
		
		// Properties that extend existing objects
		
		public function get bufferLength(): Number {
			return _netStream.bufferLength;
		}
		
		public function get bufferTime(): Number {
			return _netStream.bufferTime;
		}
		public function set bufferTime(__value:Number): void {
			_netStream.bufferTime = __value;
		}
		
		public function get time(): Number {
			return _hasVideo ? _netStream.time : 0;
		}

		public function get duration(): Number {
			return _metaData["duration"];
		}

		public function get framerate(): Number {
			return _metaData["framerate"];
		}

		public function get smoothing(): Boolean {
			return _video.smoothing;
		}
		public function set smoothing(__value:Boolean): void {
			_video.smoothing = __value;
		}

		public function get bytesLoaded(): uint {
			return _hasVideo ? _netStream.bytesLoaded : 0;
		}

		public function get bytesTotal(): uint {
			return _hasVideo ? _netStream.bytesTotal : 0;
		}
		
		public function get decodedFrames(): uint {
			return _hasVideo ? _netStream.decodedFrames : 0;
		}
		
		public function get currentFPS(): Number {
			return _hasVideo ? _netStream.currentFPS : 0; // The number of frames per second being displayed. If you are exporting video files to be played back on a number of systems, you can check this value during testing to help you determine how much compression to apply when exporting the file
		}
		
		override public function get soundTransform(): SoundTransform {
			return _hasVideo ? _netStream.soundTransform : null;
		}
		override public function set soundTransform(__value:SoundTransform): void {
			if (_hasVideo) _netStream.soundTransform = __value;
		}
		
		public function get url(): String {
			return Boolean(_request) ? _request.url : null;
		}

//		public function get video(): Video {
//			return _video;
//		}
//
//		public function get netStream(): NetStream {
//			return _netStream;
//		}

//		public function get netConnection(): NetConnection {
//			return _netConnection;
//		}
	}
}
