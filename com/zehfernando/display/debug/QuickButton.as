package com.zehfernando.display.debug {
	import com.zehfernando.display.shapes.RoundedBox;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author zeh
	 */
	public class QuickButton extends Sprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;
		protected var _text:String;

		// Instances
		protected var background:RoundedBox;
		protected var textField:TextField;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function QuickButton(__text:String = "CLICK", __x:Number = 0, __y:Number = 0, __onClick:Function = null, __width:Number = 70, __height:Number = 20) {
			x = __x;
			y = __y;
			_width = __width;
			_height = __height;
			_text = __text;

			background = new RoundedBox(100, 100, 0x3b856e, 4);
			background.superEllipseCorners = true;
			addChild(background);

			textField = new TextField();
			textField.wordWrap = true;
			textField.selectable = false;
			textField.embedFonts = false;
			addChild(textField);

			var fmt:TextFormat = new TextFormat();
			fmt.font = "_sans";
			fmt.bold = true;
			fmt.size = 12;
			fmt.color = 0xffffff;
			fmt.align = TextFormatAlign.CENTER;
			textField.defaultTextFormat = fmt;

			buttonMode = true;
			mouseChildren = false;

			if (Boolean(__onClick)) addEventListener(MouseEvent.CLICK, __onClick);

			redraw();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		public function redraw():void {
			background.width = _width;
			background.height = _height;

			textField.text = _text;
			textField.x = 0;
			textField.width = _width;
			textField.height = textField.textHeight + 4;
			textField.y = _height / 2 - textField.height / 2;
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		// TODO: use invalidate
		// The repetitive redraws don't look good but impact in rendering is virtually none

		override public function get width():Number { return _width; }
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				redraw();
			}
		}

		override public function get height():Number { return _height; }
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				redraw();
			}
		}

		public function get text():String { return _text; }
		public function set text(__value:String):void {
			if (_text != __value) {
				_text = __value;
				redraw();
			}
		}


	}
}
