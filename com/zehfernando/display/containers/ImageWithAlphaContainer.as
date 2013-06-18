package com.zehfernando.display.containers {
	import flash.display.Bitmap;
	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class ImageWithAlphaContainer extends DynamicDisplayAssetContainer {

		// Constants
		// Exception fault: SecurityError: Error #2123: Security sandbox violation: BitmapData.draw: http://fakehost.com/5GUM_COACHELLA2912/deploy/site/index.swf cannot access http://static.ak.fbcdn.net/rsrc.php/v1/yL/r/HsTZSDw4avx.gif?type=large. No policy files granted access.
		public static const EVENT_SECURITY_SANDBOX_VIOLATION:String = "onSecuritySandboxViolation";

		// Properties
		protected var _isConnectionOpened:Boolean;
		protected var _isConnectionOpenedAlpha:Boolean;

		// Instances
		protected var loader:Loader;
		protected var loaderAlpha:Loader;

		protected var loaderContainer:Sprite;

		protected var _isLoadedImage:Boolean;
		protected var _isLoadedAlpha:Boolean;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ImageWithAlphaContainer(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000) {
			super (__width, __height, __color);
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		override public function dispose():void {
			if (_isLoading) {
				if (_isConnectionOpened && !(_bytesLoaded > 0 && _bytesLoaded == _bytesTotal)) loader.close();
				if (_isConnectionOpenedAlpha && !(_bytesLoaded > 0 && _bytesLoaded == _bytesTotal)) loader.close();
				//loader.close();
			}
			if (_isLoadedImage)	loader.unload();
			if (_isLoadedAlpha)	loaderAlpha.unload();

			if (Boolean(loader)) {
				removeLoaderEvents(loader);
				loaderContainer.removeChild(loader);
				loader = null;
			}

			if (Boolean(loaderAlpha)) {
				removeLoaderEvents(loaderAlpha);
				loaderContainer.removeChild(loaderAlpha);
				loaderAlpha = null;
			}

			if (Boolean(loaderContainer)) {
				contentHolder.removeChild(loaderContainer);
				loaderContainer = null;
			}

			super.dispose();
		}

		protected function removeLoaderEvents(__loader:Loader):void {
			__loader.contentLoaderInfo.removeEventListener(Event.OPEN, onLoadOpen);
			__loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			__loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			__loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}

		override protected function applySmoothing():void {
			if (_isLoaded) {
				try {
					if (Boolean(loader.content)) Bitmap(loader.content).smoothing = _smoothing;
					if (Boolean(loaderAlpha.content)) Bitmap(loaderAlpha.content).smoothing = _smoothing;
				} catch (e:Error) {
					// Error here - meaning it's probably trying to load content not allowed
					dispatchEvent(new Event(EVENT_SECURITY_SANDBOX_VIOLATION));
					trace ("Error when trying to access loader.content smoothing!");
				}
			}
		}


		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected function onLoadOpen(e:Event = null):void {
			if (e.currentTarget == loader.contentLoaderInfo) {
				_isConnectionOpened = true;
			} else {
				_isConnectionOpenedAlpha = true;
			}
		}

		protected function onLoadComplete(e:Event = null):void {

			if (e.currentTarget == loader.contentLoaderInfo) {
				_isLoadedImage = true;
				_isConnectionOpened = false;
			} else {
				_isLoadedAlpha = true;
				_isConnectionOpenedAlpha = false;
			}

			if (_isLoadedImage && _isLoadedAlpha) {
				_isLoading = false;
				_isLoaded = true;
				try {
					_contentWidth = loader.content.width;
					_contentHeight = loader.content.height;
				} catch (e:Error) {
					// Error here - meaning it's probably trying to load content not allowed
					_contentWidth = 100;
					_contentHeight = 100;
					updateCompletedLoadingStats();
					removeLoaderEvents(loader);
					removeLoaderEvents(loaderAlpha);
					trace ("Error when trying to access loader.content width/height!");
					dispatchEvent(new Event(EVENT_SECURITY_SANDBOX_VIOLATION));
					return;
				}
				updateCompletedLoadingStats();
				removeLoaderEvents(loader);
				removeLoaderEvents(loaderAlpha);
				redraw();
				dispatchEvent(e);
			}
		}

		protected function onLoadProgress(e:ProgressEvent = null):void {
			//trace ("ImageContainer :: onLoadProgress :: " + e);
			dispatchEvent(e);
			if (!isNaN(_timeStartedLoading)) updateStartedLoadingStats();
			_bytesLoaded = loader.contentLoaderInfo.bytesLoaded + loaderAlpha.contentLoaderInfo.bytesLoaded;
			_bytesTotal = (loader.contentLoaderInfo.bytesTotal > 0 ? loader.contentLoaderInfo.bytesTotal : 50000) + (loaderAlpha.contentLoaderInfo.bytesTotal > 0 ? loaderAlpha.contentLoaderInfo.bytesTotal : 50000);
		}

		protected function onLoadError(e:IOErrorEvent = null):void {
			trace ("ERROR :: ImageContainer :: onLoadError :: " + e);
			_isLoading = false;

			if (e.currentTarget == loader.contentLoaderInfo) {
				_isConnectionOpened = false;
				if (_isLoadedAlpha)	loaderAlpha.unload();
			} else {
				_isConnectionOpenedAlpha = false;
				if (_isLoadedImage)	loader.unload();
			}

			_timeStartedLoading = NaN;
			_isLoaded = false;
			removeLoaderEvents(loader);
			removeLoaderEvents(loaderAlpha);
			dispatchEvent(e);
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function loadWithAlpha(__imageURL:String, __alphaURL:String):void {
			if (!Boolean(__imageURL) || !Boolean(__alphaURL)) {
				trace ("ImageContainer :: ERROR: tried loading image from null url ["+__imageURL+"] with alpha ["+__alphaURL+"]");
				return;
			}

			super.load(__imageURL);

			_isLoading = true;
			_isConnectionOpened = false;
			_isConnectionOpenedAlpha = false;
			_isLoaded = false;
			_isLoadedImage = false;
			_isLoadedAlpha = false;

			loaderContainer = new Sprite();
			loaderContainer.blendMode = BlendMode.LAYER;
			setAsset(loaderContainer);

			loader = new Loader();

			loader.contentLoaderInfo.addEventListener(Event.OPEN, onLoadOpen);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);

			loaderContainer.addChild(loader);

			loaderAlpha = new Loader();

			loaderAlpha.contentLoaderInfo.addEventListener(Event.OPEN, onLoadOpen);
			loaderAlpha.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loaderAlpha.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loaderAlpha.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			loaderAlpha.blendMode = BlendMode.ALPHA;

			loaderContainer.addChild(loaderAlpha);

			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;

			loader.load(new URLRequest(__imageURL), context);
			loaderAlpha.load(new URLRequest(__alphaURL), context);
		}

		override public function unload():void {
			super.unload();

			loaderContainer = null;
		}
	}
}
