package com.zehfernando.display.components.text {

	import com.zehfernando.utils.MathUtils;

	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	/**
	 * @author zeh
	 */
	public class EditableTextSprite extends TextSprite {

		// Properties
		protected var _hasFocus:Boolean;
		protected var _caretPosition:int;
		protected var _isMouseOver:Boolean;

		// Instances
		protected var caret:Caret;

		protected var undoManager:UndoManager;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function EditableTextSprite(__font:String = "_sans", __size:Number = 12, __color:Number = 0x000000, __alpha:Number = 1) {
			super(__font, __size, __color, __alpha);

			_caretPosition = 0;
			_hasFocus = false;
			_isMouseOver = false;

			undoManager = new UndoManager();
			addUndoState();

			caret = new Caret();
			caret.color = 0xffffff;
			caret.visible = false;
			addChild(caret);

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redraw():void {
			super.redraw();
			if(_hasFocus) redrawCaret();
		}

		protected function showCaret():void {
			caret.visible = true;
			redrawCaret();
		}

		protected function hideCaret():void {
			caret.visible = false;
		}

		protected function redrawCaret():void {
			caret.restartVisibilityCycle();

			_caretPosition = MathUtils.clamp(_caretPosition, 0, getMaximumCaretPosition());

			var caretRect:Rectangle = getCharBounds(_caretPosition);

			caret.x = Math.round(caretRect.x);
			caret.y = Math.round(caretRect.y);
			//caret.width = caretRect.width;
			caret.height = Math.round(caretRect.y + caretRect.height) - caret.y;
		}

		protected function getCharBounds(__charIndex:int): Rectangle {

			var isAtEnd:Boolean = false;
			var isEmpty:Boolean = false;

			__charIndex = MathUtils.clamp(_caretPosition, 0, getMaximumCaretPosition());
			if (__charIndex >= text.length) {
				isAtEnd = true;
				__charIndex--;
			}

			if (__charIndex < 0) {
				isEmpty = true;
				isAtEnd = false;
				__charIndex = 0;
			}

			var caretLine:TextLine = isEmpty ? textBlock.firstLine : textBlock.getTextLineAtCharIndex(__charIndex);

			var caretRect:Rectangle = caretLine.getAtomBounds(__charIndex-caretLine.getAtomTextBlockBeginIndex(0));

			var rect:Rectangle = new Rectangle();
			rect.x = caretLine.x + caretRect.x + (isAtEnd ? caretRect.width : 0);
			rect.y = caretLine.y + caretRect.y;
			rect.width = caretRect.width;
			rect.height = caretRect.height;

			return rect;
		}

		protected function insertText(__text:String, __moveCaret:Boolean = true, __position:int = -1):void {
			addUndoState();

			if (__position == -1) __position = _caretPosition;
			// TODO: only update from the current text line and on!
			text = text.substr(0, __position) + __text + text.substr(__position);

			if (__moveCaret) caretPosition = __position + __text.length;

			dispatchEvent(new EditableTextSpriteEvent(EditableTextSpriteEvent.CHANGED));
		}

		protected function removeText(__position:int, __length:int, __moveCaret:Boolean = true):void {
			addUndoState();

			var remStart:int = Math.max(__position, 0);
			var remEnd:int = Math.max(__position + __length, 0);

			remStart = Math.min(remStart, getMaximumCaretPosition());
			remEnd = Math.min(remEnd, getMaximumCaretPosition());

			text = text.substr(0, remStart) + text.substr(remEnd);

			if (__moveCaret) caretPosition = remStart;

			dispatchEvent(new EditableTextSpriteEvent(EditableTextSpriteEvent.CHANGED));
		}

		protected function getMaximumCaretPosition():int {
			return text.length;
		}

		protected function addUndoState():void {
			undoManager.saveState({text:text, caretPosition:caretPosition});
		}

		protected function undo():void {
			if (undoManager.prevState()) {
				var obj:Object = undoManager.getState();
				trace ("OK= "+obj["text"]);
				text = obj["text"];
				caretPosition = obj["caretPosition"];
			}
		}

		protected function redo():void {
			if (undoManager.nextState()) {
				var obj:Object = undoManager.getState();
				trace ("OK= "+obj["text"]);
				text = obj["text"];
				caretPosition = obj["caretPosition"];
			}
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void {
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}

		protected function onRemovedFromStage(e:Event):void {
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			removeEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			removeEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

			undoManager.clear();
			unfocus();
		}

		protected function onMouseOver(e:MouseEvent):void {
			Mouse.cursor = MouseCursor.IBEAM;
			_isMouseOver = true;
		}

		protected function onMouseOut(e:MouseEvent):void {
			_isMouseOver = false;
			Mouse.cursor = MouseCursor.AUTO;
		}

		protected function onMouseDown(e:MouseEvent):void {
			// TODO: caret position must be determined by ROUNDED position, not char position!
			caretPosition = getCharAtMousePosition();
			focus();
		}

		protected function onMouseDownStage(e:MouseEvent):void {
			if (!_isMouseOver) unfocus();
			//trace (stage.getObjectsUnderPoint(new Point(stage.mouseX, stage.mouseY)));
			//unfocus();
		}

		protected function onSpecialKeyboardEvent(e:Event):void {
			switch (e.type) {
				case Event.COPY:
					break;
				case Event.CLEAR:
					break;
				case Event.CUT:
					break;
				case Event.PASTE:
					break;
				case Event.SELECT_ALL:
					break;
			}
		}

		protected function onKeyDown(e:KeyboardEvent):void {
			if (e.ctrlKey && !e.altKey) {
				// CTRL
				switch (String.fromCharCode(e.charCode)) {
					case "z":
					case "Z":
						undo();
						break;
					case "y":
					case "Y":
						redo();
						break;
					default:
						//trace ("CTRL+SOMETHING = " +String.fromCharCode(e.charCode));
						//insertText(String.fromCharCode(e.charCode));
						break;
				}
			} else if (e.ctrlKey && e.altKey) {
				// CTRL + ALT
			} else if (!e.ctrlKey && e.altKey) {
				// ALT
			} else {
				switch (e.keyCode) {
					case Keyboard.CAPS_LOCK:
					case Keyboard.ESCAPE:
					case Keyboard.F1:
					case Keyboard.F2:
					case Keyboard.F3:
					case Keyboard.F4:
					case Keyboard.F5:
					case Keyboard.F6:
					case Keyboard.F7:
					case Keyboard.F8:
					case Keyboard.F9:
					case Keyboard.F10:
					case Keyboard.F11:
					case Keyboard.F12:
					case Keyboard.F13:
					case Keyboard.F14:
					case Keyboard.F15:
					case Keyboard.INSERT:
					case Keyboard.PAGE_DOWN:
					case Keyboard.PAGE_UP:
					case Keyboard.CONTROL:
					case Keyboard.SHIFT:
					case Keyboard.UP:
					case Keyboard.DOWN:
						trace ("EditableTextSprite :: Key action [" + e.keyCode + "] needs to be properly interpreted!");
						break;
					case Keyboard.TAB:
						unfocus();
						break;
					case Keyboard.LEFT:
						caretPosition--;
						break;
					case Keyboard.RIGHT:
						caretPosition++;
						break;
					case Keyboard.HOME:
						caretPosition = 0;
						break;
					case Keyboard.END:
						caretPosition = getMaximumCaretPosition();
						break;
					case Keyboard.DELETE:
						removeText(_caretPosition, 1);
						break;
					case Keyboard.BACKSPACE:
						removeText(_caretPosition-1, 1);
						break;
					default:
						insertText(String.fromCharCode(e.charCode));
				}
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function focus():void {
			if (!_hasFocus) {
				showCaret();

				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage);

				addEventListener(Event.COPY, onSpecialKeyboardEvent);
				addEventListener(Event.CLEAR, onSpecialKeyboardEvent);
				addEventListener(Event.CUT, onSpecialKeyboardEvent);
				addEventListener(Event.PASTE, onSpecialKeyboardEvent);
				addEventListener(Event.SELECT_ALL, onSpecialKeyboardEvent);

				_hasFocus = true;

				dispatchEvent(new EditableTextSpriteEvent(EditableTextSpriteEvent.GOT_FOCUS));
			}
		}

		public function unfocus():void {
			if (_hasFocus) {
				hideCaret();

				stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownStage);

				removeEventListener(Event.COPY, onSpecialKeyboardEvent);
				removeEventListener(Event.CLEAR, onSpecialKeyboardEvent);
				removeEventListener(Event.CUT, onSpecialKeyboardEvent);
				removeEventListener(Event.PASTE, onSpecialKeyboardEvent);
				removeEventListener(Event.SELECT_ALL, onSpecialKeyboardEvent);


				_hasFocus = false;

				dispatchEvent(new EditableTextSpriteEvent(EditableTextSpriteEvent.LOST_FOCUS));
			}
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get caretPosition():int {
			return _caretPosition;
		}
		public function set caretPosition(__value:int):void {
			if (_caretPosition != __value) {
				_caretPosition = __value;
				redrawCaret();
			}
		}

		public function get hasFocus():Boolean {
			return _hasFocus;
		}
	}
}
