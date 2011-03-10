package com.zehfernando.net.assets {

	import com.zehfernando.net.LoadingQueue;
	import com.zehfernando.net.loaders.VideoLoader;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;

	/**
	 * @author Zeh
	 */
	public class AssetLibrary extends EventDispatcher {

		// Static properties
		protected static var libraries:Vector.<AssetLibrary>;
		
		// Properties
		protected var _name:String;
		protected var _maxRetries:Number;
		
		protected var assets:Vector.<AssetItemInfo>;
		protected var queue:LoadingQueue;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AssetLibrary(__name:String = "", __dynamicLoadingSpots:Number = 2) {
			super(null);
			
			_name = __name;
			_maxRetries = 2;
			
			queue = new LoadingQueue();
			queue.addEventListener(ProgressEvent.PROGRESS, onQueueProgress, false, 0, true);
			queue.addEventListener(Event.COMPLETE, onQueueComplete, false, 0, true);
			//queue.addEventListener(LoadingQueueEvent.COMPLETE_ITEM, onQueueItemComplete, false, 0, true);
			queue.slots = __dynamicLoadingSpots;

			assets = new Vector.<AssetItemInfo>();

			AssetLibrary.addLibrary(this);
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------
		
		protected static function addLibrary(__library:AssetLibrary): void {
			
			if (!Boolean(libraries)) {
				libraries = new Vector.<AssetLibrary>();
			}
			
			if (libraries.indexOf(__library) == -1) {
				libraries.push(__library);
			}
		}

		protected static function removeLibrary(__library:AssetLibrary): void {
			
			if (!Boolean(libraries)) {
				libraries = new Vector.<AssetLibrary>();
			}
			
			if (libraries.indexOf(__library) != -1) {
				libraries.splice(libraries.indexOf(__library), 1);
			}
		}
		
		public static function getLibrary(__name:String = ""): AssetLibrary {
			// Use object list instead?
			var i:int;
			for (i = 0; i < libraries.length; i++) {
				if (libraries[i].name == __name) return libraries[i];
			}
			return null;
		}


		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------



		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected function onQueueProgress(e:ProgressEvent): void {
			var ne:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, e.bytesLoaded, e.bytesTotal);
			dispatchEvent(ne);
		}

		protected function onQueueComplete(e:Event): void {
			//trace ("QUEUE COMPLETE: "+e.target +", " + e.currentTarget);
			var ne:Event = new Event(Event.COMPLETE);
			dispatchEvent(ne);
		}

		/*
		protected function onQueueItemComplete(e:LoadingQueueEvent): void {
			//trace ("ITEM COMPLETE: "+e.target +", " + e.currentTarget);
			var ai:AssetItemInfo = getAssetItemInfoByObject(e.target);
			ai.isLoaded = true;
			ai.isLoading = false;
		}
		*/

		protected function onURLLoaderComplete(e:Event): void {
			//trace ("ITEM COMPLETE: "+e.target +", " + e.currentTarget);
			var ai:AssetItemInfo = getAssetItemInfoByObject(e.target);
			if (Boolean(ai)) {
				ai.isLoaded = true;
				ai.isLoading = false;
			}
		}

		protected function onLoaderComplete(e:Event): void {
			//trace ("ITEM COMPLETE: "+e.target +", " + e.currentTarget);
			var ai:AssetItemInfo = getAssetItemInfoByContentLoaderInfo(e.target as LoaderInfo);
			if (Boolean(ai)) {
				ai.isLoaded = true;
				ai.isLoading = false;
			}
		}

		protected function onVideoLoaderComplete(e:Event): void {
			//trace ("ITEM COMPLETE: "+e.target +", " + e.currentTarget);
			var ai:AssetItemInfo = getAssetItemInfoByObject(e.target);
			if (Boolean(ai)) {
				ai.isLoaded = true;
				ai.isLoading = false;
			}
		}

		
		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function addDynamicAsset(__url:String, __name:String = "", __type:String = ""): void {
			if (!Boolean(__type)) __type = AssetType.getFromURL(__url);
			var ai:AssetItemInfo = new AssetItemInfo(__name, __type);
			ai.url = __url;

			assets.push(ai);
		}
		
		public function getAssetItemInfoByName(__name:String): AssetItemInfo {
			// Use object list instead?
			if (!Boolean(assets)) return null;
			var i:int;
			for (i = 0; i < assets.length; i++) {
				if (assets[i].name == __name) return assets[i];
			}
			return null;
		}

		public function getAssetItemInfoByURL(__url:String): AssetItemInfo {
			// Use object list instead?
			if (!Boolean(assets)) return null;
			var i:int;
			for (i = 0; i < assets.length; i++) {
				if (assets[i].url == __url) return assets[i];
			}
			return null;
		}

		public function getAssetItemInfoByObject(__object:Object): AssetItemInfo {
			// Use object list instead?
			if (!Boolean(assets)) return null;
			var i:int;
			for (i = 0; i < assets.length; i++) {
				if (assets[i].loadingObject == __object) return assets[i];
			}
			return null;
		}

		public function getAssetItemInfoByContentLoaderInfo(__contentLoaderInfo:LoaderInfo): AssetItemInfo {
			// Use object list instead?
			// Sometimes this can get fired by an asset library that has already been disposed and removed, so test first to see if the asset list exists
			if (Boolean(assets)) {
				var i:int;
				for (i = 0; i < assets.length; i++) {
					if (assets[i].loadingObject is Loader && (assets[i].loadingObject as Loader).contentLoaderInfo == __contentLoaderInfo) return assets[i];
				}
			}
			return null;
		}
		
		public function startLoadings(): void {
			// Start all loads that didn't start yet
			
			//trace("AssetLibrary.startLoadings()");
			
			var i:int;
			for (i = 0; i < assets.length; i++) {
				if (!assets[i].isLoading && !assets[i].isLoaded) {
					switch (assets[i].type) {
						case AssetType.XML:
						case AssetType.CSS:
							// Text, use an URLLoader
							assets[i].loadingObject = new URLLoader();
							(assets[i].loadingObject as URLLoader).addEventListener(Event.COMPLETE, onURLLoaderComplete, false, 0, true);
							queue.addURLLoader(assets[i].loadingObject, new URLRequest(assets[i].url));
							break;
						case AssetType.SWF:
						case AssetType.IMAGE:
							assets[i].loadingObject = new Loader();
							(assets[i].loadingObject as Loader).contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete, false, 0, true);
							queue.addLoader(assets[i].loadingObject, new URLRequest(assets[i].url));
							break;
						case AssetType.VIDEO:
							assets[i].loadingObject = new VideoLoader();
							(assets[i].loadingObject as VideoLoader).addEventListener(Event.COMPLETE, onVideoLoaderComplete, false, 0, true);
							queue.addVideoLoader(assets[i].loadingObject, new URLRequest(assets[i].url));
							break;
						default:
							throw new Error ("AssetLibrary :: startLoads :: can't start loading of asset [" + assets[i].url + "] type '" + assets[i].type + "'!");
					}
					assets[i].isLoading = true;
				}
			}
			
			if (queue.paused) queue.resume();
		}

		// Type-specific content functions
		public function getAssetByName(__name:String): Object {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsset();
			return null;
		}

		public function getAssetByURL(__url:String): Object {
			var ai:AssetItemInfo = getAssetItemInfoByURL(__url);
			if (Boolean(ai)) return ai.getAsset();
			return null;
		}

		public function getXML(__name:String): XML {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsXML();
			return null;
		}

		public function getDisplayObject(__name:String): DisplayObject {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsDisplayObject();
			return null;
		}

		public function getVideoLoader(__name:String): VideoLoader {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsVideoLoader();
			return null;
		}

		public function getStyleSheet(__name:String): StyleSheet {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsStyleSheet();
			return null; 
		}

		public function dispose(): void {
			removeLibrary(this);

			for (var i:int = 0; i < assets.length; i++) {
				assets[i].dispose();
			}
			assets = null;
			queue.dispose();
			queue = null;
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get name(): String {
			return _name;
		}
	}
}

