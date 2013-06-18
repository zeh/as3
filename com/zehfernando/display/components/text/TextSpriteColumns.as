package com.zehfernando.display.components.text {
	import flash.display.Sprite;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineCreationResult;

	/**
	 * @author zeh
	 */
	public class TextSpriteColumns extends Sprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;
		protected var _text:String;

		protected var _columnWidth:Number;
		protected var _margins:Number;
		protected var _maxHeight:Number;
		protected var _maxColumns:int;

		protected var _leading:Number;
		protected var _tracking:Number;

		protected var _font:String;
		protected var _size:Number;
		protected var _color:Number;

		protected var _columns:int;

		protected var textSprites:Vector.<RichTextSprite>;
		protected var baseTextSprite:RichTextSprite;			// Used for the styles

		// Instances
		protected var textContainer:Sprite;

		/*
		Changelog
		2010 02 06 -- Changed to use the new Text Engine, be aligned to the top left

		// http://www.insideria.com/2009/03/flash-text-engine.html
		*/

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TextSpriteColumns(__font:String = "_sans", __size:Number = 12, __color:Number = 0x000000, __columnWidth:Number = 100, __margins:Number = 10, __maxHeight:Number = 100, __maxColumns:int = 1000) {
			// TODO: add bold, italic (fontPosture)

			// Set default values
			_height = 0;
			_text = "";
			_columnWidth = __columnWidth;
			_margins = __margins;
			_maxColumns = __maxColumns;

			_maxHeight = __maxHeight;

			_leading = 0;
			_tracking = 0;

			_columns = 0;

			_font = __font;
			_size = __size;
			_color = __color;

			baseTextSprite = new RichTextSprite();
			textSprites = new Vector.<RichTextSprite>();

			// Create visual assets
			textContainer = new Sprite();
			addChild(textContainer);

			// Finally, redraws everything
			redraw();
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected function redraw():void {
			// Redraws everything
			removeAllColumns();

			// Create all columns
			var ts:RichTextSprite;
			var lastLine:TextLine = null;
			var posX:Number = 0;

			_columns = 0;

			//trace ("---creating");

			while((_columns == 0 || Boolean(lastLine)) && _columns <= _maxColumns && !(Boolean(ts) && ts.textLineCreationResult == TextLineCreationResult.COMPLETE)) {

				//trace ("  -- column " + _columns);

				// Breaks text if it's already past the maximum
				// TODO: test this better or find some other way to detect it
				//if (Boolean(lastLine) && lastLine.textBlockBeginIndex + lastLine.atomCount >= getTagLessText().length) break; // This sucks -- use a better method to detect whether there's additional lines
				//if (Boolean(lastLine) && lastLine.textBlockBeginIndex + lastLine.atomCount >= _text.length) break;

				//trace ("col " + _numColumns, lastLine, getTagLessText().length, Boolean(lastLine) ? lastLine.textBlockBeginIndex + lastLine.atomCount : "");

				//if (Boolean(lastLine)) trace ("  --> ",lastLine, lastLine.textBlockBeginIndex, lastLine.atomCount, getTagLessText().length);
				//if (Boolean(ts)) trace("  ---> " + ts.textLineCreationResult);

				ts = new RichTextSprite(_font, _size, _color);
				ts.trimFirstLineIfBlank = _columns > 0;
				ts.setTextStyles(baseTextSprite.getTextStyles());
				ts.x = posX;
				ts.maxHeight = _maxHeight;
				ts.width = _columnWidth;
				ts.leading = _leading;

				if (_columns == 0) {
					ts.tracking = _tracking;
					ts.text = _text;
				}

				ts.previousTextLine = lastLine;
				lastLine = ts.lastTextLine;
				textContainer.addChild(ts);

				textSprites.push(ts);

				posX += _columnWidth;
				posX += _margins;

				_columns++;
			}

			//trace ("numColumns =================== " + _numColumns);

			_width = _columns > 0 ? posX - _margins : 0;
		}

//		protected function getTagLessText():String {
//			// This sucks
//			var txt:String = _text;
//			var tag:String;
//			for (var i:int = 0; i < baseTextSprite.getTextStyles().length; i++) {
//				tag = baseTextSprite.getTextStyles()[i].name;
//				txt = txt.split("<"+tag+">").join("");
//				txt = txt.split("<"+tag+"/>").join("");
//			}
//
//			return txt;
//		}

		protected function removeAllColumns():void {
			while (Boolean(textSprites) && textSprites.length > 0) {
				textContainer.removeChild(textSprites[0]);
				textSprites.splice(0, 1);
			}
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setStyle(__name:String, __fontName:String = "", __fontSize:Number = NaN, __color:Number = NaN):void {
			baseTextSprite.setStyle(__name, __fontName, __fontSize, __color);
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			throw new Error("You cannot set the width of a TextSpriteColumns instance");
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			throw new Error ("Warning: you cannot set the height of a TextSpriteColumns instance.");
		}

		public function get text():String {
			return _text;
		}
		public function set text(__value:String):void {
			if (_text != __value) {
				_text = __value;
				redraw();
				//if (textSprites.length > 0) textSprites[0].text = _text;
			}
		}

		public function get leading():Number {
			return _leading;
		}
		public function set leading(__value:Number):void {
			if (_leading != __value) {
				_leading = __value;
				redraw();
			}
		}


//		// FontDescription extensions
//
//		public function get renderingMode():String {
//			return fontDescription.renderingMode;
//		}
//		public function set renderingMode(__value:String):void {
//			if (renderingMode != __value) {
//				fontDescription.renderingMode = __value;
//				redraw();
//			}
//		}
//
//		public function get cffHinting():String {
//			return fontDescription.cffHinting;
//		}
//		public function set cffHinting(__value:String):void {
//			if (cffHinting != __value) {
//				fontDescription.cffHinting = __value;
//				redraw();
//			}
//		}

		// This doesn't work, or maybe depends on specific font features
		public function get tracking():Number {
			return _tracking;
		}
		public function set tracking(__value:Number):void {
			if (_tracking != __value) {
				_tracking = __value;
				redraw();
				//if (textSprites.length > 0) textSprites[0].tracking = __value;
			}
		}

		public function get trackingAsPhotoshop():Number {
			return _tracking / _size * 1000;
		}
		public function set trackingAsPhotoshop(__value:Number):void {
			tracking = __value / 1000 * _size;
		}

		public function get leadingAsPhotoshop():Number {
			return _size + _leading;
		}
		public function set leadingAsPhotoshop(__value:Number):void {
			leading = __value - _size;
		}

		public function get columnWidth():Number {
			return _columnWidth;
		}
		public function set columnWidth(__value:Number):void {
			if (_columnWidth != __value) {
				_columnWidth = __value;
				redraw();
			}
		}

		public function get margins():Number {
			return _margins;
		}
		public function set margins(__value:Number):void {
			if (_margins != __value) {
				_margins = __value;
			}
		}

		public function get columns():Number {
			return _columns;
		}

		public function get maxHeight():Number {
			return _maxHeight;
		}
		public function set maxHeight(__value:Number):void {
			if (_maxHeight != __value) {
				_maxHeight = __value;
				redraw();
			}
		}
	}
}