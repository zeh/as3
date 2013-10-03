package com.zehfernando.display.containers {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ImageDecodingPolicy;
	import flash.system.LoaderContext;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class ImageContainer extends DynamicDisplayAssetContainer {

		// Constants
		// Exception fault: SecurityError: Error #2123: Security sandbox violation: BitmapData.draw: http://fakehost.com/5GUM_COACHELLA2912/deploy/site/index.swf cannot access http://static.ak.fbcdn.net/rsrc.php/v1/yL/r/HsTZSDw4avx.gif?type=large. No policy files granted access.
		public static const EVENT_SECURITY_SANDBOX_VIOLATION:String = "onSecuritySandboxViolation";

		// Properties
		protected var _isConnectionOpened:Boolean;

		// Instances
		protected var loader:Loader;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ImageContainer(__width:Number = 100, __height:Number = 100, __backgroundColor:Number = 0x000000) {
			super(__width, __height, __backgroundColor);
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		override public function dispose():void {
			if (_isLoading) {
				if (_isConnectionOpened && !(_bytesLoaded > 0 && _bytesLoaded == _bytesTotal)) loader.close();
				//loader.close();
			} else if (_isLoaded) {
				loader.unload();
			}

			if (Boolean(loader)) {
				removeLoaderEvents();
				contentHolder.removeChild(loader);
				loader = null;
			}

			super.dispose();
		}

		protected function removeLoaderEvents():void {
			loader.contentLoaderInfo.removeEventListener(Event.OPEN, onLoadOpen);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}

		override protected function applySmoothing():void {
			if (_isLoaded) {
				try {
					if (Boolean(loader.content)) {
						Bitmap(loader.content).smoothing = _smoothing;
						//Bitmap(loader.content).pixelSnapping = PixelSnapping.ALWAYS;
						// Connection to http://static.ak.fbcdn.net/rsrc.php/v1/yL/r/HsTZSDw4avx.gif?type=large halted - not permitted from http://fakehost.com/5GUM_COACHELLA2912/deploy/site/index.swf
					}
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
			_isConnectionOpened = true;
		}

		protected function onLoadComplete(e:Event = null):void {
			_isLoading = false;
			_isConnectionOpened = false;
			_isLoaded = true;
			try {
				_contentWidth = loader.content.width;
				_contentHeight = loader.content.height;
			} catch (e:Error) {
				// Error here - meaning it's probably trying to load content not allowed
				_contentWidth = 100;
				_contentHeight = 100;
				updateCompletedLoadingStats();
				removeLoaderEvents();
				trace ("Error when trying to access loader.content width/height!");
				dispatchEvent(new Event(EVENT_SECURITY_SANDBOX_VIOLATION));
				return;
			}
			updateCompletedLoadingStats();
			removeLoaderEvents();
			redraw();
			dispatchEvent(e);
		}

		protected function onLoadProgress(e:ProgressEvent = null):void {
			//trace ("ImageContainer :: onLoadProgress :: " + e);
			dispatchEvent(e);
			if (!isNaN(_timeStartedLoading)) updateStartedLoadingStats();
			_bytesLoaded = e.bytesLoaded;
			_bytesTotal = e.bytesTotal;
		}

		protected function onLoadError(e:IOErrorEvent = null):void {
			trace ("ERROR :: ImageContainer :: onLoadError :: " + e);
			_isLoading = false;
			_isConnectionOpened = false;
			_isLoaded = false;
			_timeStartedLoading = NaN;
			removeLoaderEvents();
			dispatchEvent(e);
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getFrame(): BitmapData {
			// Captures the current image as a BitmapData
			var bmp:BitmapData = new BitmapData(_contentWidth, _contentHeight, false, 0x000000);

			//var mtx:Matrix = new Matrix();
			//mtx.scale(_contentWidth/100, _contentHeight/100);
			bmp.draw(loader);
			return bmp;
		}

		override public function load(__url:String):void {
			if (!Boolean(__url)) {
				trace ("ImageContainer :: ERROR: tried loading image from null url ["+__url+"]");
				return;
			}

			super.load(__url);

			_isLoading = true;
			_isConnectionOpened = false;
			_isLoaded = false;

			loader = new Loader();
			setAsset(loader);

			loader.contentLoaderInfo.addEventListener(Event.OPEN, onLoadOpen);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);

			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;

			loader.load(new URLRequest(_contentURL), context);
		}
	}
}
