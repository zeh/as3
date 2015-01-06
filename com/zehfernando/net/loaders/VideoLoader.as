package com.zehfernando.net.loaders {
	import com.zehfernando.utils.MathUtils;
	import com.zehfernando.utils.console.debug;
	import com.zehfernando.utils.console.log;
	import com.zehfernando.utils.getTimerUInt;

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
		protected var netConnectionToRecycle:NetConnection;
		protected var netStreamToRecycle:NetStream;
		protected var _video:Video;

		protected var isMonitoringLoading:Boolean;
		protected var isMonitoringTime:Boolean;

		protected var _metaData:Object;

		protected var _hasStartedLoading:Boolean;

		protected var _hasMetaData:Boolean;
		protected var _isLoading:Boolean;
		protected var _isLoaded:Boolean;

		protected var _timeStartedLoading:uint;
		protected var _timeCompletedLoading:uint;

		protected var _hasVideo:Boolean;

		protected var lastCuePoint:Object;
		protected var _request:URLRequest;

		protected var resumeAfterMetaDataLoad:Boolean;
		protected var pauseAfterMetaDataLoad:Boolean;
		protected var isPlayingToForceMetaDataLoad:Boolean;
		protected var previousSoundTransform:SoundTransform;
		protected var timeStartedWaitingForMetaData:uint;


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function VideoLoader(__netStreamToRecycle:NetStream = null, __netConnectionToRecycle:NetConnection = null) {
			isMonitoringLoading = false;
			isMonitoringTime = false;

			netStreamToRecycle = __netStreamToRecycle;
			netConnectionToRecycle = __netConnectionToRecycle;

			_metaData = {};

			_hasMetaData = false;
			_isLoading = false;
			_isLoaded = false;

			timeStartedWaitingForMetaData = 0;

			_netConnection = netConnectionToRecycle == null ? new NetConnection() : netConnectionToRecycle;
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetError);
			if (netConnectionToRecycle == null) _netConnection.connect(null);

			if (netStreamToRecycle == null) {
				// New netstream
				_netStream = new NetStream(_netConnection);
			} else {
				// Recycled netstream
				_netStream = netStreamToRecycle;
				_netStream.dispose();
			}
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

			_video = new Video(100, 100);
			_video.attachNetStream(_netStream);
			addChild(_video);

			_hasVideo = true;
		}


		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------

		protected function startMonitoringLoading():void {
			if (!isMonitoringLoading) {
				isMonitoringLoading = true;
				addEventListener(Event.ENTER_FRAME, onEnterFrameMonitorLoading, false, 0, true);
				//onEnterFrameMonitorLoading(null);
			}
		}

		protected function stopMonitoringLoading():void {
			if (isMonitoringLoading) {
				isMonitoringLoading = false;
				removeEventListener(Event.ENTER_FRAME, onEnterFrameMonitorLoading);
			}
		}

		protected function startMonitoringTime():void {
			if (!isMonitoringTime) {
				isMonitoringTime = true;
				addEventListener(Event.ENTER_FRAME, onEnterFrameMonitorTime, false, 0, true);
			}
		}

		protected function stopMonitoringTime():void {
			if (isMonitoringTime) {
				isMonitoringTime = false;
				removeEventListener(Event.ENTER_FRAME, onEnterFrameMonitorTime);
			}
		}

		protected function startPlayingToForceMetaDataLoad():void {
			if (!isPlayingToForceMetaDataLoad) {
				debug("Started waiting for forced metadata load");
				isPlayingToForceMetaDataLoad = true;
				previousSoundTransform = _netStream.soundTransform;
				_netStream.soundTransform = new SoundTransform(0, 0);
				_netStream.resume();
				//seek(1);
			}
		}

		protected function stopPlayingToForceMetaDataLoad():void {
			if (isPlayingToForceMetaDataLoad && _netStream != null) {
				debug("Stopped waiting for forced metadata load");
				isPlayingToForceMetaDataLoad = false;
				seek(0);
				_netStream.pause();
				_netStream.soundTransform = previousSoundTransform;
				previousSoundTransform = null;

				//if (pauseAfterMetaDataLoad) pause();
				//if (resumeAfterMetaDataLoad) resume();
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

		public function onTextData(__newData:Object):void {
			log ("##### TEXT DATA : " + JSON.stringify(__newData));
		}

		public function onSeekPoint(__newData:Object):void {
			log ("##### SEEK POINT DATA : " + JSON.stringify(__newData));
		}

		public function onImageData(__newData:Object):void {
			log ("##### IMAGE DATA : " + JSON.stringify(__newData));
		}

		public function onMetaData(__newData:Object):void {
			for (var iis:String in __newData) {
				//Log.echo(" --> " + iis + " = " + __newData[iis]);
				_metaData[iis] = __newData[iis];
			}

			//log(_request.url + " METADATA ==============> " + JSON.encode(_metaData));

			//log (">>> meta data received");

			_hasMetaData = true;
			stopPlayingToForceMetaDataLoad();

			dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.RECEIVED_METADATA));

			//if (_isLoading) onEnterFrameMonitorLoading(null);
			//log(">>>>> " + _isLoading, _netStream.bytesLoaded, _netStream.bytesTotal);
			//onEnterFrameMonitorLoading(null);
			onEnterFrameMonitorTime(null);

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

			Another (SAME f4v, twice!!):
{
	"videocodecid" : "avc1",
	"seekpoints" : [
		{
			"time" : 0,
			"offset" : 18781
		},
		{
			"time" : 0.542,
			"offset" : 192561
		},
		{
			"time" : 1.917,
			"offset" : 649419
		},
		{
			"time" : 2.208,
			"offset" : 738741
		},
		{
			"time" : 3.583,
			"offset" : 1024958
		},
		{
			"time" : 4.958,
			"offset" : 1327587
		},
		{
			"time" : 5.417,
			"offset" : 1455272
		},
		{
			"time" : 6.792,
			"offset" : 1599767
		},
		{
			"time" : 8.167,
			"offset" : 1844573
		},
		{
			"time" : 9.542,
			"offset" : 2184481
		},
		{
			"time" : 10.917,
			"offset" : 2536579
		},
		{
			"time" : 12.292,
			"offset" : 2787705
		}
	],
	"width" : 1280,
	"avcprofile" : 100,
	"height" : 720,
	"aacaot" : 2,
	"avclevel" : 51,
	"audiocodecid" : "mp4a",
	"moovposition" : 36,
	"audiosamplerate" : 44100,
	"videoframerate" : 24,
	"trackinfo" : [
		{
			"sampledescription" : [
				{
					"sampletype" : "avc1"
				}
			],
			"language" : "eng",
			"timescale" : 90000,
			"length" : 1188750
		},
		{
			"sampledescription" : [
				{
					"sampletype" : "mp4a"
				}
			],
			"language" : "eng",
			"timescale" : 44100,
			"length" : 584704
		},
		{
			"sampledescription" : [
				{
					"sampletype" : "amf0"
				}
			],
			"language" : "eng",
			"timescale" : 90000,
			"length" : 1188750
		}
	],
	"duration" : 13.25859410430839,
	"audiochannels" : 2
}
{
	"videocodecid" : 7,
	"videodatarate" : 1799.998,
	"framerate" : 24,
	"seekpoints" : [
		{
			"time" : 0,
			"offset" : 18781
		},
		{
			"time" : 0.542,
			"offset" : 192561
		},
		{
			"time" : 1.917,
			"offset" : 649419
		},
		{
			"time" : 2.208,
			"offset" : 738741
		},
		{
			"time" : 3.583,
			"offset" : 1024958
		},
		{
			"time" : 4.958,
			"offset" : 1327587
		},
		{
			"time" : 5.417,
			"offset" : 1455272
		},
		{
			"time" : 6.792,
			"offset" : 1599767
		},
		{
			"time" : 8.167,
			"offset" : 1844573
		},
		{
			"time" : 9.542,
			"offset" : 2184481
		},
		{
			"time" : 10.917,
			"offset" : 2536579
		},
		{
			"time" : 12.292,
			"offset" : 2787705
		}
	],
	"width" : 1280,
	"avcprofile" : 100,
	"audiodelay" : 0.036,
	"height" : 720,
	"aacaot" : 2,
	"avclevel" : 51,
	"audiodatarate" : 112,
	"audiocodecid" : 10,
	"canSeekToEnd" : true,
	"moovposition" : 36,
	"audiosamplerate" : 44100,
	"videoframerate" : 24,
	"trackinfo" : [
		{
			"sampledescription" : [
				{
					"sampletype" : "avc1"
				}
			],
			"language" : "eng",
			"timescale" : 90000,
			"length" : 1188750
		},
		{
			"sampledescription" : [
				{
					"sampletype" : "mp4a"
				}
			],
			"language" : "eng",
			"timescale" : 44100,
			"length" : 584704
		},
		{
			"sampledescription" : [
				{
					"sampletype" : "amf0"
				}
			],
			"language" : "eng",
			"timescale" : 90000,
			"length" : 1188750
		}
	],
	"duration" : 13.208,
	"audiochannels" : 2
}
			*/
		}

		public function onCuePoint(__cueInfo:Object):void {
			//log(" --> time=" + __cueInfo["time"] + " name=" + __cueInfo["name"] + " type=" + __cueInfo["type"]);
			//lastCuePoint = info;
			dispatchEvent(new VideoLoaderCuePointEvent(VideoLoaderCuePointEvent.CUE_POINT, false, false, __cueInfo["time"], __cueInfo["name"], __cueInfo["type"], __cueInfo["parameters"]));
			//log ("--> " + typeof __cueInfo.parameters);
 		    //for (var iis:String in __cueInfo.parameters) log(iis, __cueInfo.parameters[iis], typeof __cueInfo.parameters[iis]);
		}

		// Other events
		protected function onLoadStart():void {
			// Pseudo-event
			_timeStartedLoading = getTimerUInt();
			_hasStartedLoading = true;
			//log(url);
			dispatchEvent(new Event(Event.OPEN));
		}

		protected function onLoadProgress():void {
			// Pseudo-event
			//log(url + " / bytes = " + bytesLoaded + " / " + bytesTotal);
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, bytesLoaded, bytesTotal));
		}

		protected function onLoadComplete():void {
			// Pseudo-event
			//log(url);

			_isLoaded = true;
			_timeCompletedLoading = getTimerUInt();
			stopMonitoringLoading();

			dispatchEvent(new Event(Event.COMPLETE));
		}

		protected function onEnterFrameMonitorLoading(e:Event):void {
			// Some load progress has been made

			//log("HAS META = " + _hasMetaData);

			if (!_hasStartedLoading) {
				// First loading event
				onLoadStart();
			}

			// Continue loading
			onLoadProgress();

			if (bytesLoaded > 0) {
				if (bytesTotal > 0 && bytesLoaded >= bytesTotal) {
					if (_hasMetaData) {
						// Completed loading
						if (isPlayingToForceMetaDataLoad) {
							//debug("Received metadata later");
							stopPlayingToForceMetaDataLoad();
						}
						//debug("Finished loading");
						onLoadComplete();
					} else {
						// Fix for videos that complete loading without onMetaData dispatched
						if (!isPlayingToForceMetaDataLoad) {
							if (timeStartedWaitingForMetaData == 0) {
								//debug("Completed loading but doesn't have metadata yet! Waiting some more");
								timeStartedWaitingForMetaData = getTimerUInt();
							} else {
								if (getTimerUInt() > timeStartedWaitingForMetaData + 750) {
									//warn("Too much time passed, forcing video playback");
									startPlayingToForceMetaDataLoad();
								}
							}
						}
					}
				}
			}
		}

		protected function onEnterFrameMonitorTime(e:Event):void {
			if (!isPlayingToForceMetaDataLoad) {
				dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.TIME_CHANGE));
			}
		}

		public function onPlayStatus(__newData:Object):void {
			//log ("##### PLAY STATUS DATA : " + JSON.stringify(__newData));
			// NetStream.Play.Switch
			// NetStream.Play.Complete
			// NetStream.Play.TransitionComplete
			switch (__newData["code"]) {
				case "NetStream.Play.Complete":
					pause();
					dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.PLAY_FINISH));
					break;
			}
		}

		public function onNetStatus(__e:NetStatusEvent):void {
			//log ("##### NET STATUS CODE : " + event.info["code"]);

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

			NEW (Flash 11)
			Starting:
			NetConnection.Connect.Success
			NetStream.Pause.Notify
			NetStream.Play.Start

			Plus:
			NetStream.Unpause.Notify
			NetStream.Buffer.Full
			NetStream.Unpause.Notify
			NetStream.Buffer.Flush
			NetStream.Play.Stop
			NetStream.SeekStart.Notify
			PLAY STATUS DATA : {"code":"NetStream.Play.Complete","level":"status"}
			NetStream.Seek.Notify
			NetStream.Buffer.Full
			NetStream.Seek.Complete
			*/

			//trace ("videocontainer onNetStatus :: " + event.info.code);
			switch (__e.info["code"]) {
				case "NetStream.Play.StreamNotFound":
					log("Stream location [" + _request.url + "] not found!");
					dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.STREAM_NOT_FOUND));
					stopMonitoringLoading();
					break;
				case "NetStream.Seek.Notify":
					dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.SEEK_NOTIFY));
					break;
				case "NetStream.Play.Start":
					// Apparently this only works with streaming netstreams?
					//trace ("netstream.play.start " + _contentURL);
					startMonitoringTime();
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
					stopMonitoringTime();
					dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.PLAY_STOP));
					break;
			}
		}

		protected function onNetError(__e:SecurityErrorEvent):void {
			log("securityErrorHandler: " + __e);
			dispatchEvent(__e);

			stopMonitoringLoading();
		}


		// ================================================================================================================
		// PUBLIC API functions -------------------------------------------------------------------------------------------

		public function load(__request:URLRequest):void {
			_request = __request;
			_isLoaded = false;
			_isLoading = true;
			_hasStartedLoading = false;

			_netStream.play(__request.url);
			_netStream.pause();

			startMonitoringLoading();
		}

		public function dispose(__skipNetStreamAndNetConnectionDisposal:Boolean = false):void {
			stopMonitoringLoading();
			stopMonitoringTime();

			_isLoaded = false;
			_isLoading = false;
			_hasMetaData = false;
			_request = null;
			previousSoundTransform = null;

			netConnectionToRecycle = null;
			netStreamToRecycle = null;

			_metaData = {};

			if (_hasVideo) {
				_video.attachNetStream(null);
				removeChild(_video);
				_video = null;

				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_netStream.pause();
				_netStream.client = {};
				if (!__skipNetStreamAndNetConnectionDisposal) _netStream.dispose(); // .close()
				_netStream = null;

				_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_netConnection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetError);
				_netConnection.close();
				_netConnection = null;

				_hasVideo = false;
			}
		}

		// Functions that extend the existing objects

		public function resume():void {
			if (_hasVideo) {
				//log(">>>>>>>>>>>>>>> resume");
				//logStackTrace();
				if (!_hasMetaData || isPlayingToForceMetaDataLoad) {
					resumeAfterMetaDataLoad = true;
					pauseAfterMetaDataLoad = false;
				} else {
					resumeAfterMetaDataLoad = false;
					pauseAfterMetaDataLoad = false;
					_netStream.resume();
					startMonitoringTime();
					dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.RESUME));
				}
			}
		}

		public function pause():void {
			if (_hasVideo) {
				//log(">>>>>>>>>>>>>>> pause");
				if (!_hasMetaData || isPlayingToForceMetaDataLoad) {
					resumeAfterMetaDataLoad = false;
					pauseAfterMetaDataLoad = true;
				} else {
					resumeAfterMetaDataLoad = false;
					pauseAfterMetaDataLoad = false;
					_netStream.pause();
					stopMonitoringTime();
					dispatchEvent(new VideoLoaderEvent(VideoLoaderEvent.PAUSE));
				}
			}
		}

		public function seek(__timeSeconds:Number):void {
			if (_hasVideo) {
				_netStream.seek(__timeSeconds);
				onEnterFrameMonitorTime(null);
			}
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		// Self properties

		public function get hasMetaData():Boolean {
			return _hasMetaData;
		}

		public function get customMetaData(): Object {
			// TODO: rename this, since AS3 now includes a metadata object
			return _metaData;
		}

		// Properties that extend existing objects

		public function get bufferLength():Number {
			return _netStream.bufferLength;
		}

		public function get bufferTime():Number {
			return _netStream.bufferTime;
		}
		public function set bufferTime(__value:Number):void {
			_netStream.bufferTime = __value;
		}

		public function get time():Number {
			return _hasVideo ? _netStream.time : 0;
		}

		public function get duration():Number {
			return _metaData["duration"];
		}

		public function get framerate():Number {
			return _metaData["framerate"];
		}

		public function get smoothing():Boolean {
			return _video.smoothing;
		}
		public function set smoothing(__value:Boolean):void {
			_video.smoothing = __value;
		}

		public function get bytesLoaded():uint {
			return _hasVideo ? _netStream.bytesLoaded : 0;
		}

		public function get bytesTotal():uint {
			return _hasVideo && _netStream.bytesTotal < 0xffffffff ? _netStream.bytesTotal : 0;
		}

		public function get decodedFrames():uint {
			return _hasVideo ? _netStream.decodedFrames : 0;
		}

		public function get droppedFrames():uint {
			return _hasVideo ? _netStream.info.droppedFrames : 0;
		}

		public function get currentFPS():Number {
			return _hasVideo ? _netStream.currentFPS : 0; // The number of frames per second being displayed. If you are exporting video files to be played back on a number of systems, you can check this value during testing to help you determine how much compression to apply when exporting the file
		}

		override public function get soundTransform(): SoundTransform {
			return _hasVideo ? _netStream.soundTransform : null;
		}
		override public function set soundTransform(__value:SoundTransform):void {
			if (_hasVideo) _netStream.soundTransform = __value;
		}

		public function get url():String {
			return Boolean(_request) ? _request.url : null;
		}

		public function getLoadingSpeed():Number {
			// Returns the loading speed, in bytes per second
			if (_isLoading) {
				return bytesLoaded / ((getTimerUInt() - _timeStartedLoading) / 1000);
			} else if (_isLoaded) {
				return bytesLoaded / ((_timeCompletedLoading - _timeStartedLoading) / 1000);
			}
			return 0;
		}

		public function getFullBufferingLevel():Number {
			// Returns a number between 0 and 1 that's the percentage of data that is loaded to provide a full non-stop playback
			// 0 = nothing loaded; 1 = can probably provide a nonstop playback
			if (bytesTotal > 0 && bytesLoaded >= bytesTotal) return 1;
			//log (duration, _hasMetaData, bytesTotal, bytesLoaded, _timeStartedLoading);
			if (duration == 0 || !_hasMetaData || bytesTotal == 0 || isNaN(_timeStartedLoading)) return 0;
			if (_isLoaded) return 1;
			var remainingPlaybackTime:Number = duration - time;									// Remaining video playback time, in seconds
			var remainingLoadingTime:Number = (bytesTotal - bytesLoaded) / getLoadingSpeed();	// Time needed to play the remaining data, in seconds
			//return remainingLoadingTime <= remainingPlaybackTime;
			return MathUtils.clamp(remainingPlaybackTime / remainingLoadingTime);
		}

		public function get video():Video {
			return _video;
		}

		public function get netStream():NetStream {
			return _netStream;
		}

		public function get netConnection():NetConnection {
			return _netConnection;
		}
	}
}