import com.zehfernando.net.assets.AssetType;
import com.zehfernando.net.loaders.VideoLoader;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.net.URLLoader;
import flash.text.StyleSheet;

// TODO: add AssetData class
// TODO: add DynamicAssetData class

class AssetItemInfo {

	// Properties
	public var name:String;
	public var type:String;							// Type, from AssetType
	
	public var loadingObject:*;						// Object that gets the data when loaded
	
	public var isLoading:Boolean;						// Whether it's already loading or not
	public var isLoaded:Boolean;						// Whether it's already loaded or not
	public var url:String;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AssetItemInfo(__name:String, __type:String) {
		name = __name;
		type = __type;
		isLoading = false;
		isLoaded = false;
		url = "";
		loadingObject = null;
	}
	
	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function getAsset(): Object {
		if (isLoaded) {
			switch (type) {
				case AssetType.XML:
					return getAsXML();
				case AssetType.CSS:
					return getAsStyleSheet();
				case AssetType.SWF:
				case AssetType.IMAGE:
					return getAsDisplayObject();
				case AssetType.VIDEO:
					return getAsVideoLoader();
			}
		}
		return null;
	}

	public function getAsXML(): XML {
		if (isLoaded) return new XML((loadingObject as URLLoader).data);
		return null;
	}

	public function getAsStyleSheet(): StyleSheet {
		if (isLoaded) {
			var ss:StyleSheet = new StyleSheet();
			ss.parseCSS((loadingObject as URLLoader).data);
			return ss;
		}
		return null;
	}
	
	public function getAsDisplayObject(): DisplayObject {
		if (isLoaded) return (loadingObject as Loader).content;
		return null;
	}
	
	public function getAsVideoLoader(): VideoLoader {
		if (isLoaded) return loadingObject as VideoLoader;
		return null;
	}
	
	public function dispose(): void {
		switch (type) {
			case AssetType.XML:
			case AssetType.CSS:
				break;
			case AssetType.SWF:
			case AssetType.IMAGE:
				(loadingObject as Loader).unloadAndStop();
				break;
			case AssetType.VIDEO:
				if (isLoaded) getAsVideoLoader().dispose();
				break;
		}
		loadingObject = null;
	}
	
	/*
	public function get data(): * {
		if (loadingObject is URLLoader) {
			return (loadingObject as URLLoader).data;
		}
		
		trace ("AssetLibrary :: get data() :: Attempt to read data of unknown type!");
		return null;
	}
	*/
}
