package com.zehfernando.display.debug.statgraph {
	import com.zehfernando.utils.getTimerUInt;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author Zeh
	 */
	public class StatGraph extends Sprite {

		// Constants
		protected static const DEFAULT_TIME_INTERVAL:Number = 100;			// Time interval for each pixel column (for averaging and visual updating)
		protected static const DEFAULT_BLOCK_WIDTH:Number = 220;
		protected static const DEFAULT_BLOCK_HEIGHT:Number = 30;

		protected static const NUM_INFO_STAGES:Number = 7;

		// Properties
		protected var isRunning:Boolean;

		protected var _blockWidth:Number;
		protected var _blockHeight:Number;
		protected var _timeInterval:Number;

		protected var lastUpdateTime:uint;

		protected var infoStage:int;

		// Instances
		protected var infoField:TextField;

		protected var dataPoints:Vector.<AbstractDataPoint>;
		protected var dataBlocks:Vector.<StatGraphBlock>;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StatGraph(__blockWidth:Number = NaN, __blockHeight:Number = NaN, __timeIntervalMS:Number = NaN, __x:Number = NaN, __y:Number = NaN) {
			// Set default data
			_blockWidth = isNaN(__blockWidth) ? DEFAULT_BLOCK_WIDTH : __blockWidth;
			_blockHeight = isNaN(__blockHeight) ? DEFAULT_BLOCK_HEIGHT : __blockHeight;
			_timeInterval = isNaN(__timeIntervalMS) ? DEFAULT_TIME_INTERVAL : __timeIntervalMS;

			if (!isNaN(__x)) x = __x;
			if (!isNaN(__y)) y = __y;

			isRunning = false;

			mouseChildren = false;

			// Setup events
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);

			alpha = 0.75;
			infoStage = 0;

			dataPoints = new Vector.<AbstractDataPoint>();
			dataPoints.push(new FPSDataPoint());
			dataPoints.push(new MSDataPoint());
			dataPoints.push(new TotalMemoryDataPoint());
			//dataPoints.push(new PrivateMemoryDataPoint()); // This takes 6ms to be read!

			dataBlocks = new Vector.<StatGraphBlock>();
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected function start():void {
			if (!isRunning) {
				isRunning = true;

				var i:int;
				var db:StatGraphBlock;

				// Creates all data blocks
				for (i = 0; i < dataPoints.length; i++) {
					db = new StatGraphBlock(dataPoints[i], _blockWidth, _blockHeight);
					db.x = 0;
					db.y = i * _blockHeight;
					addChild(db);
					dataBlocks.push(db);
				}

				var fmt:TextFormat = new TextFormat("_sans", 10, 0xffffff);

				infoField = new TextField();
				infoField.defaultTextFormat = fmt;
				infoField.selectable = false;
				infoField.autoSize = TextFieldAutoSize.NONE;
				addChild(infoField);

				infoField.x = 8;
				infoField.y = 1;
				infoField.width = width - infoField.x * 2;
				infoField.height = height - infoField.y * 2;
				infoField.alpha = 0.6;
				infoField.visible = false;
				setInfoFieldText();

				lastUpdateTime = getTimerUInt();
				updateBeforeFrame();
				updateAfterFrame();

				addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 31337, true);
				addEventListener(Event.EXIT_FRAME, onExitFrame, false, -1, true);
				addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);

			}
		}

		protected function setInfoFieldText():void {

			var txt:String = "";

			switch (infoStage) {
				case 0:
					txt += "PLAYER INFO\n";
					txt += "version: " + Capabilities.version + (Capabilities.isDebugger ? " debug" : "") + "\n";
					txt += "playerType: " + Capabilities.playerType + ", cpu: " + Capabilities.cpuArchitecture + "\n";
					break;
				case 1:
					txt += "PLAYER INFO (continued)\n";
					txt += "language:" + Capabilities.language + "\n";
					txt += "OS: " + Capabilities.os + "\n";
					break;
				case 2:
					txt += "PLAYER INFO (continued)\n";
					txt += "Manufacturer:" + Capabilities.manufacturer + "\n";
					txt += "32bits processes: " + Capabilities.supports32BitProcesses + ", 64bits: " + Capabilities.supports64BitProcesses + "\n";
					break;
				case 3:
					txt += "INTERFACES\n";
					txt += "ExternalInterface.available: " + ExternalInterface.available +  "\n";
					txt += "localFileReadDisable: " + Capabilities.localFileReadDisable + "\n";
					break;
				case 4:
					txt += "SCREEN\n";
					txt += "pixelAspectRatio: " + Capabilities.pixelAspectRatio + ", dpi: " + Capabilities.screenDPI + "\n";
					txt += "screenColor: " + Capabilities.screenColor + "\n";
					break;
				case 5:
					txt += "AUDIO\n";
					txt += "hasAudio: " + Capabilities.hasAudio + ", encoder: " + Capabilities.hasAudioEncoder + "\n";
					txt += "hasMP3: " + Capabilities.hasMP3 + ", stream: " + Capabilities.hasStreamingAudio + "\n";
					break;
				case 6:
					txt += "VIDEO\n";
					txt += "embedded vd: " + Capabilities.hasEmbeddedVideo + ", encoder: " + Capabilities.hasVideoEncoder + "\n";
					txt += "hasStreamingVideo: " + Capabilities.hasStreamingVideo + "\n";
					break;
			}

			txt += "Click for more + GC [" + (infoStage+1) + "/"+NUM_INFO_STAGES+"] ";

			infoField.text = txt;
		}

		protected function updateBeforeFrame():void {
			var i:int;
			for (i = 0; i < dataPoints.length; i++) {
				dataPoints[i].updateValuesEnterFrame();
			}
		}

		protected function updateAfterFrame():void {
			var i:int;
			for (i = 0; i < dataPoints.length; i++) {
				dataPoints[i].updateValuesExitFrame();
			}
		}

		protected function updateChart(__timeSpentMS:uint):void {
			var i:int;
			for (i = 0; i < dataPoints.length; i++) {
				dataBlocks[i].update(__timeSpentMS);
			}
		}

		protected function stop():void {
			if (isRunning) {
				isRunning = false;

				while (dataBlocks.length > 0) {
					dataBlocks[0].dispose();
					removeChild(dataBlocks[0]);
					dataBlocks.splice(0, 1);
				}

				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				removeEventListener(MouseEvent.CLICK, onClick);
				removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				removeEventListener(MouseEvent.ROLL_OUT, onRollOut);

			}
		}

		protected function nextInfoStage():void {
			infoStage = (infoStage + 1) % NUM_INFO_STAGES;
			setInfoFieldText();
		}


		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void {
			 start();
		}

		protected function onRemovedFromStage(e:Event):void {
			 stop();
		}

		protected function onEnterFrame(e:Event):void {
			var now:uint = getTimerUInt();
			var timeSpentMS:uint = now - lastUpdateTime;
			if (timeSpentMS >= _timeInterval) {
				updateChart(timeSpentMS);

				for (var i:int = 0; i < dataPoints.length; i++) {
					dataPoints[i].reset();
				}

				lastUpdateTime = now;
			}

			updateBeforeFrame();
		}

		protected function onExitFrame(e:Event):void {
			updateAfterFrame();
		}

		protected function onClick(e:MouseEvent):void {
			nextInfoStage();
			System.gc();
		}

		protected function onRollOver(e:MouseEvent):void {
			infoField.visible = true;
		}

		protected function onRollOut(e:MouseEvent):void {
			infoField.visible = false;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function addDataPoint(__dataPoint:CustomDataPoint):void {
			var wasRunning:Boolean = isRunning;

			if (wasRunning) stop();
			dataPoints.push(__dataPoint);
			if (wasRunning) start();
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _blockWidth;
		}
		override public function set width(__value:Number):void {
			if (_blockWidth != __value) {
				_blockWidth = __value;
				if (isRunning) {
					stop();
					start();
				}
			}
		}

		override public function get height():Number {
			return _blockHeight * dataPoints.length;
		}
		override public function set height(__value:Number):void {
			if (_blockHeight != __value) {
				_blockHeight = Math.round(__value / dataPoints.length);
				if (isRunning) {
					stop();
					start();
				}
			}
		}
	}
}
