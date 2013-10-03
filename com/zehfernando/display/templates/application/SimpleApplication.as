package com.zehfernando.display.templates.application {
	import com.zehfernando.display.progressbars.RectangleProgressBar;
	import com.zehfernando.net.assets.AssetLibrary;
	import com.zehfernando.utils.AppUtils;
	import com.zehfernando.utils.console.debug;

	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.ProgressEvent;

	/**
	 * @author zeh fernando
	 */
	public class SimpleApplication extends MovieClip {

		// Instances
		private var assetLibrary:AssetLibrary;
		private var preloader:RectangleProgressBar;

		// Properties
		private var isActivated:Boolean;						// Whether the Stage is activated or not
		private var isInitialized:Boolean;						// Whether the visual assets are created

		private var isLoadingDataFirstPass:Boolean;
		private var isLoadingDataSecondPass:Boolean;

		// TODO: allow additional asset loading?

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function SimpleApplication() {
			super();

			// Initial properties
			isActivated = true;
			isInitialized = false;
			isLoadingDataFirstPass = false;
			isLoadingDataSecondPass = false;

			// Other initializations
			waitUntilStageIsKnownToStart();

			// End -- do not add anything else in the constructor
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		// This should be extended:

		protected function addDynamicAssetsFirstPass():void {
			// Extend
			// Example: addDynamicAsset("data/test.json", ASSET_NAME_JSON_TEST);
		}

		protected function addDynamicAssetsSecondPass():void {
			// Extend - only use if needed
			// Example: addDynamicAsset("data/test.json", ASSET_NAME_JSON_TEST);
		}

		protected function getDynamicAssetSecondPassPhaseSize():Number {
			// Extend if needed
			// Pass 0-1 (0 = no second pass needed, 1 = second pass is everything of the loading procedure)
			return 0;
		}

		protected function createVisualAssets():void {
			// Extend
			// Create sprites and stuff here
		}

		protected function redrawVisualAssets():void {
			// Extend
			// Stage resized, redraw your sprites here
		}

		protected function reactivate():void {
			// Extend
			// Activated (switched back to) after being deactivated
		}

		protected function deactivate():void {
			// Extend
			// Deactivated (switched from the app to something else)
		}


		// This can be used:

		protected function addDynamicAsset(__url:String, __name:String = "", __avoidCache:Boolean = false):void {
			assetLibrary.addDynamicAsset(__url, __name, __avoidCache);
		}

		// Other internal stuff

		private function start():void {
			if (assetLibrary.numUnloadedAssets > 0) {
				debug("Needs to load assets before initializing application.");
				startLoadingDataFirstPass();
			} else {
				debug("No assets needed; initialize application.");
				initializeApplication();
			}
		}

		private function initializeApplication():void {
			// Finally, everything has been done, so initialize the application
			isInitialized = true;
			createVisualAssets();
			redrawVisualAssets();
			debug("Application initialized.");
		}

		private function startLoadingDataFirstPass():void {
			// Start loading needed assets
			isLoadingDataFirstPass = true;
			createLoadingInterface();

			assetLibrary.addEventListener(ProgressEvent.PROGRESS, onDataLoadingProgress, false, 0, true);
			assetLibrary.addEventListener(Event.COMPLETE, onDataLoadingComplete, false, 0, true);
			assetLibrary.startLoadings();
		}

		private function startLoadingDataSecondPass():void {
			// Start loading needed assets
			isLoadingDataSecondPass = true;
			assetLibrary.startLoadings();
		}

		private function createLoadingInterface():void {
			preloader = new RectangleProgressBar();
			preloader.width = 100;
			preloader.height = 2;
			preloader.amount = 0;
			addChild(preloader);
		}

		private function redrawLoadingInterface():void {
			preloader.x = Math.round(AppUtils.getStage().stageWidth / 2 - preloader.width / 2);
			preloader.y = Math.round(AppUtils.getStage().stageHeight / 2 - preloader.height / 2);
		}

		private function updateLoadingInterface(__phase:Number):void {
			preloader.amount = Math.max(__phase, preloader.amount);
		}

		private function removeLoadingInterface():void {
			removeChild(preloader);
			preloader = null;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		private function waitUntilStageIsKnownToStart(__e:Event = null):void {
			// Only allows initializing if the stage exists
			if (stage != null) {
				removeEventListener(Event.ENTER_FRAME, waitUntilStageIsKnownToStart);

				stage.quality = StageQuality.HIGH;
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;

				stage.addEventListener(Event.RESIZE, onStageResized);
				stage.addEventListener(Event.ACTIVATE, onStageActivated);
				stage.addEventListener(Event.DEACTIVATE, onStageDeactivated);

				AppUtils.init(stage, this);

				assetLibrary = AssetLibrary.getLibrary();
				if (assetLibrary == null) assetLibrary = new AssetLibrary();

				// Higher-level initialization
				addDynamicAssetsFirstPass();

				// Wait until the stage size is known before properly initializing
				waitUntilStageSizeIsKnownToStart();
			} else {
				addEventListener(Event.ENTER_FRAME, waitUntilStageIsKnownToStart);
			}
		}

		private function waitUntilStageSizeIsKnownToStart(__e:Event = null):void {
			// Only allows initializing if the stage size is known
			if (AppUtils.getStage().stageWidth > 0 && AppUtils.getStage().stageHeight > 0) {
				removeEventListener(Event.ENTER_FRAME, waitUntilStageSizeIsKnownToStart);
				start();
			} else {
				addEventListener(Event.ENTER_FRAME, waitUntilStageSizeIsKnownToStart);
			}
		}

		private function onStageResized(__e:Event):void {
			if (isInitialized) {
				redrawVisualAssets();
			} else if (isLoadingDataFirstPass || isLoadingDataSecondPass) {
				redrawLoadingInterface();
			}
		}

		private function onStageActivated(__e:Event):void {
			if (!isActivated && isInitialized) {
				isActivated = true;
				reactivate();
			}
		}

		private function onStageDeactivated(__e:Event):void {
			if (isActivated && isInitialized) {
				isActivated = false;
				deactivate();
			}
		}

		private function onDataLoadingProgress(e:ProgressEvent):void {
			if (isLoadingDataFirstPass) {
				// First pass
				updateLoadingInterface((e.bytesLoaded / e.bytesTotal) * (1-getDynamicAssetSecondPassPhaseSize()));
			} else {
				// Second pass
				updateLoadingInterface((1-getDynamicAssetSecondPassPhaseSize()) + (e.bytesLoaded / e.bytesTotal) * getDynamicAssetSecondPassPhaseSize());
			}
		}

		private function onDataLoadingComplete(e:Event):void {
			if (isLoadingDataFirstPass) {
				// First pass finished
				isLoadingDataFirstPass = false;
				updateLoadingInterface(1-getDynamicAssetSecondPassPhaseSize());

				addDynamicAssetsSecondPass();
				if (assetLibrary.numUnloadedAssets > 0) {
					// Need second pass
					debug("Need to load assets on secondary pass.");
					startLoadingDataSecondPass();
				} else {
					// Doesn't actually need second pass
					debug("Secondary pass not needed for loading.");
					onDataLoadingComplete(null);
				}
			} else {
				// Second pass finished
				isLoadingDataSecondPass = false;
				updateLoadingInterface(1);

				removeLoadingInterface();

				AssetLibrary.getLibrary().removeEventListener(ProgressEvent.PROGRESS, onDataLoadingProgress);
				AssetLibrary.getLibrary().removeEventListener(Event.COMPLETE, onDataLoadingComplete);

				initializeApplication();
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getAssetLibrary():AssetLibrary {
			return assetLibrary;
		}
	}
}
