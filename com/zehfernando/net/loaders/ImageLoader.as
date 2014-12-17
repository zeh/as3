package com.zehfernando.net.loaders {

	import flash.system.ImageDecodingPolicy;
	import com.zehfernando.utils.console.error;

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
	public class ImageLoader extends Sprite {

		// A SAFER image loader - avoids crossdomain redirection problems
		// http://www.arpitonline.com/blog/2008/06/17/debugging-crossdomain-issues-following-http-302s/

		/* Dispatches:

		IOErrorEvent.IO_ERROR

		Event.OPEN
		ProgressEvent.PROGRESS
		Event.COMPLETE

		*/

		// Properties
		protected var _isLoading:Boolean;
		protected var _isLoaded:Boolean;
		protected var _isConnectionOpened:Boolean;

		// Instances
		protected var loader:Loader;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ImageLoader() {
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onLoadOpen(e:Event):void {
			dispatchEvent (new Event(Event.OPEN));
		}

		protected function onLoadComplete(e:Event):void {
			dispatchEvent (new Event(Event.COMPLETE));

			var w:Number;
			try {
				w = loader.content.width;
			} catch (e:Error) {
				error("Cannot read width for image at " + loader.contentLoaderInfo.loaderURL);
			}
		}

		protected function onLoadProgress(e:ProgressEvent):void {
			dispatchEvent (new ProgressEvent(ProgressEvent.PROGRESS, e.bubbles, e.cancelable, e.bytesLoaded, e.bytesTotal));
		}

		protected function onLoadError(e:IOErrorEvent):void {
			dispatchEvent (new IOErrorEvent(IOErrorEvent.IO_ERROR));
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function load(__request:URLRequest, __context:LoaderContext = null):void {
			_isLoading = true;
			_isConnectionOpened = false;
			_isLoaded = false;

			loader = new Loader();
			addChild(loader);

			loader.contentLoaderInfo.addEventListener(Event.OPEN, onLoadOpen, false, 0, true);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false, 0, true);

			if (!Boolean(__context)) {
				__context = new LoaderContext();
				__context.checkPolicyFile = true;
				__context.imageDecodingPolicy = ImageDecodingPolicy.ON_LOAD;
			}

			loader.load(__request, __context);
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get bytesTotal():uint {
			return Boolean(loader) ? loader.contentLoaderInfo.bytesTotal : 0;
		}

		public function get bytesLoaded():uint {
			return Boolean(loader) ? loader.contentLoaderInfo.bytesLoaded : 0;
		}
	}
}
