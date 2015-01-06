package com.zehfernando.display.templates.application {
	import com.zehfernando.display.templates.application.events.ApplicationFrame2Event;
	import com.zehfernando.net.assets.AssetLibrary;
	import com.zehfernando.utils.AppUtils;
	import com.zehfernando.utils.console.Console;
	import com.zehfernando.utils.console.info;
	import com.zehfernando.utils.getTimerUInt;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;

	/**
	 * @author Zeh
	 */
	public class ApplicationFrame1Abstract extends MovieClip {

		// Constants
		protected static const LIBRARY_ADDITIONAL_DATA:String = "additionalDataLibrary";

		// Properties
		protected var swfLoaded:Boolean;									// Whether the complete SWF is loaded or not
		protected var swfLoadingPhase:Number;								// Percentage (0-1) of the SWF loading
		protected var swfLoadingWeight:Number;								// Loading "weight" for total percentage counting
		protected var dataLoadingNeeded:Boolean;							// Whether main data needs to be loaded or not
		protected var dataLoaded:Boolean;									// Whether main data is loaded or not
		protected var dataLoadingPhase:Number;								// Percentage (0-1) of the data loading
		protected var dataLoadingWeight:Number;								// Loading "weight" for total percentage counting
		protected var additionalDataLoadingNeeded:Boolean;					// Additional data (based on first XML?)
		protected var additionalDataLoading:Boolean;
		protected var additionalDataLoaded:Boolean;
		protected var additionalDataLoadingPhase:Number;
		protected var additionalDataLoadingWeight:Number;					// Loading "weight" for total percentage counting
		protected var frame2DataLoaded:Boolean;								// Additional data (loaded by frame 2)
		protected var frame2DataLoadingPhase:Number;
		protected var frame2DataLoadingWeight:Number;						// Loading "weight" for total percentage counting
		protected var isFrame2Inited:Boolean;
		protected var framesAfterLoaded:int;								// Number of frames passed after the onEnterFrame event has indicated a full load
		protected var timeStartedLoading:uint;
		protected var sizeAfterPreloader:int;
		protected var frame2ClassName:String;

		protected var userSpeedBytesPerSecond:Number;						// Measured user speed
		protected var userSpeedBitsPerSecond:Number;						// Measured user speed
		protected var userLoadingTime:Number;								// Total loading time, in seconds

		// Instances
		protected var frame2:ApplicationFrame2Abstract;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------
		public function ApplicationFrame1Abstract() {
			super();

			setDefaultProperties();
			createAssets();
			initialize();

			info("Initial loader byte size is " + root.loaderInfo.bytesLoaded + " bytes out of " + root.loaderInfo.bytesTotal + " bytes (" + ((root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal) * 100).toFixed(2) + "% of total)");
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function setDefaultProperties():void {
			swfLoaded = false;
			swfLoadingPhase = 0;
			swfLoadingWeight = 100;

			dataLoadingNeeded = true;
			dataLoaded = false;
			dataLoadingPhase = 0;
			dataLoadingWeight = 10;

			additionalDataLoadingNeeded = true;
			additionalDataLoaded = false;
			additionalDataLoading = false;
			additionalDataLoadingPhase = 0;
			additionalDataLoadingWeight = 10;

			frame2DataLoaded = false;
			frame2DataLoadingPhase = 0;
			frame2DataLoadingWeight = 10;

			timeStartedLoading = getTimerUInt();
			sizeAfterPreloader = loaderInfo.bytesLoaded;
			isFrame2Inited = false;
		}

		protected function createAssets():void {
			createLoadingInterface();
		}

		protected function initialize():void {
			stop();

			AppUtils.init(stage, this);
			AppUtils.resetContextMenu();

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			// Start loading data
			startLoadingSWF();
			startLoadingData();

			AppUtils.getStage().addEventListener(Event.RESIZE, onResize, false, 0, true);
			AppUtils.getStage().addEventListener(Event.ENTER_FRAME, waitUntilStageSizeIsKnown, false, 0, true);
			waitUntilStageSizeIsKnown(null);

			Console.useJS = true;
			if (!AppUtils.isDebugSWF()) Console.useScreen = Console.useTrace = false;
		}

		protected function startLoadingSWF():void {
//			log("LOAD / SWF / INIT");
			// Start checking the SWF loading state
			framesAfterLoaded = 0;
			addEventListener(Event.ENTER_FRAME, onSWFLoadingProgressHack, false, 0, true);
			// This is needed because Flash won't fire SWF loading events if wmode=transparent!
			root.loaderInfo.addEventListener(ProgressEvent.PROGRESS, onSWFLoadingProgress, false, 0, true);
			root.loaderInfo.addEventListener(Event.COMPLETE, onSWFLoadingComplete, false, 0, true);
		}

		protected function startLoadingData():void {
			// Start loading XML data
//			log("LOAD / DATA / INIT");
			var dal:AssetLibrary = new AssetLibrary();
			addAssetsToDataLibrary(dal);

			dal.addEventListener(ProgressEvent.PROGRESS, onDataLoadingProgress, false, 0, true);
			dal.addEventListener(Event.COMPLETE, onDataLoadingComplete, false, 0, true);

			dal.startLoadings();
		}

		protected function addAssetsToDataLibrary(__dataLibrary:AssetLibrary):void {
			// EXTEND THIS
		}

		protected function startLoadingAdditionalData():void {
			// Start loading additional XML data
//			log("LOAD / ADDITIONAL DATA / INIT");
			additionalDataLoading = true;

			var dal:AssetLibrary = new AssetLibrary(LIBRARY_ADDITIONAL_DATA);
			addAdditionalAssetsToDataLibrary(dal);

			dal.addEventListener(ProgressEvent.PROGRESS, onAdditionalDataLoadingProgress, false, 0, true);
			dal.addEventListener(Event.COMPLETE, onAdditionalDataLoadingComplete, false, 0, true);

			dal.startLoadings();
		}

		protected function addAdditionalAssetsToDataLibrary(__dataLibrary:AssetLibrary):void {
			// EXTEND THIS
		}

		protected function checkIfCanInitFrame2():void {
			if (additionalDataLoadingNeeded && dataLoaded && (!additionalDataLoading && !additionalDataLoaded)) {
				// Must load additional data first
				startLoadingAdditionalData();
			}
			if (dataLoaded && swfLoaded && (additionalDataLoaded || !additionalDataLoadingNeeded) && !isFrame2Inited) {
				initFrame2();
			}
		}

		protected function initFrame2():void {
//			log("LOAD / FRAME 2 INIT / INIT");
			isFrame2Inited = true;

			userLoadingTime = (getTimerUInt() - timeStartedLoading) / 1000;

			var mainClass:Class = Class(getDefinitionByName(frame2ClassName));
			frame2 = new mainClass();
			frame2.userSpeedBytesPerSecond = userSpeedBytesPerSecond;
			frame2.userSpeedBitsPerSecond = userSpeedBitsPerSecond;
			frame2.userLoadingTime = userLoadingTime;
			frame2.addEventListener(ApplicationFrame2Event.INIT_PROGRESS, onFrame2InitProgress, false, 0, true);
			frame2.addEventListener(ApplicationFrame2Event.INIT_COMPLETE, onFrame2InitComplete, false, 0, true);
			addChildAt(frame2, 0);

			frame2.init();
			onResize(null);
		}

		protected function showFrame2():void {
			//log();
			frame2.show();
		}

		protected function getTotalLoadingPhase():Number {
			// Returns the percentage (0-1) of loading done for everything
			var l:Number = 0;
			var t:Number = 0;

			l += swfLoadingPhase * swfLoadingWeight;
			t += swfLoadingWeight;

//			log ("+++ ", swfLoadingPhase, swfLoadingWeight);

			if (dataLoadingNeeded) {
				l += dataLoadingPhase * dataLoadingWeight;
				t += dataLoadingWeight;
//			log ("+++ ", dataLoadingPhase, dataLoadingWeight);
			}
			if (additionalDataLoadingNeeded) {
				l += additionalDataLoadingPhase * additionalDataLoadingWeight;
				t += additionalDataLoadingWeight;
//			log ("+++ ", additionalDataLoadingPhase, additionalDataLoadingWeight);
			}

			l += frame2DataLoadingPhase * frame2DataLoadingWeight;
			t += frame2DataLoadingWeight;
//			log ("+++ ", frame2DataLoadingPhase, frame2DataLoadingWeight);

//			log ("==== " + l, t);

			return l / t;
		}

		protected function createLoadingInterface():void {
			// EXTEND THIS
		}

		protected function updateLoadingInterface():void {
			// EXTEND THIS
		}

		protected function resizeLoadingInterface():void {
			// EXTEND THIS
		}

		protected function removeLoadingInterface():void {
			// EXTEND THIS
		}

		protected function removeLoadingInterfaceAndShowFrame2():void {
			removeLoadingInterface();
			showFrame2();
		}

		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected function onResize(e:Event = null):void {
			var w:Number = AppUtils.getStage().stageWidth;
			var h:Number = AppUtils.getStage().stageHeight;

			if (w > 0 && h > 0) {

				resizeLoadingInterface();

				if (Boolean(frame2)) {
					frame2.width = w;
					frame2.height = h;
				}
			}
		}

		protected function waitUntilStageSizeIsKnown(e:Event):void {
			// visible = false;
			if (AppUtils.getStage().stageWidth > 0) {
				// visible = true;
				AppUtils.getStage().removeEventListener(Event.ENTER_FRAME, waitUntilStageSizeIsKnown);
				onResize(null);
			}
		}

		protected function onSWFLoadingProgress(e:ProgressEvent):void {
			swfLoadingPhase = e.bytesLoaded / e.bytesTotal;
//			log("LOAD / SWF / PROGRESS @ " + swfLoadingPhase);

			updateLoadingInterface();
		}

		protected function onSWFLoadingProgressHack(e:Event):void {
			// This is needed because Flash won't fire SWF loading events if wmode=transparent!
//			log("LOAD / SWF / PROGRESS HACK @ " + swfLoadingPhase);

			swfLoadingPhase = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
			// trace ("swf loading progress HACKED = " + root.loaderInfo.bytesLoaded);
			updateLoadingInterface();

			if (swfLoadingPhase >= 1) {
				// Just for safety's sake, wait a few frames after it has finished loading
				framesAfterLoaded++;
				if (framesAfterLoaded > 5) onSWFLoadingComplete(null);
			}
		}

		protected function onSWFLoadingComplete(e:Event):void {
//			log("LOAD / SWF / COMPLETE");
			swfLoadingPhase = 1;
			swfLoaded = true;

			//var timeSpentLoading:Number = getTimerUInt() - timeStartedLoading;

			var timeSpentLoading:uint = getTimerUInt() - timeStartedLoading;
			var sizeSpentLoading:Number = root.loaderInfo.bytesLoaded - sizeAfterPreloader;
			userSpeedBytesPerSecond = sizeSpentLoading / (timeSpentLoading / 1000);
			userSpeedBitsPerSecond = userSpeedBytesPerSecond * 8;

			info ("Spent " + timeSpentLoading + "ms loading the SWF; predicted speed is " + (userSpeedBytesPerSecond / 1024).toFixed(2) + " kbytes per second or " + (userSpeedBitsPerSecond / 1024).toFixed(2) + " kbits per second");

			nextFrame();

			removeEventListener(Event.ENTER_FRAME, onSWFLoadingProgressHack);
			root.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, onSWFLoadingProgress);
			root.loaderInfo.removeEventListener(Event.COMPLETE, onSWFLoadingComplete);

			updateLoadingInterface();
			checkIfCanInitFrame2();
		}

		protected function onDataLoadingProgress(e:ProgressEvent):void {
			dataLoadingPhase = e.bytesLoaded / e.bytesTotal;
//			log("LOAD / DATA / PROGRESS @ " + dataLoadingPhase);

			updateLoadingInterface();
		}

		protected function onDataLoadingComplete(e:Event):void {
			// Finished loading everything
//			log("LOAD / DATA / COMPLETE");
			dataLoadingPhase = 1;
			dataLoaded = true;

			AssetLibrary.getLibrary().removeEventListener(ProgressEvent.PROGRESS, onDataLoadingProgress);
			AssetLibrary.getLibrary().removeEventListener(Event.COMPLETE, onDataLoadingComplete);

			updateLoadingInterface();
			checkIfCanInitFrame2();
		}

		protected function onAdditionalDataLoadingProgress(e:ProgressEvent):void {
			additionalDataLoadingPhase = e.bytesLoaded / e.bytesTotal;
//			log("LOAD / ADDITIONAL DATA / PROGRESS @ " + additionalDataLoadingPhase);

			updateLoadingInterface();
		}

		protected function onAdditionalDataLoadingComplete(e:Event):void {
			// Finished loading everything
//			log("LOAD / ADDITIONAL DATA / COMPLETE");
			additionalDataLoadingPhase = 1;
			additionalDataLoading = false;
			additionalDataLoaded = true;

			var additionalLib:AssetLibrary = AssetLibrary.getLibrary(LIBRARY_ADDITIONAL_DATA);
			var mainLib:AssetLibrary = AssetLibrary.getLibrary();

			additionalLib.removeEventListener(ProgressEvent.PROGRESS, onAdditionalDataLoadingProgress);
			additionalLib.removeEventListener(Event.COMPLETE, onAdditionalDataLoadingComplete);

			// Transfers all assets from the additional library to main library
			var i:int = 0;
			for (i = 0; i < additionalLib.numAssets; i++) {
				mainLib.addAssetItemInfo(additionalLib.getAssetItemInfoByIndex(i));
			}

			additionalLib = null;

			updateLoadingInterface();
			checkIfCanInitFrame2();

		}

		protected function onFrame2InitProgress(e:Event):void {
			frame2DataLoadingPhase = frame2.getInitPhase();
//			log("LOAD / FRAME 2 INIT / PROGRESS @ " + frame2DataLoadingPhase);
			updateLoadingInterface();
		}

		protected function onFrame2InitComplete(e:Event):void {
			frame2DataLoaded = true;

			onFrame2InitProgress(null);
//			log("LOAD / FRAME 2 INIT / COMPLETE");
			frame2.removeEventListener(ApplicationFrame2Event.INIT_PROGRESS, onFrame2InitProgress);
			frame2.removeEventListener(ApplicationFrame2Event.INIT_COMPLETE, onFrame2InitComplete);
			//showFrame2();

			removeLoadingInterfaceAndShowFrame2();
		}
	}
}
