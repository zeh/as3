package com.zehfernando.net.assets {
	import com.zehfernando.net.LoadingQueue;
	import com.zehfernando.net.loaders.VideoLoader;
	import com.zehfernando.utils.console.info;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.StyleSheet;
	import flash.utils.ByteArray;

	/**
	 * @author Zeh
	 */
	public class AssetLibrary extends EventDispatcher {

		// Static properties
		protected static var libraries:Vector.<AssetLibrary> = new Vector.<AssetLibrary>();

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

		protected static function addLibrary(__library:AssetLibrary):void {
			if (libraries.indexOf(__library) == -1) {
				libraries.push(__library);
			}
		}

		protected static function removeLibrary(__library:AssetLibrary):void {
			if (libraries.indexOf(__library) != -1) {
				libraries.splice(libraries.indexOf(__library), 1);
			}
		}

		public static function getLibrary(__name:String = ""):AssetLibrary {
			var i:int;
			for (i = 0; i < libraries.length; i++) {
				if (libraries[i].name == __name) return libraries[i];
			}
			return null;
		}


		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected function getRandomURLSuffix(__singleParameter:Boolean):String {
			return (__singleParameter ? "?" : "&") + "r="+Math.floor(Math.random() * 9999999);
		}

		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected function onQueueProgress(e:ProgressEvent):void {
			var ne:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS, false, false, e.bytesLoaded, e.bytesTotal);
			dispatchEvent(ne);
		}

		protected function onQueueComplete(e:Event):void {
			//trace ("QUEUE COMPLETE: "+e.target +", " + e.currentTarget);
			var ne:Event = new Event(Event.COMPLETE);
			dispatchEvent(ne);
		}

		/*
		protected function onQueueItemComplete(e:LoadingQueueEvent):void {
			//trace ("ITEM COMPLETE: "+e.target +", " + e.currentTarget);
			var ai:AssetItemInfo = getAssetItemInfoByObject(e.target);
			ai.isLoaded = true;
			ai.isLoading = false;
		}
		*/

		protected function onURLLoaderProgress(e:ProgressEvent):void {
			var ai:AssetItemInfo = getAssetItemInfoByObject(e.target);
			if (Boolean(ai)) {
				ai.bytesLoaded = e.bytesLoaded;
				ai.bytesTotal = e.bytesTotal;
				ai.loadingPhase = e.bytesLoaded / e.bytesTotal;
			}
		}

		protected function onURLLoaderComplete(e:Event):void {
			//trace ("ITEM COMPLETE: "+e.target +", " + e.currentTarget);
			var ai:AssetItemInfo = getAssetItemInfoByObject(e.target);
			if (Boolean(ai)) {
				ai.isLoaded = true;
				ai.isLoading = false;
				ai.bytesLoaded = ai.bytesTotal;
				ai.loadingPhase = 1;
			}
		}

		protected function onLoaderProgress(e:ProgressEvent):void {
			var ai:AssetItemInfo = getAssetItemInfoByContentLoaderInfo(e.target as LoaderInfo);
			if (Boolean(ai)) {
				ai.bytesLoaded = e.bytesLoaded;
				ai.bytesTotal = e.bytesTotal;
				ai.loadingPhase = e.bytesLoaded / e.bytesTotal;
			}
		}

		protected function onLoaderComplete(e:Event):void {
			//trace ("ITEM COMPLETE: "+e.target +", " + e.currentTarget);
			var ai:AssetItemInfo = getAssetItemInfoByContentLoaderInfo(e.target as LoaderInfo);
			if (Boolean(ai)) {
				ai.isLoaded = true;
				ai.isLoading = false;
				ai.bytesLoaded = ai.bytesTotal;
				ai.loadingPhase = 1;
			}
		}

		protected function onVideoLoaderProgress(e:ProgressEvent):void {
			var ai:AssetItemInfo = getAssetItemInfoByObject(e.target);
			if (Boolean(ai)) {
				ai.bytesLoaded = e.bytesLoaded;
				ai.bytesTotal = e.bytesTotal;
				ai.loadingPhase = e.bytesLoaded / e.bytesTotal;
			}
		}

		protected function onVideoLoaderComplete(e:Event):void {
			//trace ("ITEM COMPLETE: "+e.target +", " + e.currentTarget);
			var ai:AssetItemInfo = getAssetItemInfoByObject(e.target);
			if (Boolean(ai)) {
				ai.isLoaded = true;
				ai.isLoading = false;
				ai.bytesLoaded = ai.bytesTotal;
				ai.loadingPhase = 1;
			}
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function addAssetItemInfo(__assetItemInfo:AssetItemInfo):void {
			assets.push(__assetItemInfo);
		}

		public function addDynamicAsset(__url:String, __name:String = "", __avoidCache:Boolean = false, __type:String = ""):void {
			if (!Boolean(__type)) __type = AssetType.getFromURL(__url);
			var ai:AssetItemInfo = new AssetItemInfo(__name, __type, __avoidCache);
			ai.url = __url;

			// TODO: add option to allow an asset to be loaded/monitored without being fully loaded? VideoLoaders can be used even if not available yet...

			assets.push(ai);
		}

		public function getAssetItemInfoByName(__name:String):AssetItemInfo {
			// Use object list instead?
			if (!Boolean(assets)) return null;
			var i:int;
			for (i = 0; i < assets.length; i++) {
				if (assets[i].name == __name) return assets[i];
			}
			return null;
		}

		public function getAssetItemInfoByIndex(__index:int):AssetItemInfo {
			// Use object list instead?
			if (!Boolean(assets) || __index > assets.length) return null;
			return assets[__index];
		}

		public function getAssetItemInfoByURL(__url:String):AssetItemInfo {
			// Use object list instead?
			if (!Boolean(assets)) return null;
			var i:int;
			for (i = 0; i < assets.length; i++) {
				if (assets[i].url == __url) return assets[i];
			}
			return null;
		}

		public function getAssetItemInfoByObject(__object:Object):AssetItemInfo {
			// Use object list instead?
			if (!Boolean(assets)) return null;
			var i:int;
			for (i = 0; i < assets.length; i++) {
				if (assets[i].loadingObject == __object) return assets[i];
			}
			return null;
		}

		public function getAssetItemInfoByContentLoaderInfo(__contentLoaderInfo:LoaderInfo):AssetItemInfo {
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

		public function startLoadings():void {
			// Start all loads that didn't start yet

			//trace("AssetLibrary.startLoadings()");

			var i:int;
			var url:String;
			var urlSuffix:String;
			for (i = 0; i < assets.length; i++) {
				if (!assets[i].isLoading && !assets[i].isLoaded) {

					switch (assets[i].type) {
						case AssetType.XML:
						case AssetType.JSON:
						case AssetType.CSS:
							// Text, use an URLLoader
							assets[i].loadingObject = new URLLoader();
							(assets[i].loadingObject as URLLoader).addEventListener(ProgressEvent.PROGRESS, onURLLoaderProgress, false, 0, true);
							(assets[i].loadingObject as URLLoader).addEventListener(Event.COMPLETE, onURLLoaderComplete, false, 0, true);
							url = assets[i].url;
							urlSuffix = assets[i].avoidCache ? getRandomURLSuffix(url.indexOf("?") == -1) : "";
							queue.addURLLoader(assets[i].loadingObject, new URLRequest(url + urlSuffix));
							break;
						case AssetType.SWF:
						case AssetType.IMAGE:
							assets[i].loadingObject = new Loader();
							(assets[i].loadingObject as Loader).contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress, false, 0, true);
							(assets[i].loadingObject as Loader).contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete, false, 0, true);
							url = assets[i].url;
							urlSuffix = assets[i].avoidCache ? getRandomURLSuffix(url.indexOf("?") == -1) : "";
							queue.addLoader(assets[i].loadingObject, new URLRequest(url + urlSuffix));
							break;
						case AssetType.BINARY:
							// Binary, use an URLLoader
							assets[i].loadingObject = new URLLoader();
							(assets[i].loadingObject as URLLoader).dataFormat = URLLoaderDataFormat.BINARY;
							(assets[i].loadingObject as URLLoader).addEventListener(ProgressEvent.PROGRESS, onURLLoaderProgress, false, 0, true);
							(assets[i].loadingObject as URLLoader).addEventListener(Event.COMPLETE, onURLLoaderComplete, false, 0, true);
							url = assets[i].url;
							urlSuffix = assets[i].avoidCache ? getRandomURLSuffix(url.indexOf("?") == -1) : "";
							queue.addURLLoader(assets[i].loadingObject, new URLRequest(url + urlSuffix));
							break;
						case AssetType.VIDEO:
							assets[i].loadingObject = new VideoLoader();
							(assets[i].loadingObject as VideoLoader).addEventListener(ProgressEvent.PROGRESS, onVideoLoaderProgress, false, 0, true);
							(assets[i].loadingObject as VideoLoader).addEventListener(Event.COMPLETE, onVideoLoaderComplete, false, 0, true);
							url = assets[i].url;
							urlSuffix = assets[i].avoidCache ? getRandomURLSuffix(url.indexOf("?") == -1) : "";
							queue.addVideoLoader(assets[i].loadingObject, new URLRequest(url + urlSuffix));
							break;
						default:
							throw new Error ("AssetLibrary :: startLoads :: can't start loading of asset [" + assets[i].url + "] type '" + assets[i].type + "'!");
					}
					assets[i].isLoading = true;

					info("Loading ["+url+"] ["+urlSuffix+"]");
				}
			}

			if (queue.paused) queue.resume();
		}

		public function getLoadedPhase():Number {
			var total:Number = 0;
			for (var i:int = 0; i < assets.length; i++) {
				total += assets[i].isLoaded ? 1 : assets[i].loadingPhase * 0.99;
			}
			return total / assets.length;
		}

		public function getAssetLoadedPhase(__name:String):Number {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (!Boolean(ai)) return 0;
			if (ai.isLoaded) return 1;
			if (ai.isLoading) return ai.loadingPhase * 0.99;
			return 0;
		}

		// Type-specific content functions
		public function getAssetByName(__name:String):Object {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsset();
			return null;
		}

		public function getAssetByIndex(__index:int):Object {
			var ai:AssetItemInfo = getAssetItemInfoByIndex(__index);
			if (Boolean(ai)) return ai.getAsset();
			return null;
		}

		public function getAssetByURL(__url:String):Object {
			var ai:AssetItemInfo = getAssetItemInfoByURL(__url);
			if (Boolean(ai)) return ai.getAsset();
			return null;
		}

		public function getXML(__name:String):XML {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsXML();
			return null;
		}

		public function getJSON(__name:String):Object {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsJSON();
			return null;
		}

		public function getDisplayObject(__name:String):DisplayObject {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsDisplayObject();
			return null;
		}

		public function getVideoLoader(__name:String):VideoLoader {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsVideoLoader();
			return null;
		}

		public function getStyleSheet(__name:String):StyleSheet {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsStyleSheet();
			return null;
		}

		public function getByteArray(__name:String):ByteArray {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsByteArray();
			return null;
		}

		public function getBitmapData(__name:String):BitmapData {
			var ai:AssetItemInfo = getAssetItemInfoByName(__name);
			if (Boolean(ai)) return ai.getAsBitmapData();
			return null;
		}

		public function dispose():void {
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

		public function get name():String {
			return _name;
		}

		public function get numAssets():int {
			return Boolean(assets) ? assets.length : 0;
		}

		public function get numUnloadedAssets():int {
			var unloadedAssets:int = 0;
			if (Boolean(assets)) {
				for (var i:int = 0; i < assets.length; i++) {
					if (!assets[i].isLoaded) unloadedAssets++;
				}
			}
			return unloadedAssets;
		}
	}
}
import com.zehfernando.net.assets.AssetType;
import com.zehfernando.net.loaders.VideoLoader;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.net.URLLoader;
import flash.text.StyleSheet;
import flash.utils.ByteArray;

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
	public var avoidCache:Boolean;
	public var bytesLoaded:int;
	public var bytesTotal:int;
	public var loadingPhase:Number;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function AssetItemInfo(__name:String, __type:String, __avoidCache:Boolean) {
		name = __name;
		type = __type;
		isLoading = false;
		isLoaded = false;
		url = "";
		loadingObject = null;
		avoidCache = __avoidCache;
		bytesLoaded = 0;
		bytesTotal = 0;
		loadingPhase = 0;
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function getAsset():Object {
		switch (type) {
			case AssetType.XML:
				return getAsXML();
			case AssetType.JSON:
				return getAsJSON();
			case AssetType.CSS:
				return getAsStyleSheet();
			case AssetType.SWF:
			case AssetType.IMAGE:
				return getAsDisplayObject();
			case AssetType.VIDEO:
				return getAsVideoLoader();
			case AssetType.BINARY:
				return getAsByteArray();
		}
		return null;
	}

	public function getAsXML():XML {
		if (isLoaded) return new XML((loadingObject as URLLoader).data);
		return null;
	}

	public function getAsJSON():Object {
		if (isLoaded) return JSON.parse(((loadingObject as URLLoader).data as String).replace(/\/\*.*?\*\//sg, ""));
		return null;
	}

	public function getAsStyleSheet():StyleSheet {
		if (isLoaded) {
			var ss:StyleSheet = new StyleSheet();
			ss.parseCSS((loadingObject as URLLoader).data);
			return ss;
		}
		return null;
	}

	public function getAsDisplayObject():DisplayObject {
		if (isLoaded) return (loadingObject as Loader).content;
		return null;
	}

	public function getAsByteArray():ByteArray {
		if (isLoaded) return (loadingObject as URLLoader).data;
		return null;
	}

	public function getAsBitmapData():BitmapData {
		if (isLoaded) return ((loadingObject as Loader).content as Bitmap).bitmapData;
		return null;
	}

	public function getAsVideoLoader():VideoLoader {
		return loadingObject as VideoLoader;
		// TODO: allow download to check whether the request needs a fully loaded file or not?
		//if (isLoaded) return loadingObject as VideoLoader;
		//return null;
	}

	public function dispose():void {
		switch (type) {
			case AssetType.XML:
			case AssetType.JSON:
			case AssetType.CSS:
			case AssetType.BINARY:
				break;
			case AssetType.SWF:
			case AssetType.IMAGE:
				(loadingObject as Loader).unloadAndStop();
				break;
			case AssetType.VIDEO:
				getAsVideoLoader().dispose();
				//if (isLoaded) getAsVideoLoader().dispose();
				break;
		}
		loadingObject = null;
	}
}
