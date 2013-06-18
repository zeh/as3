package com.zehfernando.display.templates.videoplayer {

	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.display.shapes.Box;
	import com.zehfernando.utils.AppUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FullScreenEvent;

	/**
	 * @author zeh at zehfernando.com
	 */
	public class VideoPanel extends ResizableSprite {

		// Properties
		protected var _contentHeight:Number;
		protected var _visibility:Number;
		protected var _canHide:Boolean;

		// Instances
		protected var contentMask:Box;
		protected var contentContainer:Sprite;

		protected var _videoPlayer:VideoPlayer;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VideoPanel() {
			super();

			setDefaultProperties();
			createAssets();

			redrawContentHeight();
			redrawVisibility();
			redrawFullScreenButtons();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function setDefaultProperties():void {
			_contentHeight = 50;
			_visibility = 1;
			_canHide = true;
		}

		protected function createAssets():void {
			contentContainer = new Sprite();
			addChild(contentContainer);

			contentMask = new Box();
			addChild(contentMask);

			contentContainer.mask = contentMask;

			AppUtils.getStage().addEventListener(FullScreenEvent.FULL_SCREEN, onSwitchedFullScreen);
		}

		override protected function redrawWidth():void {
			contentMask.width = _width;
			redrawContentWidth();
		}

		override protected function redrawHeight():void {
			redrawVisibility();
		}

		protected function redrawContentWidth():void {
		}

		protected function redrawContentHeight():void {
			redrawVisibility();
		}

		protected function redrawFullScreenButtons():void {
			// Called when full screen state is changed and buttons must be redrawn
		}

		protected function redrawVisibility():void {
			var h:Number = Math.round(_contentHeight * _visibility);
			if (Boolean(contentMask)) {
				contentMask.y = _height - h;
				contentMask.height = h;
			}

			if (Boolean(contentContainer)) {
				contentContainer.y = _height - h;
				contentContainer.visible = _visibility > 0;
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onSwitchedFullScreen(e:Event):void {
			redrawFullScreenButtons();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setPlayState(__isPlaying:Boolean):void {
			// Informs whether the video is playing or not
		}

		public function setVideoTime(__time:Number, __duration:Number):void {
			// Informs the current video time and duration
		}

		public function setVideoLoadProgress(__f:Number):void {
			// Informs the current load progress on the video
		}

		public function setVideoVolume(__volume:Number):void {
			// Informs the current volume of the video
		}

		public function dispose() :void {
			AppUtils.getStage().removeEventListener(FullScreenEvent.FULL_SCREEN, onSwitchedFullScreen);

			contentContainer.mask = null;
			removeChild(contentContainer);
			contentContainer = null;

			removeChild(contentMask);
			contentMask = null;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get contentHeight():Number {
			return _contentHeight;
		}
		public function set contentHeight(__value:Number):void {
			if (_contentHeight != __value) {
				_contentHeight = __value;
				redrawContentHeight();
			}
		}

		public function get visibility():Number {
			return _visibility;
		}
		public function set visibility(__value:Number):void {
			if (_visibility != __value) {
				_visibility = __value;
				redrawVisibility();
			}
		}

		public function get canHide():Boolean {
			return _canHide;
		}
	}
}
