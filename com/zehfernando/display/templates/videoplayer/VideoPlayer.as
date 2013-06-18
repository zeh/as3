package com.zehfernando.display.templates.videoplayer {
	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.display.containers.VideoContainer;
	import com.zehfernando.display.templates.videoplayer.events.VideoPanelEvent;
	import com.zehfernando.display.templates.videoplayer.events.VideoPanelSeekEvent;
	import com.zehfernando.display.templates.videoplayer.events.VideoPanelVolumeEvent;
	import com.zehfernando.display.templates.videoplayer.events.VideoPlayerEvent;
	import com.zehfernando.geom.GeomUtils;
	import com.zehfernando.transitions.Equations;
	import com.zehfernando.transitions.ZTween;
	import com.zehfernando.utils.AppUtils;
	import com.zehfernando.utils.DelayedCalls;
	import com.zehfernando.utils.RenderUtils;

	import flash.display.DisplayObjectContainer;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class VideoPlayer extends ResizableSprite {

		// Constants
		protected static const TIME_SHOW_PANEL:Number = 0.6;
		protected static const TIME_HIDE_PANEL:Number = 0.6;
		protected static const TIME_WAIT_TO_HIDE_PANEL:Number = 4;

		// Properties
		protected var wasVideoPausedBeforeScrub:Boolean;

		protected var originalX:Number;					// X before going fullscreen
		protected var originalY:Number;					// Y before going fullscreen
		protected var originalWidth:Number;					// Size before going fullscreen
		protected var originalHeight:Number;
		protected var originalParent:DisplayObjectContainer;

		protected var _scaleMode:String;
		protected var isPanelShown:Boolean;

		// Instances
		protected var video:VideoContainer;
		protected var panel:VideoPanel;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoPlayer() {
			super();

			setDefaultProperties();
			createAssets();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function setDefaultProperties():void {
			_scaleMode = StageScaleMode.SHOW_ALL;
			isPanelShown = true;
		}

		protected function createAssets():void {
			video = new VideoContainer();
			video.backgroundColor = 0x000000;
			video.backgroundAlpha = 1;
			video.smoothing = true;
			video.pauseVideo();
			video.autoPlay = false;
			video.loop = false;
			video.addEventListener(VideoContainer.EVENT_PLAY_FINISH, onVideoPlayFinish);
			video.addEventListener(VideoContainer.EVENT_PLAY_START, onVideoPlayed);
			video.addEventListener(VideoContainer.EVENT_RESUME, onVideoPlayed);
			video.addEventListener(VideoContainer.EVENT_PAUSE, onVideoPaused);
			video.addEventListener(VideoContainer.EVENT_PLAY_STOP, onVideoPaused);
			video.addEventListener(VideoContainer.EVENT_LOADING_PROGRESS, onVideoLoadingProgress);
			video.addEventListener(VideoContainer.EVENT_LOADING_COMPLETE, onVideoLoadingComplete);
			video.addEventListener(VideoContainer.EVENT_RECEIVED_METADATA, onVideoReceivedMetadata);
			video.addEventListener(VideoContainer.EVENT_TIME_CHANGE, onVideoTimeChanged);
			video.addEventListener(VideoContainer.EVENT_VOLUME_CHANGE, onVideoVolumeChanged);
			video.addEventListener(VideoContainer.EVENT_SEEK_NOTIFY, onVideoSeekNotify);
			addChild(video);

			AppUtils.getStage().addEventListener(FullScreenEvent.FULL_SCREEN, onSwitchedFullScreen);
			AppUtils.getStage().addEventListener(MouseEvent.MOUSE_MOVE, onMouseAction);
			AppUtils.getStage().addEventListener(MouseEvent.MOUSE_DOWN, onMouseAction);
			AppUtils.getStage().addEventListener(MouseEvent.MOUSE_UP, onMouseAction);

			updateVideoScaleMode();

			var p:VideoPanel = new VideoPanel();
			setPanel(p);
		}

		override protected function redrawWidth():void {
			video.width = _width;

			if (Boolean(panel)) panel.width = _width;
		}

		override protected function redrawHeight():void {
			video.height = _height;

			if (Boolean(panel)) panel.height = _height;
		}

		protected function requestRedraw():void {
			RenderUtils.addFunction(redraw);
		}

		protected function redraw():void {
			redrawWidth();
			redrawHeight();
		}

		protected function setPanel(__panel:VideoPanel):void {
			removePanel();

			panel = __panel;
			panel.addEventListener(VideoPanelEvent.PAUSE, onVideoPanelPause);
			panel.addEventListener(VideoPanelEvent.PLAY, onVideoPanelPlay);
			panel.addEventListener(VideoPanelEvent.SCREEN_FULL, onVideoPanelScreenFull);
			panel.addEventListener(VideoPanelEvent.SCREEN_NORMAL, onVideoPanelScreenNormal);
			panel.addEventListener(VideoPanelEvent.SCRUB_START, onVideoPanelScrubStart);
			panel.addEventListener(VideoPanelSeekEvent.SEEK, onVideoPanelSeek);
			panel.addEventListener(VideoPanelEvent.SCRUB_END, onVideoPanelScrubEnd);
			panel.addEventListener(VideoPanelVolumeEvent.VOLUME_CHANGE, onVideoPanelVolumeChange);
			addChild(panel);

			updatePlayState();
			updateVideoLoad();
			updateVideoTime();
			updateVideoVolume();

			requestRedraw();

			panel.visibility = isPanelShown ? 1 : 0;

			waitToHidePanel();
		}

		protected function removePanel():void {
			if (Boolean(panel)) {
				panel.removeEventListener(VideoPanelEvent.PAUSE, onVideoPanelPause);
				panel.removeEventListener(VideoPanelEvent.PLAY, onVideoPanelPlay);
				panel.removeEventListener(VideoPanelEvent.SCREEN_FULL, onVideoPanelScreenFull);
				panel.removeEventListener(VideoPanelEvent.SCREEN_NORMAL, onVideoPanelScreenNormal);
				panel.removeEventListener(VideoPanelEvent.SCRUB_START, onVideoPanelScrubStart);
				panel.removeEventListener(VideoPanelSeekEvent.SEEK, onVideoPanelSeek);
				panel.removeEventListener(VideoPanelEvent.SCRUB_END, onVideoPanelScrubEnd);
				panel.removeEventListener(VideoPanelVolumeEvent.VOLUME_CHANGE, onVideoPanelVolumeChange);
				panel.dispose();
				removeChild(panel);
				panel = null;
			}
		}

		protected function updatePlayState():void {
			panel.setPlayState(video.isPlaying);
		}

		protected function updateVideoScaleMode():void {
			if (isFullScreen()) {
				video.scaleMode = StageScaleMode.SHOW_ALL;
			} else {
				video.scaleMode = _scaleMode;
			}
		}

		protected function updateVideoLoad():void {
			panel.setVideoLoadProgress(video.bytesLoaded / video.bytesTotal);
		}

		protected function updateVideoTime():void {
			panel.setVideoTime(video.time, video.duration);
		}

		protected function updateVideoVolume():void {
			panel.setVideoVolume(video.volume);
		}

		protected function isFullScreen():Boolean {
			return AppUtils.getStage().displayState == StageDisplayState.FULL_SCREEN;
		}

		protected function waitToHidePanel():void {
			cancelWaitToHidePanel();
			DelayedCalls.add(TIME_WAIT_TO_HIDE_PANEL * 1000, hidePanel);
		}

		protected function cancelWaitToHidePanel():void {
			DelayedCalls.remove(hidePanel);
		}

		protected function showPanel(__immediate:Boolean = false):void {
			if (Boolean(panel) && !isPanelShown) {
				cancelWaitToHidePanel();
				ZTween.remove(panel, "visibility");
				isPanelShown = true;

				if (__immediate) {
					panel.visibility = 1;
				} else {
					ZTween.add(panel, {visibility:1}, {time:TIME_SHOW_PANEL, transition:Equations.quintOut});
				}
			}
		}

		protected function hidePanel(__immediate:Boolean = false):void {
			if (Boolean(panel) && isPanelShown && panel.canHide) {
				ZTween.remove(panel, "visibility");
				isPanelShown = false;

				if (__immediate) {
					panel.visibility = 0;
				} else {
					ZTween.add(panel, {visibility:0}, {time:TIME_HIDE_PANEL, transition:Equations.quintOut});
				}
			}
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onVideoPanelPause(e:VideoPanelEvent):void {
			video.pauseVideo();
		}

		protected function onVideoPanelPlay(e:VideoPanelEvent):void {
			video.playVideo();
		}

		protected function onVideoPanelScreenFull(e:VideoPanelEvent):void {
			if (!isFullScreen()) {

				originalX = x;
				originalY = y;
				originalWidth = _width;
				originalHeight = _height;
				originalParent = parent;

				var sw:Number = AppUtils.getStage().fullScreenWidth;
				var sh:Number = AppUtils.getStage().fullScreenHeight;

				var ns:Number = GeomUtils.fitRectangle(new Rectangle(0, 0, sw, sh), new Rectangle(0, 0, originalWidth, originalHeight), false);
				width = Math.round(ns * sw);
				height = Math.round(ns * sh);
				redraw();

				var pp:Point = AppUtils.getStage().localToGlobal(new Point(0, 0));
				AppUtils.getStage().addChild(this);

				x = pp.x;
				y = pp.y;

				var p1:Point = video.parent.localToGlobal(new Point(video.x, video.y));
				var p2:Point = video.parent.localToGlobal(new Point(video.x+video.width, video.y+video.height));
				AppUtils.getStage().fullScreenSourceRect = new Rectangle(p1.x, p1.y, p2.x-p1.x, p2.y-p1.y);

				AppUtils.getStage().displayState = StageDisplayState.FULL_SCREEN;
			}
		}

		protected function onVideoPanelScreenNormal(e:VideoPanelEvent):void {
			if (isFullScreen()) {
				AppUtils.getStage().displayState = StageDisplayState.NORMAL;
			}
		}

		protected function onMouseAction(e:Event):void {
			if (Boolean(panel)) {
				if (!isPanelShown) showPanel();

				cancelWaitToHidePanel();

				if (panel.canHide) waitToHidePanel();
			}
		}

		protected function onSwitchedFullScreen(e:Event):void {
			if (isFullScreen()) {
				// Switched to full screen
				updateVideoScaleMode();

				dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.SCREEN_FULL));
			} else {
				// Switched to normal screen

				x = originalX;
				y = originalY;
				width = originalWidth;
				height = originalHeight;
				originalParent.addChild(this);

				updateVideoScaleMode();

				dispatchEvent(new VideoPlayerEvent(VideoPlayerEvent.SCREEN_NORMAL));
			}
		}

		protected function onVideoPanelScrubStart(e:VideoPanelEvent):void {
			wasVideoPausedBeforeScrub = video.isPlaying;
			video.pauseVideo();
		}

		protected function onVideoPanelSeek(e:VideoPanelSeekEvent):void {
			video.time = e.time;
		}

		protected function onVideoPanelScrubEnd(e:VideoPanelEvent):void {
			if (wasVideoPausedBeforeScrub) {
				video.playVideo();
			}
			onMouseAction(null);
		}

		protected function onVideoPanelVolumeChange(e:VideoPanelVolumeEvent):void {
			//video.volume =
			video.volume = e.volume;
		}

		protected function onVideoPlayFinish(e:Event):void {
			// TODO!
		}

		protected function onVideoPlayed(e:Event):void {
			updatePlayState();
		}

		protected function onVideoPaused(e:Event):void {
			updatePlayState();
		}

		protected function onVideoLoadingProgress(e:Event):void {
			updateVideoLoad();
		}

		protected function onVideoLoadingComplete(e:Event):void {
			updateVideoLoad();
		}

		protected function onVideoReceivedMetadata(e:Event):void {
			updateVideoLoad();
			updateVideoTime();
		}

		protected function onVideoTimeChanged(e:Event):void {
			updateVideoTime();
		}

		protected function onVideoVolumeChanged(e:Event):void {
			updateVideoVolume();
		}

		protected function onVideoSeekNotify(e:Event):void {
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function load(__url:String):void {
			video.load(__url);
		}

		public function play():void {
			video.playVideo();
		}

		public function pause():void {
			video.pauseVideo();
		}

		public function dispose():void {
			removePanel();

			cancelWaitToHidePanel();

			AppUtils.getStage().removeEventListener(FullScreenEvent.FULL_SCREEN, onSwitchedFullScreen);
			AppUtils.getStage().removeEventListener(MouseEvent.MOUSE_MOVE, onMouseAction);
			AppUtils.getStage().removeEventListener(MouseEvent.MOUSE_UP, onMouseAction);
			AppUtils.getStage().removeEventListener(MouseEvent.MOUSE_DOWN, onMouseAction);

			video.removeEventListener(VideoContainer.EVENT_PLAY_FINISH, onVideoPlayFinish);
			video.removeEventListener(VideoContainer.EVENT_PLAY_START, onVideoPlayed);
			video.removeEventListener(VideoContainer.EVENT_RESUME, onVideoPlayed);
			video.removeEventListener(VideoContainer.EVENT_PAUSE, onVideoPaused);
			video.removeEventListener(VideoContainer.EVENT_PLAY_STOP, onVideoPaused);
			video.removeEventListener(VideoContainer.EVENT_LOADING_PROGRESS, onVideoLoadingProgress);
			video.removeEventListener(VideoContainer.EVENT_LOADING_COMPLETE, onVideoLoadingComplete);
			video.removeEventListener(VideoContainer.EVENT_RECEIVED_METADATA, onVideoReceivedMetadata);
			video.removeEventListener(VideoContainer.EVENT_TIME_CHANGE, onVideoTimeChanged);
			video.removeEventListener(VideoContainer.EVENT_VOLUME_CHANGE, onVideoVolumeChanged);
			video.removeEventListener(VideoContainer.EVENT_SEEK_NOTIFY, onVideoSeekNotify);
			video.dispose();
			removeChild(video);
			video = null;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get scaleMode():String {
			return _scaleMode;
		}
		public function set scaleMode(__value:String):void {
			_scaleMode = __value;
			updateVideoScaleMode();
		}


	}
}
