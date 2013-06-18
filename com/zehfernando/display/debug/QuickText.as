package com.zehfernando.display.debug {

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author zeh
	 */
	public class QuickText extends Sprite {

		// Properties
		protected var _autoSize:Boolean;

		// Instances
		protected var textField:TextField;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function QuickText(__text:String, __size:Number = 10, __color:Number = 0x000000, __x:Number = 0, __y:Number = 0, __width:Number = NaN) {

			// Create assets
			var fmt:TextFormat = new TextFormat("_sans", __size, __color);
			fmt.align = TextFormatAlign.LEFT;

			textField = new TextField();
			textField.selectable = false;
			textField.embedFonts = false;
			//textField.antiAliasType = AntiAliasType.ADVANCED;
			textField.defaultTextFormat = fmt;
			textField.multiline = true;
			textField.wordWrap = true;
			textField.setTextFormat(fmt);
			textField.text = "";
			addChild(textField);

			textField.borderColor = 0x000000;

			x = __x;
			y = __y;

			autoSize = true;

			if (!isNaN(__width)) width = __width;

			text = __text;
			editable = false;

			textField.x = 0;// This shouldn't be needed...
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return textField.width;
		}
		override public function set width(__value:Number):void {
			if (_autoSize) {
				autoSize = false;
			}
			textField.width = __value;
		}

		override public function get height():Number {
			return textField.height;
		}
		override public function set height(__value:Number):void {
			textField.height = __value;
		}

		public function get text():String {
			return textField.text;
		}
		public function set text(__value:String):void {
			textField.text = __value;
		}

		public function get selectable():Boolean {
			return textField.selectable;
		}
		public function set selectable(__value:Boolean):void {
			textField.selectable = __value;
		}

		public function get editable():Boolean {
			return textField.type == TextFieldType.INPUT;
		}

		public function set editable(__value : Boolean):void {
			textField.type = __value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			if (editable) textField.selectable = true;
		}


		public function get border():Boolean {
			return textField.border;

		}
		public function set border(__value:Boolean):void {
			textField.border = __value;
		}

		public function get scrollV():int {
			return textField.scrollV;
		}
		public function set scrollV(__value:int):void {
			textField.scrollV = __value;
		}

		public function get maxScrollV():int {
			return textField.maxScrollV;
		}

		public function get autoSize():Boolean {
			return _autoSize;
		}
		public function set autoSize(__value:Boolean):void {
			if (_autoSize != __value) {
				textField.autoSize = __value ? TextFieldAutoSize.LEFT : textField.autoSize = TextFieldAutoSize.NONE;
			}
		}
	}
}
