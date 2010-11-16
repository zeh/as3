package com.zehfernando.display.containers {
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * @author zeh
	 */
	public class NetStreamContainer  extends DisplayAssetContainer {
		
		// Ugh

		// Constants
		public static const EVENT_CONNECTED:String = "onConnect";
		public static const EVENT_PLAYBACK_COMPLETE:String = "onPlaybackComplete";

		// Properties
		protected var _isStarted:Boolean;
		protected var _isConnected:Boolean;
		protected var _isStreaming:Boolean;
		protected var _video:Video;
		
		protected var _smoothing:Boolean;

		protected var _streamName:String;

		protected var netConnection:NetConnection;
		protected var netStream:NetStream;

		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function NetStreamContainer(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000) {
			super (__width, __height, __color);
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		override protected function createContent(): void {
			super.createContent();
			_isStarted = false;
			_video = new Video(100, 100);
			_video.smoothing = _smoothing;
			addAsset(_video);
		}

		override protected function destroyContent(): void {
			stopStreaming();
			disconnect();
			stop();
			super.destroyContent();
		}
		
		protected function redrawSmoothing(): void {
			//if (_isLoaded && Boolean(loader.content)) Bitmap(loader.content).smoothing = _smoothing;
			if (Boolean(_video)) _video.smoothing = false;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onNetConnectionStatus(e:NetStatusEvent): void {
			trace ("NetStreamContainer :: net status event [info.code="+e.info.code+"] : " + e);

			var info:Object = e.info;

                //Checking the event.info.code for the current NetConnection status string	
                switch (info.code) {
					//code == NetConnection.Connect.Success when Netconnection has successfully
					//connected
					case "NetConnection.Connect.Success":
						dispatchEvent(new Event(EVENT_CONNECTED));
						break;
					//code == NetConnection.Connect.Rejected when Netconnection did
					//not have permission to access the application.		
						case "NetConnection.Connect.Rejected":
						trace("NetStreamContainer :: onNetConnectionStatus :: Connection rejected.");
						break;

					//code == NetConnection.Connect.Failed when Netconnection has failed to connect
					//either because your network connection is down or the server address doesn't exist.
					case "NetConnection.Connect.Failed":
						trace("NetStreamContainer :: onNetConnectionStatus :: Connection failed.");
						break;

					//code == NetConnection.Connect.Closed when Netconnection has been closed successfully.	
					case "NetConnection.Connect.Closed":
						trace("NetStreamContainer :: onNetConnectionStatus :: Connection closed.");
						break;
                }
		}
		
		protected function onMetaData(info:Object): void {
            //trace("onMetaData: duration=" + info.duration + " framerate=" + info.framerate);
     	}

		protected function onPlayStatus(info:Object): void {
            //trace("onPlayStatus: status=" + info.code);
            if (info.code == "NetStream.Play.Complete") {
            	// Completed
            	dispatchEvent(new Event(EVENT_PLAYBACK_COMPLETE));
            }
     	}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function start(): void {
			if (!_isStarted) {
				if (!Boolean(_video)) createContent();
				_isStarted = true;
				_contentWidth = 100;
				_contentHeight = 100;
				redraw();
			}
		}

		public function connect(__url:String, __streamName:String):void {
			if (!_isConnected) {
				_streamName = __streamName;
				netConnection = new NetConnection();
                netConnection.addEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
				netConnection.connect(__url);
				
				_isConnected = true;
			}
		}

		public function disconnect(): void {
			if (_isConnected) {
				stopStreaming();
				netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
				netConnection.connect(null);
				netConnection = null;
				
				_isConnected = false;
			}
		}

		public function startStreaming(): void {
			if (!_isStreaming) {
				trace ("NetStreamContainer :: startStreaming()");
				netStream = new NetStream(netConnection);
				//netStream.client = new Object();
				netStream.client = {onMetaData:onMetaData, onPlayStatus:onPlayStatus};
				
				_video.attachNetStream(netStream);
			
				_isStreaming = true;
			}
		}

		public function stopStreaming(): void {
			if (_isStreaming) {
				trace ("NetStreamContainer :: stopStreaming()");
				_video.attachNetStream(null);
				netStream.close();
				
				_isStreaming = false;
			}
		}

		public function play(__context:String): void {
			trace ("NetStreamContainer :: play()");
			startStreaming();
			if (_isStreaming) {
				trace (" --> "+ __context);
				netStream.play(__context);
			}
		}
		public function stop(): void {
			stopStreaming();
			// Ugh
			if (_isStarted) {
				_isStarted = false;
			}
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// State information ----------------------------------

		public function get smoothing(): Boolean {
			return _smoothing;
		}
		public function set smoothing(__value:Boolean): void {
			_smoothing = __value;
			redrawSmoothing();
		}
		
		public function get isConnected(): Boolean {
			return _isConnected;
		}
	}
}
