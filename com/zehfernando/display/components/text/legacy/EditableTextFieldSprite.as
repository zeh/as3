package com.zehfernando.display.components.text.legacy {

	import com.zehfernando.display.abstracts.ResizableSprite;

	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	/**
	 * @author zeh
	 */
	public class EditableTextFieldSprite extends ResizableSprite {
		
		// Events
		public static const EVENT_GOT_FOCUS:String = "onGotFocus";
		public static const EVENT_CHANGED:String = "onChanged";
		public static const EVENT_LOST_FOCUS:String = "onLostFocus";
		
		// Instances
		protected var textField:TextField;
		protected var textFormat:TextFormat;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function EditableTextFieldSprite(__font:String, __size:Number = 10, __color:int = 0x000000) {
			super();
			
			textField = new TextField();
			textField.type = TextFieldType.INPUT;
			textField.embedFonts = true;
			textField.antiAliasType = AntiAliasType.ADVANCED;
			addChild(textField);
			
			textField.addEventListener(FocusEvent.FOCUS_IN, onGotFocus, false, 0, true);
			textField.addEventListener(FocusEvent.FOCUS_OUT, onLostFocus, false, 0, true);
			textField.addEventListener(Event.CHANGE, onChanged, false, 0, true);
			
			tabEnabled = false;
			
			//textField.border = true;
			
			textFormat = new TextFormat();
			
			font = __font;
			size = __size;
			color = __color;
			
			text = "";
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		override protected function redrawWidth(): void {
			textField.width = _width;
		}

		override protected function redrawHeight(): void {
			textField.height = _height;
		}
		
		protected function applyTextFormat(): void {
			textField.setTextFormat(textFormat);
			textField.defaultTextFormat = textFormat;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onGotFocus(e:FocusEvent): void {
			dispatchEvent(new Event(EVENT_GOT_FOCUS));
		}

		protected function onLostFocus(e:FocusEvent): void {
			dispatchEvent(new Event(EVENT_LOST_FOCUS));
		}
		
		protected function onChanged(e:Event): void {
			dispatchEvent(new Event(EVENT_CHANGED));
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function focus():void {
			if (Boolean(stage)) stage.focus = textField;
		}

//		public function unfocus():void {
//			stage.focus = null;
//		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get font(): String {
			return textFormat.font;
		}
		public function set font(__value:String): void {
			textFormat.font = __value;
			applyTextFormat();
		}

		public function get size(): Number {
			return textFormat.size as Number;
		}
		public function set size(__value:Number): void {
			textFormat.size = __value;
			applyTextFormat();
		}
	
		public function get color(): int {
			return textFormat.color as int;
		}
		public function set color(__value:int): void {
			textFormat.color = __value;
			applyTextFormat();
		}
		
		public function get text(): String {
			return textField.text;
		}

		public function set text(__value:String): void {
			textField.text = __value;
		}
		
		override public function get tabIndex(): int {
			return textField.tabIndex;
		}
		override public function set tabIndex(__value:int): void {
			textField.tabIndex = __value;
		}
		
		public function get wordWrap(): Boolean {
			return textField.wordWrap;
		}
		public function set wordWrap(__value:Boolean): void {
			textField.wordWrap = __value;
		}

		public function get editable(): Boolean {
			return textField.type == TextFieldType.INPUT;
		}
		public function set editable(__value:Boolean): void {
			textField.type = __value ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
		}

		public function get selectable(): Boolean {
			return textField.selectable;
		}
		public function set selectable(__value:Boolean): void {
			textField.selectable = __value;
		}
	}
}
