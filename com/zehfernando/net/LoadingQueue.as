package com.zehfernando.net {
	import com.zehfernando.net.loaders.ImageLoader;
	import com.zehfernando.net.loaders.VideoLoader;
	import com.zehfernando.net.loaders.VideoLoaderEvent;
	import com.zehfernando.utils.console.log;

	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;


	/**
	 * @author Zeh
	 */
	public class LoadingQueue extends EventDispatcher {

		// Properties
		public var maximumRetries:uint;

		protected var _slots:uint;											// Maximum simultaneous loadings

		protected var _cumulativeBytesLoaded:uint;
		protected var _cumulativeSimulatedBytesLoaded:uint;

		protected var queue:Vector.<LoadingQueueItemInfo>;					// Items currently waiting in line
		protected var currentLoaders:Vector.<LoadingQueueItemInfo>;			// Items currently loading

		protected var _paused:Boolean;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function LoadingQueue(__target:IEventDispatcher = null) {
			super(__target);

			setDefaultProperties();

			//trace("LoadingQueue.LoadingQueue()");
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected function setDefaultProperties():void {
			_slots = 1;
			maximumRetries = 0;
			_paused = true;
			_cumulativeBytesLoaded = 0;
			_cumulativeSimulatedBytesLoaded = 0;
			//_cumulativeTimeSpent = 0;

			queue = new Vector.<LoadingQueueItemInfo>();
			currentLoaders = new Vector.<LoadingQueueItemInfo>();
		}

		protected function checkUnusedSlots():void {
			// Check if there are remaining loading slots

			//trace("LoadingQueue.checkUnusedSlots()");

			if (!_paused) {
				while (currentLoaders.length < _slots && queue.length > 0) {
					loadNextItem();
				}

				if (queue.length == 0) {
					//trace ("LoadingQueue.checkUnusedSlots() - All queued items have been fired already.");
					if (currentLoaders.length == 0) {
						//trace ("LoadingQueue.checkUnusedSlots() - All done!");
						dispatchCompleteEvent();
					}
				}
			}
		}

		private function selectNextItemToLoad():LoadingQueueItemInfo {
			// Find the next item that should be loaded
			var i:int;
			var nextItemIndex:int = -1;
			var nextItemPriority:Number = 1;
			for (i = 0; i < queue.length; i++) {
				if (nextItemIndex < 0 || nextItemPriority < queue[i].priority) {
					// This is the first item in the list, or an item has higher priority than the previous one
					nextItemIndex = i;
					nextItemPriority = queue[i].priority;
				}
			}

			return queue[nextItemIndex];
		}

		protected function loadNextItem():void {
			// Remove one item from the loading queue, and start loading it

			//trace("LoadingQueue.loadNextItem()");

			var q:LoadingQueueItemInfo = selectNextItemToLoad();
			queue.splice(queue.indexOf(q), 1);
			currentLoaders.push(q);

			//Log.echo("ADDING: " +q.request.url);

			if (q.targetObject is URLLoader) {

				var ul:URLLoader = q.targetObject as URLLoader;

				//ul.addEventListener(Event.OPEN, onURLLoaderOpen, false, 0, true);
				ul.addEventListener(Event.COMPLETE, onURLLoaderComplete, false, 0, true);
				ul.addEventListener(ProgressEvent.PROGRESS, onURLLoaderProgress, false, 0, true);
				//ul.addEventListener(HTTPStatusEvent.HTTP_STATUS, onURLLoaderHTTPStatus, false, 0, true); // TODO: set the http status?
				ul.addEventListener(IOErrorEvent.IO_ERROR, onURLLoaderIOError, false, 0, true);
				//l.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderSecurityError, false, 0, true);

				ul.load(q.request);
			} else if (q.targetObject is Loader) {

				var ld:Loader = q.targetObject as Loader;

				//ld.contentLoaderInfo.addEventListener(Event.OPEN, onLoaderOpen, false, 0, true);
				ld.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete, false, 0, true);
				ld.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress, false, 0, true);
				//ld.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus, false, 0, true); // TODO: set the http status?
				ld.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderIOError, false, 0, true);
				// Event.INIT
				// Event.UNLOAD

				var lc:LoaderContext = new LoaderContext(true);
				ld.load(q.request, lc);
			} else if (q.targetObject is ImageLoader) {

				var id:ImageLoader = q.targetObject as ImageLoader;

				//ld.contentLoaderInfo.addEventListener(Event.OPEN, onLoaderOpen, false, 0, true);
				id.addEventListener(Event.COMPLETE, onImageLoaderComplete, false, 0, true);
				id.addEventListener(ProgressEvent.PROGRESS, onImageLoaderProgress, false, 0, true);
				//ld.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, onLoaderHTTPStatus, false, 0, true); // TODO: set the http status?
				id.addEventListener(IOErrorEvent.IO_ERROR, onImageLoaderIOError, false, 0, true);
				// Event.INIT
				// Event.UNLOAD

				id.load(q.request);
			} else if (q.targetObject is VideoLoader) {

				var vl:VideoLoader = q.targetObject as VideoLoader;

				//vl.addEventListener(Event.OPEN, onLoaderOpen, false, 0, true);
				vl.addEventListener(Event.COMPLETE, onVideoLoaderComplete, false, 0, true);
				vl.addEventListener(ProgressEvent.PROGRESS, onVideoLoaderProgress, false, 0, true);
				vl.addEventListener(VideoLoaderEvent.STREAM_NOT_FOUND, onVideoLoaderStreamNotFound, false, 0, true);

				vl.load(q.request);

			} else {
				throw new Error("LoadingQueue :: loadNextItem() tried loading an item '" + q.targetObject + "' of unknown type");
			}
		}

		protected function getQueueItemInfoForObject(__targetObject:*): LoadingQueueItemInfo {
			// Based on a target object, returns the LoadingQueueItemInfo instance that is loading it
			var i:int;
			for (i = 0; i < currentLoaders.length; i++) {
				if (currentLoaders[i].targetObject == __targetObject) return currentLoaders[i];
			}
			return null;
		}

		protected function getQueueItemInfoForObjectLoaderInfo(__targetObject:LoaderInfo):LoadingQueueItemInfo {
			// Based on a target object's contentLoaderInfo, returns the LoadingQueueItemInfo instance that is loading it
			var i:int;
			for (i = 0; i < currentLoaders.length; i++) {
				if (Object(currentLoaders[i].targetObject).hasOwnProperty("contentLoaderInfo") && currentLoaders[i].targetObject["contentLoaderInfo"] == __targetObject) return currentLoaders[i];
			}
			return null;
		}

		protected function removeItemFromCurrentLoaders(__q:LoadingQueueItemInfo):Boolean {
			var iq:int = currentLoaders.indexOf(__q);

			/*
			// Implied?
			if (__q.targetObject is URLLoader) {
				var l:URLLoader = __q.targetObject as URLLoader;

				l.removeEventListener(Event.OPEN, onURLLoaderOpen);
				l.removeEventListener(Event.COMPLETE, onURLLoaderComplete);
				l.removeEventListener(ProgressEvent.PROGRESS, onURLLoaderProgress);
				l.removeEventListener(HTTPStatusEvent.HTTP_STATUS, onURLLoaderHTTPStatus);
				l.removeEventListener(IOErrorEvent.IO_ERROR, onURLLoaderIOError);
				//l.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLLoaderSecurityError);

			} else {
				throw new Error("LoadingQueue :: removeItemFromCurrentLoaders() tried unregistering an item '" + q.targetObject + "' of unknown type");
			}
			*/

			if (iq > -1) {
				//Log.echo("REMOVING: " + currentLoaders[iq].request.url);
				currentLoaders.splice(iq, 1);
				return true;
			}
			return false;
		}

		protected function dispatchProgressEvent():void {
			var bl:int = 0;
			var bt:int = 0;
			var i:int;

			bl += _cumulativeSimulatedBytesLoaded;
			bt += _cumulativeSimulatedBytesLoaded;

			for (i = 0; i < queue.length; i++) {
				bl += queue[i].simulatedBytesLoaded;
				bt += queue[i].simulatedBytesTotal;
			}

			for (i = 0;i < currentLoaders.length; i++) {
				bl += currentLoaders[i].simulatedBytesLoaded;
				bt += currentLoaders[i].simulatedBytesTotal;
			}

			var ne:Event = new ProgressEvent(ProgressEvent.PROGRESS, false, false, bl, bt);
			dispatchEvent(ne);
		}

		protected function dispatchCompleteEvent():void {
			var ne:Event = new Event(Event.COMPLETE);
			dispatchEvent(ne);
		}

		/*
		protected function dispatchCompleteItemEvent(__queueItem:LoadingQueueItemInfo):void {
			var ne:Event = new LoadingQueueEvent(LoadingQueueEvent.COMPLETE_ITEM, this, __queueItem.targetObject);
			dispatchEvent(ne);
		}
		*/


		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		// TODO: this is too redundant?

		// URLLoader

		protected function onURLLoaderProgress(e:ProgressEvent):void {
			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);
			q.bytesLoaded = e.bytesLoaded;
			q.bytesTotal = e.bytesTotal;

			dispatchProgressEvent();
		}

		protected function onURLLoaderComplete(e:Event):void {
			// Successfully loaded one item, remove it from the queue
			//trace ("LoadingQueue.onURLLoaderComplete :: Object '" + e.target);

			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);

			//_cumulativeTimeSpent += (getTimer() - q.timeStarted);
			_cumulativeBytesLoaded += (q.targetObject as URLLoader).bytesTotal;
			_cumulativeSimulatedBytesLoaded += q.simulatedBytesTotal;

			removeItemFromCurrentLoaders(q);

			//dispatchCompleteItemEvent(q);

			checkUnusedSlots();
		}

		protected function onURLLoaderIOError(e:IOErrorEvent):void {
			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);
			//trace ("LoadingQueue :: onURLLoaderIOError :: Object '" + q.targetObject + "' has thrown an IOErrorEvent of " + e.text);

			removeItemFromCurrentLoaders(q);

			if (q.retries < maximumRetries) {
				// Try again
				q.retries++;
				queue.push(q);
			} else {
				// Maximum tries already
				log("Can't load: reached maximum number of tries for URLLoader [" +q.request.url + "] !");
			}
		}

		// VideoLoader

		protected function onVideoLoaderProgress(e:ProgressEvent):void {
			//Log.echo("current = " + currentLoaders.length + ", total = " + queue.length);

			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);
			q.bytesLoaded = e.bytesLoaded;
			q.bytesTotal = e.bytesTotal;

			dispatchProgressEvent();
		}

		protected function onVideoLoaderComplete(e:Event):void {
			// Successfully loaded one item, remove it from the queue
			//trace ("LoadingQueue.onURLLoaderComplete :: Object '" + e.target);

			//Log.echo(currentLoaders.length);

			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);

			//_cumulativeTimeSpent += (getTimer() - q.timeStarted);
			_cumulativeBytesLoaded += (q.targetObject as VideoLoader).bytesTotal;
			_cumulativeSimulatedBytesLoaded += q.simulatedBytesTotal;

			removeItemFromCurrentLoaders(q);

			//dispatchCompleteItemEvent(q);

			checkUnusedSlots();
		}

		protected function onVideoLoaderStreamNotFound(e:VideoLoaderEvent):void {
			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);
			//trace ("LoadingQueue :: onURLLoaderIOError :: Object '" + q.targetObject + "' has thrown an IOErrorEvent of " + e.text);

			removeItemFromCurrentLoaders(q);

			if (q.retries < maximumRetries) {
				// Try again
				q.retries++;
				queue.push(q);
			} else {
				// Maximum tries already
				log("Can't load: reached maximum number of tries for VideoLoader [" +q.request.url + "] !");
			}
		}

		// ImageLoader

		protected function onImageLoaderProgress(e:ProgressEvent):void {
			//Log.echo("current = " + currentLoaders.length + ", total = " + queue.length);

			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);
			q.bytesLoaded = e.bytesLoaded;
			q.bytesTotal = e.bytesTotal;

			dispatchProgressEvent();
		}

		protected function onImageLoaderComplete(e:Event):void {
			// Successfully loaded one item, remove it from the queue
			//trace ("LoadingQueue.onURLLoaderComplete :: Object '" + e.target);

			//Log.echo(currentLoaders.length);

			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);

			//_cumulativeTimeSpent += (getTimer() - q.timeStarted);
			_cumulativeBytesLoaded += (q.targetObject as ImageLoader).bytesTotal;
			_cumulativeSimulatedBytesLoaded += q.simulatedBytesTotal;

			removeItemFromCurrentLoaders(q);

			//dispatchCompleteItemEvent(q);

			checkUnusedSlots();
		}

		protected function onImageLoaderIOError(e:VideoLoaderEvent):void {
			var q:LoadingQueueItemInfo = getQueueItemInfoForObject(e.target);
			//trace ("LoadingQueue :: onURLLoaderIOError :: Object '" + q.targetObject + "' has thrown an IOErrorEvent of " + e.text);

			removeItemFromCurrentLoaders(q);

			if (q.retries < maximumRetries) {
				// Try again
				q.retries++;
				queue.push(q);
			} else {
				// Maximum tries already
				log("Can't load: reached maximum number of tries for ImageLoader [" +q.request.url + "] !");
			}
		}

		// Loader

		protected function onLoaderProgress(e:ProgressEvent):void {
			var q:LoadingQueueItemInfo = getQueueItemInfoForObjectLoaderInfo(e.target as LoaderInfo);
			q.bytesLoaded = e.bytesLoaded;
			q.bytesTotal = e.bytesTotal;

			dispatchProgressEvent();
		}

		protected function onLoaderComplete(e:Event):void {
			// Successfully loaded one item, remove it from the queue
			//trace ("LoadingQueue.onURLLoaderComplete :: Object '" + e.target);

			var q:LoadingQueueItemInfo = getQueueItemInfoForObjectLoaderInfo(e.target as LoaderInfo);

			//_cumulativeTimeSpent += (getTimer() - q.timeStarted);
			_cumulativeBytesLoaded += (q.targetObject as Loader).contentLoaderInfo.bytesTotal;
			_cumulativeSimulatedBytesLoaded += q.simulatedBytesTotal;

			removeItemFromCurrentLoaders(q);

			//dispatchCompleteItemEvent(q);

			checkUnusedSlots();
		}

		protected function onLoaderIOError(e:IOErrorEvent):void {
			var q:LoadingQueueItemInfo = getQueueItemInfoForObjectLoaderInfo(e.target as LoaderInfo);
			//trace ("LoadingQueue :: onURLLoaderIOError :: Object '" + q.targetObject + "' has thrown an IOErrorEvent of " + e.text);

			removeItemFromCurrentLoaders(q);

			if (q.retries < maximumRetries) {
				// Try again
				q.retries++;
				queue.push(q);
			} else {
				// Maximum tries already
				log("Can't load: reached maximum number of tries for Loader [" +q.request.url + "] !");
			}
		}


		// ================================================================================================================
		// PUBLIC functions -----------------------------------------------------------------------------------------------

		public function addURLLoader(__targetObject:URLLoader, __request:URLRequest, __simulatedBytesTotal:Number = 10000, __priority:Number = 1):void {
			//trace("LoadingQueue.addURLLoader("+__targetObject+", "+__request+", "+__simulatedBytesTotal+")");
			var q:LoadingQueueItemInfo = new LoadingQueueItemInfo(__targetObject, __request);
			q.priority = __priority;
			q.simulatedBytesTotal = __simulatedBytesTotal;
			queue.push(q);
			checkUnusedSlots();
		}

		public function addLoader(__targetObject:Loader, __request:URLRequest, __simulatedBytesTotal:Number = 100000, __priority:Number = 1):void {
			//trace("LoadingQueue.addURLLoader("+__targetObject+", "+__request+", "+__simulatedBytesTotal+")");
			var q:LoadingQueueItemInfo = new LoadingQueueItemInfo(__targetObject, __request);
			q.priority = __priority;
			q.simulatedBytesTotal = __simulatedBytesTotal;
			queue.push(q);
			checkUnusedSlots();
		}

		public function addImageLoader(__targetObject:ImageLoader, __request:URLRequest, __simulatedBytesTotal:Number = 100000, __priority:Number = 1):void {
			//trace("LoadingQueue.addURLLoader("+__targetObject+", "+__request+", "+__simulatedBytesTotal+")");
			var q:LoadingQueueItemInfo = new LoadingQueueItemInfo(__targetObject, __request);
			q.priority = __priority;
			q.simulatedBytesTotal = __simulatedBytesTotal;
			queue.push(q);
			checkUnusedSlots();
		}

		public function addVideoLoader(__targetObject:VideoLoader, __request:URLRequest, __simulatedBytesTotal:Number = 1000000, __priority:Number = 1):void {
			//trace("LoadingQueue.addURLLoader("+__targetObject+", "+__request+", "+__simulatedBytesTotal+")");
			var q:LoadingQueueItemInfo = new LoadingQueueItemInfo(__targetObject, __request);
			q.priority = __priority;
			q.simulatedBytesTotal = __simulatedBytesTotal;
			queue.push(q);
			checkUnusedSlots();
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get slots():Number {
			return _slots;
		}
		public function set slots(__value:Number):void {
			if (_slots != __value) {
				_slots = __value;
				checkUnusedSlots();
			}
		}

		public function get paused():Boolean {
			return _paused;
		}

		public function pause():void {
			if (!_paused) {
				_paused = true;
			}
		}

		public function resume():void {
			if (_paused) {
				_paused = false;
				checkUnusedSlots();
			}
		}

		public function dispose():void {
			pause();
			queue = new Vector.<LoadingQueueItemInfo>();
			currentLoaders = new Vector.<LoadingQueueItemInfo>();
		}
	}
}
import flash.net.URLRequest;

class LoadingQueueItemInfo {

	// Properties
	public var targetObject:*;
	public var request:URLRequest;
	public var retries:uint;								// Number of times this loading has been retried
	public var simulatedBytesTotal:Number;					// Number of simulated bytes total
	public var bytesLoaded:Number;							// Number of bytes actually loaded
	public var bytesTotal:Number;							// Number of total bytes
	public var priority:Number;								// Priority (higher = higher priority)

	// ================================================================================================================
	// PUBLIC functions -----------------------------------------------------------------------------------------------

	public function LoadingQueueItemInfo(__targetObject:*, __request:URLRequest) {
		targetObject = __targetObject;
		request = __request;
		retries = 0;
		bytesLoaded = 0;
		bytesTotal = 0;
		simulatedBytesTotal = 10000;
		priority = 1;
	}

	// ================================================================================================================
	// ACCESSOR functions ---------------------------------------------------------------------------------------------

	public function get simulatedBytesLoaded():Number {
		return bytesTotal == 0 ? 0 : Math.round((bytesLoaded/bytesTotal) * simulatedBytesTotal);
	}
}