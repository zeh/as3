package com.zehfernando.display.containers {
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class ImageContainer extends DynamicDisplayAssetContainer {
		
		// Properties
		protected var _isConnectionOpened:Boolean;

		// Instances
		protected var loader:Loader;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ImageContainer(__width:Number = 100, __height:Number = 100, __color:Number = 0x000000) {
			super (__width, __height, __color);
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		override public function dispose(): void {
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
		
		protected function removeLoaderEvents(): void {
			loader.contentLoaderInfo.removeEventListener(Event.OPEN, onLoadOpen);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		}		

		override protected function applySmoothing(): void {
			if (_isLoaded && Boolean(loader.content)) Bitmap(loader.content).smoothing = _smoothing;
		}


		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected function onLoadOpen(e:Event = null): void {
			_isConnectionOpened = true;
		}

		protected function onLoadComplete(e:Event = null): void {
			_isLoading = false;
			_isConnectionOpened = false;
			_isLoaded = true;
			_contentWidth = loader.content.width;
			_contentHeight = loader.content.height;
			updateCompletedLoadingStats();
			removeLoaderEvents();
			redraw();
			dispatchEvent(e);
		}

		protected function onLoadProgress(e:ProgressEvent = null): void {
			//trace ("ImageContainer :: onLoadProgress :: " + e);
			dispatchEvent(e);
			if (!isNaN(_timeStartedLoading)) updateStartedLoadingStats();
			_bytesLoaded = e.bytesLoaded;
			_bytesTotal = e.bytesTotal;
		}

		protected function onLoadError(e:IOErrorEvent = null): void {
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

		override public function load(__url:String): void {
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
			
			loader.load(new URLRequest(_contentURL), context);
		}
	}
}
