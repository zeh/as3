package com.zehfernando.display.debug {
	import com.zehfernando.display.abstracts.ResizableSprite;
	import com.zehfernando.display.components.text.RichTextSprite;
	import com.zehfernando.display.components.text.legacy.EditableTextFieldSprite;
	import com.zehfernando.display.shapes.Box;
	import com.zehfernando.transitions.Equations;
	import com.zehfernando.transitions.ZTween;
	import com.zehfernando.utils.MathUtils;
	import com.zehfernando.utils.console.Console;
	import com.zehfernando.utils.console.info;

	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.filters.GlowFilter;
	import flash.ui.Keyboard;

	/**
	 * @author zeh fernando
	 */
	public class ConsoleView extends ResizableSprite {

		// Event enums
		public static const EVENT_OPENED:String = "onConsoleOpened";
		public static const EVENT_CLOSED:String = "onConsoleClosed";

		// Constants
		private static const MARGIN_TEXT:Number = 4;
		private static const TIME_OPEN:Number = 0.8;
		private static const TIME_CLOSE:Number = 0.6;

		private static const MAX_LOG_LINES:int = 1000;
		private static const MIN_LOG_LINES:int = 500;

		// Properties
		private var _visibility:Number;
		private var currentScrollLine:int;

		// Instances
		private var boxMask:Box;
		private var container:Sprite;
		private var textField:EditableTextFieldSprite;
		private var textFieldOverlay:RichTextSprite;
		private var background:Box;
		private var border:Box;
		private var backgroundChildrenContainer:Sprite;

		private var logLines:Vector.<String>;

		private var _stage:Stage;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ConsoleView(__overlayMessage:String = "") {
			super();

			_visibility = 1;
			currentScrollLine = 0;

			logLines = new Vector.<String>();

			// Create assets
			backgroundChildrenContainer = new Sprite();
			addChild(backgroundChildrenContainer);

			boxMask = new Box(100, 100);
			addChild(boxMask);

			container = new Sprite();
			container.mask = boxMask;
			addChild(container);

			background = new Box(100, 100, 0x000000);
			background.alpha = 0.9;
			background.cacheAsBitmap = true;
			container.addChild(background);

			textField = new EditableTextFieldSprite("_typewriter", 12, 0xafafaf);
			textField.editable = false;
			textField.wordWrap = true;
			textField.mouseEnabled = textField.mouseChildren = false;
			textField.kerning = false;
			textField.embedFonts = false;
			container.addChild(textField);

			if (__overlayMessage != null && __overlayMessage.length > 0) {
				textFieldOverlay = new RichTextSprite("_typewriter", 20, 0xafffffff);
				textFieldOverlay.embeddedFonts = false;
				textFieldOverlay.text = __overlayMessage;
				textFieldOverlay.filters = [new GlowFilter(0x000000, 1, 8, 8, 10, 1)];
				container.addChild(textFieldOverlay);
			}

			border = new Box(100, 2.5, 0xffffff);
			border.alpha = 0.8;
			container.addChild(border);

			Console.addEventListener(Console.EVENT_LINE_WRITTEN, onLineWritten);

			// Writes all existing lines (pre-console creation)
			var linesWritten:Vector.<String> = Console.linesWritten;
			for (var i:int = 0; i < linesWritten.length; i++) {
				writeLine(Console.linesWritten[i]);
			}

			redrawVisibility();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth():void {
			border.width = _width;
			boxMask.width = _width;
			background.width = _width;
			textField.x = MARGIN_TEXT;
			textField.width = _width - MARGIN_TEXT * 2;
			if (textFieldOverlay != null) textFieldOverlay.x = _width - textFieldOverlay.width - 10;
		}

		override protected function redrawHeight():void {
			border.y = _height - Math.ceil(border.height);
			boxMask.height = _height;
			background.height = _height;
			textField.y = MARGIN_TEXT;
			textField.height = _height - MARGIN_TEXT * 2;
			if (textFieldOverlay != null) textFieldOverlay.y = 10;
		}

		private function redrawVisibility():void {
			container.alpha = 0.5 + _visibility * 0.5;
			visible = _visibility > 0;
			blendMode = _visibility < 1 ? BlendMode.LAYER : BlendMode.NORMAL;
			textField.cacheAsBitmap = _visibility < 1;
			container.y = Math.round((1-_visibility) * -_height);

			backgroundChildrenContainer.alpha = _visibility;
		}

		private function toggleVisibility():void {
			if (_visibility > 0.5) {
				close();
			} else {
				open();
			}
		}

		private function open():void {
			ZTween.remove(this, "visibility");
			ZTween.add(this, {visibility:1}, {time:TIME_OPEN, transition:Equations.quintOut, onComplete:function():void { dispatchEvent(new Event(EVENT_OPENED)); }});
		}

		private function close():void {
			ZTween.remove(this, "visibility");
			ZTween.add(this, {visibility:0}, {time:TIME_CLOSE, transition:Equations.quintOut, onComplete:function():void { dispatchEvent(new Event(EVENT_CLOSED)); }});
		}

		private function scrollLog(__numLines:int):void {
			// Scrolls the log by a number of lines
			currentScrollLine = MathUtils.clamp(currentScrollLine + __numLines, 0,  textField.internalTextField.maxScrollV);
			textField.internalTextField.scrollV = textField.internalTextField.maxScrollV - currentScrollLine;
		}

		private function writeLine(__text:String):void {
			// Write a line to the log
			logLines.push(__text);

			if (logLines.length > MAX_LOG_LINES) {
				// Too many log lines, strip it down
				logLines.splice(0, logLines.length - MIN_LOG_LINES);
				textField.text = logLines.join("\n");

				info("Console text was stripped");
			} else {
				// Can still fit, just add the line
				textField.internalTextField.appendText("\n" + __text);
			}
			if (currentScrollLine == 0) textField.internalTextField.scrollV = textField.internalTextField.maxScrollV;
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		override protected function onAddedToStage(__e:Event):void {
			_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			super.onAddedToStage(__e);
		}

		override protected function onRemovedFromStage(__e:Event):void {
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage = null;
			super.onRemovedFromStage(__e);
		}

		private function onLineWritten(__e:Event):void {
			writeLine(Console.lastLineWritten);
		}

		private function onKeyDown(__e:KeyboardEvent):void {
			if(__e.keyCode == Keyboard.BACKQUOTE) {
				toggleVisibility();
			}

			if (_visibility > 0) {
				if (__e.keyCode == Keyboard.PAGE_DOWN) scrollLog(-3);
				if (__e.keyCode == Keyboard.PAGE_UP) scrollLog(3);
			}
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function addBackgroundChild(__child:Sprite):void {
			// Add something to the background of the console (only visible when the console is visible)
			backgroundChildrenContainer.addChild(__child);
		}

		public function clear():void {
			// Clear the console
			logLines = new Vector.<String>();
			textField.text = "";
			currentScrollLine = 0;
			textField.internalTextField.scrollV = textField.internalTextField.maxScrollV;
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get visibility():Number {
			return _visibility;
		}
		public function set visibility(__value:Number):void {
			if (_visibility != __value) {
				_visibility = __value;
				redrawVisibility();
			}
		}
	}
}
