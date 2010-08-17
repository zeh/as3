package com.zehfernando.display.debug {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	/**
	 * @author Zeh
	 */
	public class StatGraph extends Sprite {

		// Constants
		protected static const DEFAULT_TIME_INTERVAL:Number = 250;
		protected static const DEFAULT_WIDTH:Number = 210;
		protected static const DEFAULT_HEIGHT:Number = 60;
		
		protected static const COLOR_FPS:Number = 0xff2200;
		protected static const COLOR_MS:Number = 0x44cc00;
		protected static const COLOR_MEMORY:Number = 0x0066ff;
		
		protected static const NUM_INFO_STAGES:Number = 7;
		
		// Properties
		protected var isRunning:Boolean;
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _timeInterval:Number;
		
		protected var lastUpdateTime:Number;
		
		protected var framesExecuted:Number;
		protected var memoryTotal:Number;
		protected var memoryTotalEntries:Number;

		protected var infoStage:int;
		
		// Instances
		protected var graphBitmapData:BitmapData;
		protected var graphBitmap:Bitmap;
		
		protected var fpsField:TextField;
		protected var msField:TextField;
		protected var memoryField:TextField;
		
		protected var infoField:TextField;
		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StatGraph(__width:Number = NaN, __height:Number = NaN) {
			// Set default data
			_width = isNaN(__width) ? DEFAULT_WIDTH : __width;
			_height = isNaN(__height) ? DEFAULT_HEIGHT : __height;
			_timeInterval = DEFAULT_TIME_INTERVAL;

			isRunning = false;
			
			mouseChildren = false;
			
			// Setup events
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			alpha = 0.75;
			infoStage = 0;
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------
		
		protected function start(): void {
			if (!isRunning) {
				isRunning = true;
				
				graphBitmapData = new BitmapData(Math.round(_width), Math.round(_height), false, 0x000000);
				
				graphBitmap = new Bitmap(graphBitmapData);
				addChild(graphBitmap);
				
				var fmt:TextFormat = new TextFormat("_sans", 10, 0xffffff);

				fpsField = new TextField();
				fpsField.defaultTextFormat = fmt;
				fpsField.selectable = false;
				fpsField.autoSize = TextFieldAutoSize.LEFT;
				addChild(fpsField);

				msField = new TextField();
				msField.defaultTextFormat = fmt;
				msField.selectable = false;
				msField.autoSize = TextFieldAutoSize.LEFT;
				addChild(msField);

				memoryField = new TextField();
				memoryField.defaultTextFormat = fmt;
				memoryField.selectable = false;
				memoryField.autoSize = TextFieldAutoSize.LEFT;
				addChild(memoryField);
				
				infoField = new TextField();
				infoField.defaultTextFormat = fmt;
				infoField.selectable = false;
				infoField.autoSize = TextFieldAutoSize.NONE;
				addChild(infoField);
				
				//Capabilities.cpuArchitecture;
				infoField.x = 50;
				infoField.y = 1;
				infoField.width = _width - infoField.x;
				infoField.height = _height - infoField.y;
				infoField.alpha = 0.5;
				infoField.visible = false;
				setInfoFieldText();
				
				resetData();
				update(true);

				addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
				addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
				addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
				addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
				
			}
		}
		
		protected function setInfoFieldText(): void {

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
		
		protected function update(__forceRender:Boolean = false): void {
			var now:Number = getTimer();
			
			// Add values to totals
			framesExecuted++;
			
			//msTotal += now - lastUpdateTime;
			//msTotalEntries++;
			
			memoryTotal += System.totalMemory;
			memoryTotalEntries++;
			
			var timeSpent:Number = now - lastUpdateTime;
			if (timeSpent >= _timeInterval || __forceRender) {
				// Final, can update
				updateGraphic(timeSpent);
			}

			// Reset if starting anew or if just updated
			if (timeSpent >= _timeInterval) resetData();
			
		}
		
		protected function resetData(): void {
			framesExecuted = 0;
			memoryTotal = 0;
			memoryTotalEntries = 0;

			lastUpdateTime = getTimer();
		}
		
		protected function stop(): void {
			if (isRunning) {
				isRunning = false;
				
				removeChild(graphBitmap);
				graphBitmap = null;
				
				graphBitmapData.dispose();
				graphBitmapData = null;
				
				lastUpdateTime = NaN;
				
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				removeEventListener(MouseEvent.CLICK, onClick);
				removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
				removeEventListener(MouseEvent.ROLL_OUT, onRollOut);

				removeChild(fpsField);
				fpsField = null;

				removeChild(msField);
				msField = null;

				removeChild(memoryField);
				memoryField = null;
			}
		}

		protected function updateGraphic(__timeSpent:Number): void {
			graphBitmapData.lock();
			
			// Scroll bitmap to the side
			graphBitmapData.copyPixels(graphBitmapData, new Rectangle(1, 0, graphBitmapData.width - 1, graphBitmapData.height), new Point(0, 0));
			graphBitmapData.fillRect(new Rectangle(graphBitmapData.width-1, 0, 1, graphBitmapData.height), 0x000000); // TODO: set some background color?
			
			var numGraphs:int = 3;
			var pyMax:Number;
			var pyMin:Number;

			// Framerate line
			var numFPS:Number = __timeSpent > 0 ? framesExecuted / (__timeSpent / 1000) : 0;
			pyMax = 0;
			pyMin = Math.round(1 * (_height / numGraphs)) - 1;
			addGraphicLine(numFPS / stage.frameRate, pyMin, pyMax, COLOR_FPS);
			
			fpsField.text = Math.round(numFPS)+"FPS";
			fpsField.x = 2;
			fpsField.y = pyMin - fpsField.height;
			
			// Frame time line
			var numMS:Number = __timeSpent/framesExecuted;
			pyMax = Math.round(1 * (_height / numGraphs));
			pyMin = Math.round(2 * (_height / numGraphs)) - 1;
			addGraphicLine(numMS/1000, pyMin, pyMax, COLOR_MS);

			msField.text = Math.round(numMS)+"MS/F";
			msField.x = 2;
			msField.y = pyMin - fpsField.height;
			
			// Memory use line
			var numMemory:Number = (memoryTotal/memoryTotalEntries);
			pyMax = Math.round(2 * (_height / numGraphs));
			pyMin = Math.round(3 * (_height / numGraphs)) - 1;
			addGraphicLine(numMemory/(1024*1024*100), pyMin, pyMax, COLOR_MEMORY); // 107374182400 = 100mb// 214748364800

			memoryField.text = (Math.round((numMemory/1024/1024)*10)/10)+"MB";
			memoryField.x = 2;
			memoryField.y = pyMin - fpsField.height;
			
			graphBitmapData.unlock();
		}

		protected function addGraphicLine(__val:Number, __minY:int, __maxY:int, __color:Number): void {
			var py:Number = Math.round(__minY + __val * (__maxY - __minY));
			graphBitmapData.fillRect(new Rectangle(_width-1, __maxY, 1, __minY-__maxY+1), colorAsBackground(__color));
			graphBitmapData.fillRect(new Rectangle(_width-1, py, 1, 1), __color);
		}
		
		protected function colorAsBackground(__color:Number): Number {
			var a:Number = 0.1;
			var r:Number = __color >> 16 & 0xff * a;
			var g:Number = __color >> 8 & 0xff * a;
			var b:Number = __color & 0xff * a;
			return r << 16 | g << 8 | b;
		}
		
		protected function nextInfoStage(): void {
			infoStage = (infoStage + 1) % NUM_INFO_STAGES;
			setInfoFieldText();
		}

		
		// ================================================================================================================
		// EVENT functions ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event): void {
			 start();
		}

		protected function onRemovedFromStage(e:Event): void {
			 stop();
		}
		
		protected function onEnterFrame(e:Event): void {
			update();
		}
		
		protected function onClick(e:MouseEvent): void {
			nextInfoStage();
			System.gc();
		}

		protected function onRollOver(e:MouseEvent): void {
			infoField.visible = true;
		}

		protected function onRollOut(e:MouseEvent): void {
			infoField.visible = false;
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		override public function get width(): Number {
			return _width;
		}
		override public function set width(__value:Number): void {
			if (_width != __value) {
				_width = __value;
				if (isRunning) {
					stop();
					start();
				}
			}
		}

		override public function get height(): Number {
			return _height;
		}
		override public function set height(__value:Number): void {
			if (_height != __value) {
				_height = __value;
				if (isRunning) {
					stop();
					start();
				}
			}
		}
	}
}
