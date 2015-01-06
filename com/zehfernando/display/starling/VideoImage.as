package com.zehfernando.display.starling {
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;

	import com.zehfernando.data.BitmapDataPool;
	import com.zehfernando.net.loaders.VideoLoader;
	import com.zehfernando.net.loaders.VideoLoaderEvent;
	import com.zehfernando.signals.SimpleSignal;
	import com.zehfernando.utils.MathUtils;
	import com.zehfernando.utils.console.warn;

	import flash.display.BitmapData;
	import flash.display.StageQuality;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;

	/**
	 * @author zeh fernando
	 */
	public class VideoImage extends Image {

		// Properties
		private var loop:Boolean;
		private var _visibility:Number;
		private var url:String;
		private var transparent:Boolean;
		private var _isLoaded:Boolean;
		private var _doNotDisposeOfNetStream:Boolean;

		// Instances
		private var bitmapData:BitmapData;
		private var textureVideo:Texture;
		private var videoLoader:VideoLoader;
		private var videoMatrix:Matrix;

		private var _onFinishedPlaying:SimpleSignal;
		private var _onSeekComplete:SimpleSignal;
		private var _onLoaded:SimpleSignal;

		private var clipRect:Rectangle;
		private var netStreamToRecycle:NetStream;
		private var netConnectionToRecycle:NetConnection;

		// TODO Lee: getting namespace conflict when named as "bounds" - TBD
		private var boundss:Rectangle;

		// Temp properties
		private var wasVisible:Boolean;

		private static var bitmapDataPool:BitmapDataPool = BitmapDataPool.getPool("videoImage");


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoImage(__videoURL:String, __loop:Boolean, __transparent:Boolean, __recycledNetStream:NetStream = null, __recycledNetConnection:NetConnection = null) {
			super(Texture.empty(10, 10));

			url = __videoURL;
			loop = __loop;
			transparent = __transparent;
			_visibility = 1;
			_isLoaded = false;
			netStreamToRecycle = __recycledNetStream;
			netConnectionToRecycle = __recycledNetConnection;

			clipRect = null;
			boundss = new Rectangle(super.x, super.y, super.width, super.height);

			_onFinishedPlaying = new SimpleSignal();
			_onSeekComplete = new SimpleSignal();
			_onLoaded = new SimpleSignal();

			videoMatrix = new Matrix();

			//createBitmapData();

			applyVisibility();

			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function createBitmapData():void {
			if (textureVideo != null) {
				textureVideo.dispose();
				textureVideo = null;
			}

			if (bitmapData != null) {
				bitmapDataPool.put(bitmapData);
				bitmapData = null;
			}

			//previousTexture = texture;
			texture.dispose();
			videoMatrix.identity();

			var w:int = videoLoader.video.videoWidth > 0 ? videoLoader.video.videoWidth : 100;
			var h:int = videoLoader.video.videoHeight > 0 ? videoLoader.video.videoHeight : 100;

			bitmapData = bitmapDataPool.get(w, h, transparent, 0x00000000);

			textureVideo = Texture.fromBitmapData(bitmapData, false, true);
//			textureVideo.root.onRestore = function():void {
//				try {
//					textureVideo.root.uploadBitmapData(bitmapData);
//				} catch (__e:Error) {
//					warn("Caught error when restoring bitmap: " + __e);
//				}
//			};

			videoMatrix.scale(w / 100, h / 100); // Ugh, not sure why it's forcing the original video to be set at a size of 100x100, so it needs a matrix

			texture = textureVideo;

			//var iw:Number = width;
			//var ih:Number = height;

			//readjustSize();

			//width = iw;
			//height = ih;

			adjustDimensions();
		}

		private function updateFrame():void {
			if (visible && stage != null && videoLoader != null && bitmapData != null) {
				if (transparent) bitmapData.fillRect(bitmapData.rect, 0x000000);
				bitmapData.drawWithQuality(videoLoader.video, videoMatrix, null, null, null, false, StageQuality.LOW);
				try {
					textureVideo.root.uploadBitmapData(bitmapData);
				} catch (__e:Error) {
					warn("Caught error when updating bitmap: " + __e);
				}
			}
		}

		private function checkSize():void {
			if (bitmapData == null || bitmapData.width != videoLoader.video.videoWidth || bitmapData.height != videoLoader.video.videoHeight) createBitmapData();
		}

		private function adjustDimensions():void {
			// Based on the bounds and clip rect, adjust position and texture mappings

			if (clipRect == null) {
				// No clipping
				super.x = boundss.x;
				super.y = boundss.y;
				super.width = boundss.width;
				super.height = boundss.height;

				setTexCoordsTo(0, 0, 0);
				setTexCoordsTo(1, 1, 0);
				setTexCoordsTo(2, 0, 1);
				setTexCoordsTo(3, 1, 1);
			} else {
				// Clips
				super.x = Math.max(boundss.left, clipRect.left);
				super.y = clipRect.top;
				//super.y = Math.max(bounds.top, clipRect.top);
				super.width = Math.min(boundss.right, clipRect.right) - super.x;
				super.height = Math.min(boundss.bottom, clipRect.bottom) - super.y;

				// Adjust maps
				var l:Number = MathUtils.map(super.x, boundss.left, boundss.right, 0, 1);
				var r:Number = MathUtils.map(super.x + super.width, boundss.left, boundss.right, 0, 1);
				var t:Number = MathUtils.map(super.y, boundss.top, boundss.bottom, 0, 1);
				var b:Number = MathUtils.map(super.y + super.height, boundss.top, boundss.bottom, 0, 1);

				//while (l > r) l--;
				//while (t > b) t--;

				setTexCoordsTo(0, l, t);
				setTexCoordsTo(1, r, t);
				setTexCoordsTo(2, l, b);
				setTexCoordsTo(3, r, b);

//				log("1=> bounds: " + bounds);
//				log(" => clip: " + clipRect);
//				log(" => adjusted: " + new Rectangle(super.x, super.y, super.width, super.height));
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function onEnterFrame(__e:Event):void {
			updateFrame();
		}

		private function onVideoLoaderReceivedMetadata(__e:VideoLoaderEvent):void {
			checkSize();
		}

		private function onVideoLoaderFinishedPLaying(__e:VideoLoaderEvent):void {
			if (loop) {
				videoLoader.seek(0);
				videoLoader.resume();
			} else {
				_onFinishedPlaying.dispatch(this);
			}
		}

		private function onVideoLoaderNotifiedSeek(__e:VideoLoaderEvent):void {
			_onSeekComplete.dispatch(this);
		}

		private function onVideoLoaderComplete(__e:*):void {
			_isLoaded = true;
			_onLoaded.dispatch(this);
		}

		private function applyVisibility():void {
			wasVisible = visible;
			alpha = _visibility;
			visible = _visibility > 0;

			if (!wasVisible && visible) updateFrame();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function load():void {
			if (videoLoader == null) {
				videoLoader = new VideoLoader(netStreamToRecycle, netConnectionToRecycle);
				videoLoader.netStream.receiveAudio(false);
				videoLoader.addEventListener(VideoLoaderEvent.RECEIVED_METADATA, onVideoLoaderReceivedMetadata);
				videoLoader.addEventListener(VideoLoaderEvent.PLAY_FINISH, onVideoLoaderFinishedPLaying);
				videoLoader.addEventListener(VideoLoaderEvent.SEEK_NOTIFY, onVideoLoaderNotifiedSeek);
				videoLoader.addEventListener(Event.COMPLETE, onVideoLoaderComplete);
				videoLoader.load(new URLRequest(url));

				createBitmapData();
			}
		}

		public function seek(__timeSeconds:Number):void {
			if (videoLoader != null) {
				videoLoader.seek(__timeSeconds);
			}
		}

		public function resume():void {
			if (videoLoader != null) {
				videoLoader.resume();
			}
		}

		public function pause():void {
			if (videoLoader != null) {
				videoLoader.pause();
			}
		}

		public function stop():void {
			if (videoLoader != null) {
				videoLoader.pause();
				videoLoader.seek(0);
			}
		}

		public function setClipRect(__rect:Rectangle):void {
			clipRect = __rect;
			adjustDimensions();
		}

		override public function dispose():void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);

			_onFinishedPlaying.removeAll();
			_onFinishedPlaying = null;
			_onSeekComplete.removeAll();
			_onSeekComplete = null;
			_onLoaded.removeAll();
			_onLoaded = null;

			if (bitmapData != null) {
				bitmapDataPool.put(bitmapData);
				bitmapData = null;
			}

			if (textureVideo != null) {
				textureVideo.dispose();
				textureVideo = null;
			}

			if (videoLoader != null) {
				videoLoader.removeEventListener(VideoLoaderEvent.RECEIVED_METADATA, onVideoLoaderReceivedMetadata);
				videoLoader.removeEventListener(VideoLoaderEvent.PLAY_FINISH, onVideoLoaderFinishedPLaying);
				videoLoader.removeEventListener(VideoLoaderEvent.SEEK_NOTIFY, onVideoLoaderNotifiedSeek);
				videoLoader.removeEventListener(Event.COMPLETE, onVideoLoaderComplete);
				videoLoader.dispose(netStreamToRecycle != null || _doNotDisposeOfNetStream);
				videoLoader = null;
				netStreamToRecycle = null;
				netConnectionToRecycle = null;
			}

			super.dispose();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function set x(__value:Number):void {
			if (boundss.x != __value) {
				boundss.x = __value;
				adjustDimensions();
			}
		}

		override public function set y(__value:Number):void {
			if (boundss.y != __value) {
				boundss.y = __value;
				adjustDimensions();
			}
		}

		override public function set width(__value:Number):void {
			if (boundss.width != __value) {
				boundss.width = __value;
				adjustDimensions();
			}
		}

		override public function set height(__value:Number):void {
			if (boundss.height != __value) {
				boundss.height = __value;
				adjustDimensions();
			}
		}

		public function get onFinishedPlaying():SimpleSignal {
			return _onFinishedPlaying;
		}

		public function get onSeekComplete():SimpleSignal {
			return _onSeekComplete;
		}

		public function get onLoaded():SimpleSignal {
			return _onLoaded;
		}

		public function get duration():Number {
			return videoLoader == null ? 0 : videoLoader.duration;
		}

		public function get time():Number {
			return videoLoader == null ? 0 : videoLoader.time;
		}

		public function get visibility():Number {
			return _visibility;
		}
		public function set visibility(__value:Number):void {
			if (_visibility != __value) {
				_visibility = __value;
				applyVisibility();
			}
		}

		public function get isLoaded():Boolean {
			return _isLoaded;
		}

		public function get netStream():NetStream {
			return videoLoader == null ? null : videoLoader.netStream;
		}

		public function get netConnection():NetConnection {
			return videoLoader == null ? null : videoLoader.netConnection;
		}

		public function get doNotDisposeOfNetStream():Boolean {
			return _doNotDisposeOfNetStream;
		}

		public function set doNotDisposeOfNetStream(__value:Boolean):void {
			_doNotDisposeOfNetStream = __value;
		}
	}
}
