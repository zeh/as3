package com.zehfernando.net.apis {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	/**
	 * @author zeh
	 */
	public class DataLoader extends EventDispatcher {
		
		// Stores data but optionally loads it from a source
		
		// Properties
		protected var _isDataLoading:Boolean;
		protected var _isDataLoaded:Boolean;
		protected var _urlLoader:URLLoader;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function DataLoader() {
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function loadData(__request:URLRequest): void {
			createURLLoader();
			_urlLoader.load(__request);
		}

		protected function createURLLoader(): void {
			_urlLoader = new URLLoader();
			_urlLoader.addEventListener(Event.OPEN, onLoadOpen, false, 0, true);
			_urlLoader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError, false, 0, true);
			_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
			_urlLoader.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
		}
		
		protected function removeURLLoader(): void {
			if (Boolean(_urlLoader)) {
				_urlLoader.removeEventListener(Event.OPEN, onLoadOpen);
				_urlLoader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
				_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
				_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_urlLoader.removeEventListener(Event.COMPLETE, onLoadComplete);
				_urlLoader = null;
			}
		}

		// Overwrite:

		protected function parseLoadedData(__data:*): void {
			// Parses the loaded data
		}

		public function stopLoading(): void {
			if (_isDataLoading) {
				_urlLoader.close();
				_isDataLoading = false;
				removeURLLoader();
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onLoadOpen(e:Event): void {
			dispatchEvent(new Event(Event.OPEN));
		}

		protected function onLoadProgress(e:ProgressEvent): void {
			dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, e.bubbles, e.cancelable, e.bytesLoaded, e.bytesTotal));
		}

		protected function onLoadIOError(e:IOErrorEvent): void {
			trace ("DataLoader :: I/O Error!!!!");
			_isDataLoading = false;
			_isDataLoaded = false;
			removeURLLoader();
		}

		protected function onSecurityError(e:SecurityErrorEvent): void {
			trace ("DataLoader :: Security Error!!!!");
			_isDataLoading = false;
			_isDataLoaded = false;
			removeURLLoader();
		}

		protected function onLoadComplete(e:Event): void {
			parseLoadedData(_urlLoader.data);
			dispatchEvent(new Event(Event.COMPLETE));
			_isDataLoading = false;
			_isDataLoaded = true;
			removeURLLoader();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get isDataLoading(): Boolean {
			return _isDataLoading;
		}
		public function set isDataLoading(__value:Boolean): void {
			if (_isDataLoading != __value) {
				_isDataLoading = __value;
			}
		}
	}
}
