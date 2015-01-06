package com.zehfernando.display.components.text {
	import com.zehfernando.utils.StringUtils;

	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.engine.CFFHinting;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.GroupElement;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBaseline;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;

	/**
	 * @author Zeh
	 */
	public class TextSprite extends Sprite {

		// Properties
		protected var _blockAlignVertical:String;
		protected var _blockAlignHorizontal:String;
		protected var _align:String;

		protected var _width:Number;
		protected var _height:Number;
		protected var _maxHeight:Number;
		protected var _autoSize:Boolean;
		protected var _text:String;
		protected var _textWidth:Number;

		protected var _lastTextLine:TextLine;
		protected var _previousTextLine:TextLine;

		protected var _leading:Number;
		protected var _tracking:Number;

		protected var _border:Boolean;

		protected var _ascent:Number;
		protected var _descent:Number;
		protected var _baseline:Number;
		protected var _trimFirstLineIfBlank:Boolean;

		// Instances
		protected var textBlock:TextBlock;
		protected var fontDescription:FontDescription;
		protected var elementFormat:ElementFormat;
		protected var textContainer:Sprite;
		protected var textLines:Vector.<TextLine>;

		/*
		Changelog
		2010 02 06 -- Changed to use the new Text Engine, be aligned to the top left

		// http://www.insideria.com/2009/03/flash-text-engine.html
		*/

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function TextSprite(__font:String = "_sans", __size:Number = 12, __color:Number = 0x000000, __alpha:Number = 1, __trackingAsPhotoshop:Number = 0) {
			// TODO: add bold, italic (fontPosture)

			// Set default values
			_blockAlignVertical = TextSpriteAlign.TOP;
			_blockAlignHorizontal = TextSpriteAlign.LEFT;
			_align = TextSpriteAlign.LEFT;

			_width = 0;
			_textWidth = 0;
			_height = 0;
			_autoSize = true;
			_text = "";
			_border = false;

			_trimFirstLineIfBlank = false;

			_maxHeight = NaN;
			_lastTextLine = null;
			_previousTextLine = null;

			_leading = 0;
			_tracking = 0;

			// Create visual assets
			textContainer = new Sprite();
			addChild(textContainer);

			// Create text block properties
			fontDescription = new FontDescription();
			fontDescription.fontName = __font;
			fontDescription.fontLookup = FontLookup.EMBEDDED_CFF; // TODO: set this as .embedded:Boolean ?
			fontDescription.renderingMode = RenderingMode.CFF; // TODO: set this as .highQuality:Boolean ? (if normal, there's no hinting)
			fontDescription.cffHinting = CFFHinting.HORIZONTAL_STEM; // TODO: set this as .optimizedForAnimation:Boolean or hinting:Boolean? (if normal, apparently there's no change?)

			//fontDescription.renderingMode = RenderingMode.NORMAL;
			//fontDescription.cffHinting = CFFHinting.NONE;

			elementFormat = new ElementFormat();
			//elementFormat.fontDescription = fontDescription;
			elementFormat.fontSize = __size;
			elementFormat.color = __color;
			elementFormat.alpha = __alpha;
			_tracking = __trackingAsPhotoshop / 1000 * __size;

			applyElementFormatTracking();

			textBlock = new TextBlock();
			textBlock.baselineZero = TextBaseline.IDEOGRAPHIC_TOP;

			// Finally, redraws everything
			redraw();
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected function applyElementFormatTracking():void {
			// Based on tracking (letter spacing), applies that to the elementFormat instance
			elementFormat.trackingLeft = _tracking/2;
			elementFormat.trackingRight = _tracking/2;
		}

		protected function getTextElement(__text:String): ContentElement {
			// Creates a ContentElement for text rendering based on the given text
			var fd:FontDescription = fontDescription.clone();
			var ef:ElementFormat = elementFormat.clone();
			ef.fontDescription = fd;
			return new TextElement(__text, ef);
		}

		protected function getCharAtMousePosition():int {
			if (!Boolean(stage)) return -1;
			return getCharAtPosition(stage.mouseX, stage.mouseY);
		}

		protected function getCharAtPosition(__stageX:Number, __stageY:Number):int {
			var p:Point = new Point(__stageX, __stageY);
			var lastLine:TextLine = textBlock.firstLine;
			var pos:int = -1;
			while (Boolean(lastLine)) {
				pos = lastLine.getAtomIndexAtPoint(p.x, p.y);
				if (pos > -1) {
					pos += lastLine.getAtomTextBlockBeginIndex(0);
					break;
				}
				lastLine = lastLine.nextLine;
			}
			return pos;
		}

		protected function getElementAtPos(__element:ContentElement, __pos:int):ContentElement {
			if (__element is GroupElement) {
				return getElementAtPos((__element as GroupElement).getElementAtCharIndex(__pos), __pos);
//				var ge:GroupElement = (__element as GroupElement);
//				for (var i:int = 0; i < ge.elementCount; i++) {
//					trace (i, ge.);
//					//if (ge.getElementAt(i).getElementAtCharIndex(pos)
//				}
			} else {
				return __element;
			}
		}

		protected function redraw():void {
			// Redraw the whole text block

			var i:int;

			// Delete previous lines if needed
			if (Boolean(textLines)) {
				for (i = 0; i < textLines.length; i++) {
					textContainer.removeChild(textLines[i]);
				}
				textLines = null;
			}

			// Create new lines
			textLines = new Vector.<TextLine>();

			textBlock.content = getTextElement(_text);

			var lineWidth:Number = _autoSize ? TextLine.MAX_LINE_WIDTH : _width;
			var textLine:TextLine;
			var previousLine:TextLine = _previousTextLine;
			var posY:Number = 0;
			var maxWidth:Number = 0;
			var lineCount:int = 0;

			_ascent = NaN;
			_descent = NaN;
			_baseline = NaN;

			while (true) {
				// In FP 10.1, this sometimes gives "Exception fault: ArgumentError: Error #2004: One of the parameters is invalid." even if it works on 10.0
				// The error is triggered when you try a .createTextLine on a textBlock using a previousLine from another textBlock
				//textLine = textBlock.createTextLine(previousLine, lineWidth, 0, true);
				if (Boolean(previousLine)) {
					//trace ("----> ", previousLine, previousLine.textBlockBeginIndex, lineWidth);
					textLine = previousLine.textBlock.createTextLine(previousLine, lineWidth, 0, true);

					// Trims the first line if it's blank
					// TODO: make this cleaner...
					while (Boolean(textLine) && textLine.atomCount == 1 && lineCount == 0 && _trimFirstLineIfBlank) {
						textLine = previousLine.textBlock.createTextLine(textLine, lineWidth, 0, true);
					}
					// TODO: use textLine.textLineCreationResult?
				} else {
					textLine = textBlock.createTextLine(null, lineWidth, 0, true);
				}
				if (Boolean(textLine) && (posY <= _maxHeight || isNaN(_maxHeight))) {
					//textLine.x = 0; // Overridden later
					textLine.y = posY;

					posY += textLine.height;

					posY += _leading;

					if (posY <= _maxHeight || isNaN(_maxHeight)) {
						maxWidth = Math.max(maxWidth, textLine.width);

						_lastTextLine = textLine;

						textLines.push(textLine);
						textContainer.addChild(textLine);
						previousLine = textLine;

						//trace ("-- " + textLine.ascent, textLine.descent);
						//trace (textLine.getBaselinePosition(TextBaseline.ROMAN));

						if (isNaN(_baseline)) _baseline = textLine.getBaselinePosition(TextBaseline.ROMAN);
						if (isNaN(_ascent)) _ascent = textLine.ascent;
						_descent = textLine.descent;
					} else {
						textLine = null;
						break;
					}

					// TODO: is this the correct naming?

				} else {
					break;
				}

				lineCount++;
			}

			if (Boolean(textLine)) posY -= _leading;
			// TODO: ERROR! this takes the wrong size as consideration.. _height becomes negative if leading is too low!!

			if (_autoSize) _width = maxWidth;
			_textWidth = maxWidth;
			_height = posY;
			for (i = 0; i < textLines.length; i++) {
				if (_align == TextSpriteAlign.RIGHT) {
					// Aligned right
					textLines[i].x = _width - textLines[i].width;
				} else if (_align == TextSpriteAlign.CENTER) {
					// Aligned center
					// TODO: add option for round position?
					textLines[i].x = _width/2 - textLines[i].width/2;
				} else {
					// Aligned left
					textLines[i].x = 0;
				}
			}

			// Adjust horizontal position of line texts for align


//			var widthOffset:Number = textField.width - textField.textWidth;
//			textField.width = _width + widthOffset;
//			resetTextPosition();

			redrawPosition();
		}

//		protected function removeForwardLines(__line:TextLine):void {
//			if (Boolean(__line)) {
//				if (Boolean(__line.nextLine)) removeForwardLines(__line.nextLine);
//				if (__line.parent) __line.parent.removeChild(__line);
//			}
//		}

		protected function redrawPosition():void {
			// Sets the position of the text based on the current alignment

			// Fix vertical position
			if (_blockAlignVertical == TextSpriteAlign.TOP) {
				// Top
				textContainer.y = 0;
			} else if (_blockAlignVertical == TextSpriteAlign.BOTTOM) {
				// Bottom
				textContainer.y = -_height;
			} else if (_blockAlignVertical == TextSpriteAlign.BASELINE) {
				// Baseline bottom
				throw new Error("align.baseline not implemented yet");
				// TODO: do this!
			} else {
				// Middle
				textContainer.y = -_height/2;
			}

			// Fix horizontal position
			if (_blockAlignHorizontal == TextSpriteAlign.LEFT) {
				// Left
				textContainer.x = 0;
			} else if (_blockAlignHorizontal == TextSpriteAlign.RIGHT) {
				// Right
				textContainer.x = -_width;
			} else {
				// Center
				textContainer.x = -_width/2;
			}

			graphics.clear();
			if (_border) {
				graphics.lineStyle(1, 0x000000, 0.5);
				graphics.drawRect(textContainer.x, textContainer.y, _width, _height);
			}

//			var actualBoundaries:Rectangle = new Rectangle(0, 0, 0, 0);
//			var descentOffset:Number = 0;
//
//			// Read all metrics about the text position
//			if (textField.text.length > 0) {
//				var ty:Number, tx:Number, tw:Number, th:Number;
//				var tmpP:Number;
//				var mts:TextLineMetrics;
//
//				th = 0;
//
//				// Accounts for variable X - not sure if this ever happens, test with right/center alignment
//				for (var i:int = 0; i < textField.numLines; i++) {
//					mts = textField.getLineMetrics(i);
//
//					// Left
//					tmpP = mts.x;
//					if (isNaN(tx) || tmpP < tx) tx = tmpP;
//
//					// Width
//					tmpP = mts.width + mts.x;
//					if (isNaN(tw) || tmpP > tw) tw = tmpP;
//
//					// Height
//					th += mts.height;
//				}
//
//				// Descent
//				descentOffset = textField.getLineMetrics(textField.numLines - 1).descent;
//
//				var firstChar:Rectangle = textField.getCharBoundaries(0);
//				if (Boolean(firstChar)) {
//					ty = firstChar.y;
//				} else {
//					ty = 0;
//				}
//
//				th = textField.textHeight; // UGH // TODO: fix this?
//
//				actualBoundaries.x = tx;
//				actualBoundaries.y = ty;
//				actualBoundaries.width = tw - tx;
//				actualBoundaries.height = th;
//			}
//
//			// Finally, set all positions
//
//			// Fix vertical position
//			if (_blockAlignVertical == TextSpriteAlign.TOP) {
//				// Top
//				textField.y = -actualBoundaries.y;
//			} else if (_blockAlignVertical == TextSpriteAlign.BOTTOM) {
//				// Bottom
//				textField.y = -actualBoundaries.y - actualBoundaries.height;
//			} else if (_blockAlignVertical == TextSpriteAlign.BASELINE) {
//				// Baseline bottom
//				textField.y = -actualBoundaries.y - actualBoundaries.height + descentOffset;
//			} else {
//				// Middle
//				textField.y = -actualBoundaries.y - actualBoundaries.height/2;
//			}
//
//			// Fix horizontal position
//			if (_blockAlignHorizontal == TextSpriteAlign.LEFT) {
//				// Left
//				textField.x = -actualBoundaries.x;
//			} else if (_blockAlignHorizontal == TextSpriteAlign.RIGHT) {
//				// Right
//				textField.x = -actualBoundaries.x - actualBoundaries.width;
//			} else {
//				// Center
//				textField.x = -actualBoundaries.x - actualBoundaries.width/2;
//			}
//
//			_width = actualBoundaries.width;
//			_height = actualBoundaries.height;

			//if (_height != textField.textHeight && !_autoSize && textField.textHeight > textField.height) {
				// Temporary workaround for when a textfield with auto size fails to take the actual height of the text
				//textField.height = _height + 20;
				//trace ("RESET!");
			//}

			//trace ("h = " + _height + ",  tf.h = " + textField.height + ", tf.th = " + textField.textHeight);
		}


//		protected function setTextFormatProperties(__props:Object):void {
//			// Set properties of the textfield's text format
//			// TODO: set selectively, so it won't overwrite anything?
//			var fmt:TextFormat = textField.getTextFormat();
//			for (var i:String in __props) {
//				fmt[i] = __props[i];
//			}
//			textField.defaultTextFormat = fmt;
//			textField.setTextFormat(fmt);
//			resetTextPosition();
//		}

		// ================================================================================================================
		// PUBLIC functions -----------------------------------------------------------------------------------------------

		// Textfield extensions
//		public function getTextFormat(beginIndex:int = -1, endIndex:int = -1): TextFormat {
//			return textField.getTextFormat(beginIndex, endIndex);
//		}
//
//		public function setTextFormat(format:TextFormat, beginIndex:int = -1, endIndex:int = -1):void {
//			textField.setTextFormat(format, beginIndex, endIndex);
//		}

		public function setTrackingForWidth(__desiredWidth:Number, __offset:Number = 100, __reset:Boolean = true):void {
			// Try to adjust the textfield until the desired width is achieved

			if (__reset) tracking = 0;

			//log ("Trying to achieve width of " + __desiredWidth + " with tracking " + __offset + ", current is " + width);
			var subtracting:Boolean = __desiredWidth < width;

			while (((subtracting && width > __desiredWidth) || (!subtracting && width < __desiredWidth)) && trackingAsPhotoshop >- 1000 && trackingAsPhotoshop < 3000) {
				trackingAsPhotoshop += __offset * (subtracting ? -1 : 1);
			}

			if (Math.abs(__offset) > 1) {
				setTrackingForWidth(__desiredWidth, __offset / 2, false);
			}
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get blockAlignVertical():String {
			return _blockAlignVertical;
		}
		public function set blockAlignVertical(__value:String):void {
			if (_blockAlignVertical != __value) {
				_blockAlignVertical = __value;
				redrawPosition();
			}
		}

		public function get blockAlignHorizontal():String {
			return _blockAlignHorizontal;
		}
		public function set blockAlignHorizontal(__value:String):void {
			if (_blockAlignHorizontal != __value) {
				_blockAlignHorizontal = __value;
				redrawPosition();
			}
		}

		public function get autoSize():Boolean {
			return _autoSize;
		}
		public function set autoSize(__value:Boolean):void {
			if (_autoSize != __value) {
				_autoSize = __value;
				redraw();
			}
		}

		public function get align():String {
			return _align;
		}
		public function set align(__value:String):void {
			if (_align != __value) {
				_align = __value;
				redraw();
			}
		}

		override public function get width():Number {
			return _width * scaleX;
		}
		override public function set width(__value:Number):void {
			if (_width != __value || _autoSize) {
				_width = __value;
				_autoSize = false;
				redraw();
			}
		}

		public function get textWidth():Number {
			return _textWidth * scaleX;
		}

		override public function get height():Number {
			return _height * scaleY;
		}
		override public function set height(__value:Number):void {
			throw new Error ("Warning: you cannot set the height of a TextSprite instance.");
		}

		// Textfield extensions
//		public function get antiAliasType():String {
//			return textField.antiAliasType;
//		}
//		public function set antiAliasType(__value:String):void {
//			textField.antiAliasType = __value;
//		}
//
//		public function get border():Boolean {
//			return textField.border;
//		}
//		public function set border(__value:Boolean):void {
//			textField.border = __value;
//		}
//
//		public function get sharpness():Number {
//			return textField.sharpness;
//		}
//		public function set sharpness(__value:Number):void {
//			textField.sharpness = __value;
//		}
//
//		public function get thickness():Number {
//			return textField.thickness;
//		}
//		public function set thickness(__value:Number):void {
//			textField.thickness = __value;
//		}

		public function get text():String {
			return _text;
		}
		public function set text(__value:String):void {
			if (_text != __value) {
				_text = StringUtils.getCleanString(__value);
				redraw();
			}
		}

		public function get border():Boolean {
			return _border;
		}
		public function set border(__value:Boolean):void {
			if (_border != __value) {
				_border = __value;
				redraw();
			}
		}

		public function get ascent():Number {
			return _ascent;
		}

		public function get descent():Number {
			return _descent;
		}

		public function get baseline():Number {
			return _baseline;
		}

//		public function get htmlText():String {
//			return textField.htmlText;
//		}
//		public function set htmlText(__value:String):void {
//			textField.htmlText = __value;
//			resetTextPosition();
//		}
//
//		public function get embedFonts():Boolean {
//			return textField.embedFonts;
//		}
//		public function set embedFonts(__value:Boolean):void {
//			textField.embedFonts = __value;
//			resetTextPosition();
//		}
//
//		public function get styleSheet(): StyleSheet {
//			return textField.styleSheet;
//		}
//		public function set styleSheet(__value:StyleSheet):void {
//			textField.styleSheet = __value;
//			resetTextPosition();
//		}
//
//		public function get multiline():Boolean {
//			return textField.wordWrap;
//		}
//		public function set multiline(__value:Boolean):void {
//			textField.wordWrap = textField.multiline = __value;
//			resetTextPosition();
//		}


		// Textfield format extensions
//		public function get font():String {
//			return textField.getTextFormat().font;
//		}
//		public function set font(__value:String):void {
//			setTextFormatProperties({font:__value});
//		}
//
//		public function get size():Number {
//			return textField.getTextFormat().size == null ? 12 : (textField.getTextFormat().size as Number);
//		}
//		public function set size(__value:Number):void {
//		}
//			setTextFormatProperties({size:__value});
//
//		public function get color():int {
//			return Boolean(textField.getTextFormat().color) ? (textField.getTextFormat().color as int) : 0;
//		}
//		public function set color(__value:int):void {
//			setTextFormatProperties({font:__value});
//		}
//
//		public function get bold():Boolean {
//			return Boolean(textField.getTextFormat().bold);
//		}
//		public function set bold(__value:Boolean):void {
//			setTextFormatProperties({bold:__value});
//		}
//
//		public function get kerning():Boolean {
//			return Boolean(textField.getTextFormat().kerning);
//		}
//		public function set kerning(__value:Boolean):void {
//			setTextFormatProperties({kerning:__value});
//		}
//
		public function get leading():Number {
			return _leading;
		}
		public function set leading(__value:Number):void {
			if (_leading != __value) {
				_leading = __value;
				redraw();
			}
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

		public function get previousTextLine(): TextLine {
			return _previousTextLine;
		}
		public function set previousTextLine(__value:TextLine):void {
			if (_previousTextLine != __value) {
				_previousTextLine = __value;
				redraw();
			}
		}

		public function get lastTextLine(): TextLine {
			return _lastTextLine;
		}

		// FontDescription extensions

		public function get renderingMode():String {
			return fontDescription.renderingMode;
		}
		public function set renderingMode(__value:String):void {
			if (renderingMode != __value) {
				fontDescription.renderingMode = __value;
				redraw();
			}
		}

		public function get fontName():String {
			return fontDescription.fontName;
		}
		public function set fontName(__value:String):void {
			if (fontName != __value) {
				fontDescription.fontName = __value;
				redraw();
			}
		}

		public function get embeddedFonts():Boolean {
			return fontDescription.fontLookup == FontLookup.EMBEDDED_CFF;
		}
		public function set embeddedFonts(__value:Boolean):void {
			fontDescription.fontLookup = __value ? FontLookup.EMBEDDED_CFF : FontLookup.DEVICE;
			redraw();
		}

		public function get cffHinting():String {
			return fontDescription.cffHinting;
		}
		public function set cffHinting(__value:String):void {
			if (cffHinting != __value) {
				fontDescription.cffHinting = __value;
				redraw();
			}
		}

		// ElementFormat extensions

		// This doesn't work, or maybe depends on specific font features
		public function get digitWidth():String {
			return elementFormat.digitWidth;
		}
		public function set digitWidth(__value:String):void {
			if (digitWidth != __value) {
				elementFormat.digitWidth = __value;
				redraw();
			}
		}

		public function get color():uint {
			return elementFormat.color;
		}
		public function set color(__value:uint):void {
			if (color != __value) {
				elementFormat.color = __value;
				redraw();
			}
		}

		public function get fontSize():Number {
			return elementFormat.fontSize;
		}
		public function set fontSize(__value:Number):void {
			if (fontSize != __value) {
				elementFormat.fontSize = __value;
				redraw();
			}
		}

		// This doesn't work, or maybe depends on specific font features
		public function get tracking():Number {
			return _tracking;
		}
		public function set tracking(__value:Number):void {
			if (_tracking != __value) {
				_tracking = __value;
				// TODO: always re-apply this?
				applyElementFormatTracking();
				redraw();
			}
		}

		private function get trackingAsPhotoshop():Number {
			// -100 ps = -4 f (font size 40)
			// -100 ps = -2 f (font size 20)
			return tracking / elementFormat.fontSize * 1000;
		}
		private function set trackingAsPhotoshop(__value:Number):void {
			// TODO: make it re-apply when font size is changed! otherwise the value is wrong
			tracking = __value / 1000 * elementFormat.fontSize;
		}

		public function get leadingAsPhotoshop():Number {
			// 55 ps = -15 f (font size 70)
			// 32.66 ps = -7.54 f (font size 40)
			return elementFormat.fontSize + leading;
		}
		public function set leadingAsPhotoshop(__value:Number):void {
			// TODO: make it re-apply when font size is changed! otherwise the value is wrong
			leading = __value - elementFormat.fontSize;
		}


		public function get textLineCreationResult():String {
			return (Boolean(_previousTextLine) ? _previousTextLine.textBlock : textBlock).textLineCreationResult;
		}

		public function get trimFirstLineIfBlank():Boolean {
			return _trimFirstLineIfBlank;
		}
		public function set trimFirstLineIfBlank(__value:Boolean):void {
			if (_trimFirstLineIfBlank != __value) {
				_trimFirstLineIfBlank = __value;
				// TODO: better name?
				redraw();
			}
		}
	}
}