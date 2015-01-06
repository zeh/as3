package com.zehfernando.display.containers {
	import com.zehfernando.utils.console.log;
	import com.zehfernando.utils.getTimerUInt;

	import flash.display.BitmapData;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.Video;


	/**
	 * @author zeh
	 */
	public class CameraContainer extends DisplayAssetContainer {

		// Events
		public static const EVENT_CAMERA_ACTIVATED:String = "onCameraActivated";
		public static const EVENT_CAMERA_NOT_AVAILABLE:String = "onCameraNotAvailable";
		public static const EVENT_CAMERA_DENIED:String = "onCameraDenied";
		public static const EVENT_AUTO_SELECT_SUCCESS:String = "onAutoSelectSuccess";
		public static const EVENT_AUTO_SELECT_FAILED:String = "onAutoSelectFailed";

		// Constants
		public static const TIME_TO_WAIT_FOR_VALID_ACTIVITY:Number = 100;	// Time, in ms, to wait for camera activity during auto-selection process (when activity is higher than -1)
		public static const TIME_TO_WAIT_FOR_ANY_ACTIVITY:Number = 500;		// Time, in ms, to wait for camera activity during auto-selection process (after starting, even if it's still -1)

		// Properties
		protected var _isStarted:Boolean;
		protected var _isConnected:Boolean;
		protected var _video:Video;
		protected var _camera:Camera;
		protected var isFindingActiveCameras:Boolean;
		protected var autoSelectFirstActiveCamera:Boolean;
		protected var lastCameraTried:int;
		protected var timeStartedCheckingCamera:uint;
		protected var timeStartedCheckingCameraHadActivity:uint;

		protected var _streamName:String;

		protected var _smoothing:Boolean;

		protected var isWaitingForCamera:Boolean;

		protected var validCameras:Vector.<Boolean>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function CameraContainer(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000) {
			super (__width, __height, __color);
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		override protected function setDefaultData():void {
			super.setDefaultData();

			_isStarted = false;
		}

		override protected function createContentHolder():void {
			super.createContentHolder();

			_video = new Video(100, 100);
			redrawSmoothing();
			setAsset(_video, 100, 100);
		}

		protected function redrawSmoothing():void {
			//if (_isLoaded && Boolean(loader.content)) Bitmap(loader.content).smoothing = _smoothing;
			if (Boolean(_video)) _video.smoothing = _smoothing;
		}

		protected function startWaitingForCamera():void {
			if (!isWaitingForCamera) {
				_camera.addEventListener(StatusEvent.STATUS, onCameraChangeStatus);
				addEventListener(Event.ENTER_FRAME, onEnterFrameWaitForCamera);
				isWaitingForCamera = true;
			}
		}

		protected function stopWaitingForCamera():void {
			if (isWaitingForCamera) {
				_camera.removeEventListener(StatusEvent.STATUS, onCameraChangeStatus);
				removeEventListener(Event.ENTER_FRAME, onEnterFrameWaitForCamera);
				isWaitingForCamera = false;
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onEnterFrameWaitForCamera(e:Event):void {
			//Console.log("waiting for camera..." + _camera.muted);

			// TODO: checking currentfps is bad... for some reason it doesn't always work (just first time?). Using mute is better,
			// so it's probably better to use the change status event only instead
			if (_camera.currentFPS > 0 || !_camera.muted) {
				// FPS is higher than 0, therefore it's working
				dispatchEvent(new Event(EVENT_CAMERA_ACTIVATED));
				stopWaitingForCamera();
			}
		}

		protected function onCameraChangeStatus(e:Event):void {
			log("camera changed status: " + e);
			if (_camera.muted) {
				stop();
				dispatchEvent(new Event(EVENT_CAMERA_DENIED));
			}
		}

		protected function tryNextCamera():void {
			var cam:int = lastCameraTried + 1;

			if (cam < Camera.names.length) {
				lastCameraTried = cam;

				log("Trying camera ["+lastCameraTried+"] : " + Camera.names[lastCameraTried] + "...");
				timeStartedCheckingCamera = -1;
				timeStartedCheckingCameraHadActivity = -1;
				setCamera(lastCameraTried);
				addEventListener(Event.ENTER_FRAME, onWaitForRealCameraActivity);
			} else {
				// Finished testing all cameras

				stopFindingActiveCameras();

				if (getNumValidCameras() > 0) {
					// Has at least one valid camera
					log("Found at least one valid camera!!!");

					if (autoSelectFirstActiveCamera) {
						// Pick the first valid camera
						setCamera(validCameras.indexOf(true));
					} else {
						// Pick the default camera
						setCamera();
					}

					dispatchEvent(new Event(EVENT_AUTO_SELECT_SUCCESS));
				} else {
					// No valid cameras found
					log("Could not find valid camera!!!");
					dispatchEvent(new Event(EVENT_AUTO_SELECT_FAILED));
				}
			}
		}

		protected function setCamera(__index:int = -1):void {
			unsetCamera();
			_camera = Camera.getCamera(__index == -1 ? null : __index.toString(10));
			if (Boolean(_camera)) {
				_video.attachCamera(_camera);
				_camera.setMotionLevel(0);
				_camera.addEventListener(ActivityEvent.ACTIVITY, onActivityOnCamera);
				setCameraMode(320, 240, 20);
				startWaitingForCamera();
			}
		}

		protected function unsetCamera():void {
			if (Boolean(_camera)) {
				_camera.removeEventListener(ActivityEvent.ACTIVITY, onActivityOnCamera);
				stopWaitingForCamera();
				_video.attachCamera(null);
				_camera = null;
			}
		}
		protected function stopFindingActiveCameras():void {
			if (isFindingActiveCameras) {
				isFindingActiveCameras = false;
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onActivityOnCamera(e:ActivityEvent):void {
			// ...
		}

		protected function onWaitForRealCameraActivity(e:Event):void {
			if (_camera.activityLevel > 0) {
				// Real camera active
				onCurrentAutoCameraActivity();
			} else {
				if (timeStartedCheckingCamera == -1) {
					timeStartedCheckingCamera = getTimerUInt();
				}

				if (_camera.activityLevel > -1) {
					// Camera is somehow active, continue waiting
					if (timeStartedCheckingCameraHadActivity == -1) {
						// First time active, set the time it started
						timeStartedCheckingCameraHadActivity = getTimerUInt();
					} else if (timeStartedCheckingCameraHadActivity + TIME_TO_WAIT_FOR_VALID_ACTIVITY < getTimerUInt()) {
						// Waited for too long
						onCurrentAutoCameraNoActivity();
					}
				} else {
					if (timeStartedCheckingCamera + TIME_TO_WAIT_FOR_ANY_ACTIVITY < getTimerUInt()) {
						// Too long without any activity
						onCurrentAutoCameraNoActivity();
					}
				}
			}
		}

		protected function onCurrentAutoCameraActivity():void {
			// While waiting for a camera, it had activity
			log("Camera is active!!");
			validCameras[lastCameraTried] = true;
			removeEventListener(Event.ENTER_FRAME, onWaitForRealCameraActivity);
			tryNextCamera();
			// TODO: skip next if must short-circuit for a quicker camera selection?
		}

		protected function onCurrentAutoCameraNoActivity():void {
			// While waiting for a camera, it failed to have any activity
			log("Camera is not active!!");
			validCameras[lastCameraTried] = false;
			removeEventListener(Event.ENTER_FRAME, onWaitForRealCameraActivity);
			tryNextCamera();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getFrame(): BitmapData {
			// Captures the current frame as a BitmapData
			var bmp:BitmapData = new BitmapData(_contentWidth, _contentHeight, false, 0x000000);

			var mtx:Matrix = new Matrix();
			mtx.scale(_contentWidth/100, _contentHeight/100);
			//mtx.scale(video.width/_contentWidth, video.height/_contentHeight);
			bmp.draw(_video, mtx);
			return bmp;
		}

		public function setCameraMode(__width:Number, __height:Number, __fps:Number = 24):void {
			if (Boolean(_camera)) _camera.setMode(__width, __height, __fps);
			_contentWidth = __width;
			_contentHeight = __height;
			_video.width = __width;
			_video.height = __height;
			redraw();
		}

		public function setCameraQuality(__bandwidth:int = 16384, __quality:int = 0):void {
			if (Boolean(_camera)) _camera.setQuality(__bandwidth, __quality);
		}

		public function start():void {
			// Start capturing from user
			if (!_isStarted) {

				setCamera();
				//trace ("camera ==== " + _camera);
				//_camera.setMode(320, 240, 24);
				if (Boolean(_camera)) {
					_isStarted = true;
				} else {
					log("Camera not available");
					dispatchEvent(new Event(EVENT_CAMERA_NOT_AVAILABLE));
				}

				//_contentWidth = 100;
				//_contentHeight = 100;

				redraw();
			}
		}

		public function findActiveCameras(__autoSelect:Boolean = false):void {
			// Cycle through cameras, automatically selecting the valid one
			// If __tryAll is true, continue picking cameras even when a valid camera is found (useful to find ALL valid cameras)
			if (!isFindingActiveCameras) {
				isFindingActiveCameras = true;
				autoSelectFirstActiveCamera = __autoSelect;

				validCameras = new Vector.<Boolean>(Camera.names.length);

				log("auto-selecting camera...");

				lastCameraTried = -1;

				tryNextCamera();
			}
		}

		public function stop():void {
			if (_isStarted) {
				unsetCamera();
				_isStarted = false;
			}
		}

		public function getNumValidCameras():int {
			// Returns the number of valid cameras, after a findActiveCameras() call
			var c:int = 0;
			for (var i:int = 0; i < validCameras.length; i++) {
				if (validCameras[i]) c++;
			}
			return c;
		}

		override public function dispose():void {
			stopFindingActiveCameras();
			stop();
			removeAsset();
			_video = null;

			super.dispose();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		// State information ----------------------------------

		public function get isStarted():Boolean {
			return _isStarted;
		}

		public function get smoothing():Boolean {
			return _smoothing;
		}
		public function set smoothing(__value:Boolean):void {
			_smoothing = __value;
			redrawSmoothing();
		}

		public function get muted():Boolean {
			return Boolean(_camera) ? _camera.muted : false;
		}

		public function get currentFPS():Number {
			return Boolean(_camera) ? _camera.currentFPS : 0;
		}

		public function get fps():Number {
			return Boolean(_camera) ? _camera.fps : 0;
		}

		public function get activityLevel():Number {
			return Boolean(_camera) ? _camera.activityLevel : 0;
		}

		public function get bandwidth():int {
			return Boolean(_camera) ? _camera.bandwidth : 0;
		}

		public function get cameraWidth():int {
			return Boolean(_camera) ? _camera.width : 0;
		}

		public function get cameraHeight():int {
			return Boolean(_camera) ? _camera.height : 0;
		}

		public function get cameraName():String {
			return Boolean(_camera) ? _camera.name : null;
		}

	}
}
