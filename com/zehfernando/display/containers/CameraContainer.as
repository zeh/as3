package com.zehfernando.display.containers {
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	/**
	 * @author zeh
	 */
	public class CameraContainer extends DisplayAssetContainer {

		// Constants
		public static const EVENT_CAMERA_ACTIVATED:String = "onCameraActivated";
		public static const EVENT_CONNECTED:String = "onConnect";
		public static const EVENT_CAMERA_NOT_AVAILABLE:String = "onCameraNotAvailable";

		// Properties
		protected var _isStarted:Boolean;
		protected var _isConnected:Boolean;
		protected var _isRecording:Boolean;
		protected var _video:Video;
		protected var _camera:Camera;
		
		protected var _streamName:String;

		protected var _smoothing:Boolean;
		
		protected var isWaitingForCamera:Boolean;
		
		protected var netConnection:NetConnection;
		protected var netStream:NetStream;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CameraContainer(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000) {
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
			stopRecording();
			disconnect();
			stop();
			super.destroyContent();
		}
		
		protected function redrawSmoothing(): void {
			//if (_isLoaded && Boolean(loader.content)) Bitmap(loader.content).smoothing = _smoothing;
			if (Boolean(_video)) _video.smoothing = false;
		}
		
		protected function startWaitingForCamera(): void {
			if (!isWaitingForCamera) {
				addEventListener(Event.ENTER_FRAME, onEnterFrameWaitForCamera);
				isWaitingForCamera = true;
			}
		}

		protected function stopWaitingForCamera(): void {
			if (isWaitingForCamera) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrameWaitForCamera);
				isWaitingForCamera = false;
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onEnterFrameWaitForCamera(e:Event): void {
			if (_camera.currentFPS > 0) {
				// FPS is higher than 0, therefore it's working
				dispatchEvent(new Event(EVENT_CAMERA_ACTIVATED));
				stopWaitingForCamera();
			}
		}
		
		protected function onNetConnectionStatus(e:NetStatusEvent): void {
			trace ("net status event [info.code="+e.info.code+"] : " + e);

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
						trace("onNetConnectionStatus :: Connection rejected.");
						break;

					//code == NetConnection.Connect.Failed when Netconnection has failed to connect
					//either because your network connection is down or the server address doesn't exist.
					case "NetConnection.Connect.Failed":
						trace("onNetConnectionStatus :: Connection failed.");
						break;

					//code == NetConnection.Connect.Closed when Netconnection has been closed successfully.	
					case "NetConnection.Connect.Closed":
						trace("onNetConnectionStatus :: Connection closed.");
						break;
                }
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------
		
		public function setCameraMode(__width:Number, __height:Number, __fps:Number = 24): void {
			if (!Boolean(_video)) createContent();
			if (Boolean(_camera)) _camera.setMode(__width, __height, __fps);
			_contentWidth = __width;
			_contentHeight = __height;
			_video.width = __width;
			_video.width = __height;
			redraw();
		}

		public function setCameraQuality(__bandwidth:int = 16384, __quality:int = 0):void {
			if (Boolean(_camera)) _camera.setQuality(__bandwidth, __quality);
		}

		public function start(): void {
			if (!_isStarted) {
				
				if (!Boolean(_video)) createContent();
				
				_camera = Camera.getCamera();
				//trace ("camera ==== " + _camera);
				//_camera.setMode(320, 240, 24);
				if (Boolean(_camera)) {
					startWaitingForCamera();
					_video.attachCamera(_camera);
					setCameraMode(320, 240, 24);
					_isStarted = true;
				} else {
					dispatchEvent(new Event(EVENT_CAMERA_NOT_AVAILABLE));
				}
				
				//_contentWidth = 100;
				//_contentHeight = 100;
				

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
				netConnection.removeEventListener(NetStatusEvent.NET_STATUS, onNetConnectionStatus);
				netConnection.connect(null);
				netConnection = null;
				
				_isConnected = false;
			}
		}

		public function startRecording(): void {
			if (!_isRecording) {
				trace ("CameraContainer :: startRecording()");
				netStream = new NetStream(netConnection);
				netStream.client = new Object();
			
				netStream.attachCamera(_camera);
				netStream.publish(_streamName, "record");
				
				_isRecording = true;
			}
		}

		public function stopRecording(): void {
			if (_isRecording) {
				trace ("CameraContainer :: stopRecording()");
				
				netStream.close();
				
				_isRecording = false;
			}
		}

		public function stop(): void {
			if (_isStarted) {
				stopWaitingForCamera();
				_video.attachCamera(null);
				_camera = null;
				_isStarted = false;
			}
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// State information ----------------------------------

		public function get isStarted(): Boolean {
			return _isStarted;
		}
		
		public function get smoothing(): Boolean {
			return _smoothing;
		}
		public function set smoothing(__value:Boolean): void {
			_smoothing = __value;
			redrawSmoothing();
		}

		public function getNetStream(): NetStream {
			return netStream;
		}

	}
}
