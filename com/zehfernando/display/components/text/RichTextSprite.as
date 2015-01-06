package com.zehfernando.display.components.text {
	import com.zehfernando.utils.StringUtils;

	import flash.events.MouseEvent;
	import flash.system.System;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextElement;

	/**
	 * @author zeh
	 */
	public class RichTextSprite extends TextSprite {

		// Styles
		protected var styles:Vector.<TextStyle>;
		protected var _currentLinkHref:String;
		protected var _currentLinkTarget:String;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RichTextSprite(__font:String = "_sans", __size:Number = 12, __color:Number = 0x000000, __alpha:Number = 1, __trackingAsPhotoshop = 0) {
			styles = new Vector.<TextStyle>();

			super(__font, __size, __color, __alpha, __trackingAsPhotoshop);

			addEventListener(MouseEvent.ROLL_OVER, onMouseOver, false, 0, true);
			addEventListener(MouseEvent.ROLL_OUT, onMouseOut, false, 0, true);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function getStyle(__name:String = null): TextStyle {
			// TODO: make this faster. Dictionary? TextStyleCollection?
			for (var i:int = 0; i < styles.length; i++) {
				if (styles[i].name == __name) return styles[i];
			}
			return null;
		}

		protected function getTextElementOld(__text:String): ContentElement {
			var texts:Vector.<String> = new Vector.<String>();
			var tStyles:Vector.<String> = new Vector.<String>();

			texts.push(__text);
			tStyles.push("");

			// Looks for all style tags inside __text
			// TODO: Very manual for proper nesting = use regexp instead?
			// NESTING DOESN'T WORK!
			var i:int;
			var j:int;
			var tagOpen:String, tagClose:String;
			var tagOpenPos:Number, tagClosePos:Number;
			var tempText:String;
			var tempStyle:String;

			for (i = 0; i < styles.length; i++) {
				tagOpen = "<"+styles[i].name+">";
				tagClose = "</"+styles[i].name+">";
				for (j = 0; j < texts.length; j++) {
					tagOpenPos = texts[j].indexOf(tagOpen);
					tagClosePos = texts[j].indexOf(tagClose, tagOpenPos);
					if (tagOpenPos > -1 && tagClosePos > -1) {
						// Found; breaks down
						tempText = texts[j];
						tempStyle = tStyles[j];

						texts.splice(j, 1);
						tStyles.splice(j, 1);

						texts.splice(j, 0, tempText.substr(0, tagOpenPos), tempText.substr(tagOpenPos + tagOpen.length, tagClosePos - tagOpenPos - tagOpen.length), tempText.substr(tagClosePos + tagClose.length));
						tStyles.splice(j, 0, tempStyle, styles[i].name, tempStyle);
					}
				}
			}

//			for (i = 0; i < texts.length; i++) {
//				trace(tStyles[i], texts[i]);
//			}

			var fd:FontDescription = fontDescription.clone();
			var ef:ElementFormat = elementFormat.clone();
			ef.fontDescription = fd;

			var elements:Vector.<ContentElement> = new Vector.<ContentElement>();
			for (i = 0; i < texts.length; i++) {
				// TODO: using too many elements? try to re-use elements...
				if (Boolean(tStyles[i])) {
					// Special text style
					elements.push(new TextElement(texts[i], getStyle(tStyles[i]).getAsElementFormat(ef, fd)));
				} else {
					// Default text style
					elements.push(new TextElement(texts[i], ef));
				}
			}

			fd = null;
			ef = null;

			//elements.push(new TextElement(_text, ef));
			return new GroupElement(elements);
		}

		override protected function getTextElement(__text:String): ContentElement {

			var fd:FontDescription = fontDescription.clone();
			var ef:ElementFormat = elementFormat.clone();
			ef.fontDescription = fd;

			return getSubTextElement(__text, fd, ef);
		}

		protected function getSubTextElement(__text:String, __fd:FontDescription, __ef:ElementFormat): ContentElement {
			//var texts:Vector.<String> = new Vector.<String>();
			//var tStyles:Vector.<String> = new Vector.<String>();

			//texts.push(__text);
			//tStyles.push("");

			// Looks for all style tags inside __text
			// TODO: Very manual for proper nesting = use regexp instead?
			// NESTING DOESN'T WORK!
			var i:int;
//			var j:int;
//			var tagOpen:String, tagClose:String;
//			var tagOpenPos:Number, tagClosePos:Number;
//			var tempText:String;
//			var tempStyle:String;

			//StringUtils.getQuerystringParameterValue(__url, __parameterName)
			//var qsRegex:RegExp = new RegExp("[?&]" + __parameterName + "(?:=([^&]*))?","i");
			//var match:Object = qsRegex.exec(__url);

			XML.ignoreWhitespace = false;

			var contentAsXML:XML = new XML("<root>" + __text + "</root>");
			var contentChildren:XMLList = contentAsXML.children();
			var elements:Vector.<ContentElement> = new Vector.<ContentElement>(contentChildren.length(), true);
			var te:TextElement;
			var ts:TextStyle;
			var ccn:String;
			for (i = 0; i < contentChildren.length(); i++) {
				//trace (i, (contentChildren[i] as XML));
				ccn = (contentChildren[i] as XML).name();
				if (ccn != null && ccn.length > 0) {
					// A sub-node
					//trace ("---> style " + String((contentChildren[i] as XML).name()));
					ts = getStyle(ccn);
					if (Boolean(ts)) {
						// The style exists
						te = new TextElement(contentChildren[i], ts.getAsElementFormat(__ef, __fd));
						te.userData = contentChildren[i];
					} else {
						// Style doesn't exist
						// TODO: do something different here? render the tags?
						te = new TextElement(contentChildren[i], __ef);
					}
				} else {
					// No node, just add the text
					te = new TextElement(contentChildren[i], __ef);
				}
				elements[i] = te;
//				if (Boolean(tStyles[i])) {
//					// Special text style
//					elements.push(new TextElement(texts[i], getStyle(tStyles[i]).getAsElementFormat(__ef, __fd)));
//				} else {
//					// Default text style
//					elements.push(new TextElement(texts[i], __ef));
//				}
			}

			ccn = null;
			ts = null;
			te = null;
			contentChildren = null;

			System.disposeXML(contentAsXML);
			contentAsXML = null;

			XML.ignoreWhitespace = true;

			/*
			var __text:String = "this is a <i link='x'>test</i>...";
			var contentAsXML:XML = new XML("<root link='y'>" + __text + "</root>");
			trace (contentAsXML.attribute("link"));
			trace (contentAsXML.children());
			for (var i:int = 0; i < contentAsXML.children().length(); i++) {
				trace (i, contentAsXML.children()[i].toString(), ".......", contentAsXML.children()[i].name());
			}
			*/


//			for (i = 0; i < styles.length; i++) {
//				tagOpen = "<"+styles[i].name+">";
//				tagClose = "</"+styles[i].name+">";
//				for (j = 0; j < texts.length; j++) {
//					tagOpenPos = texts[j].indexOf(tagOpen);
//					tagClosePos = texts[j].indexOf(tagClose, tagOpenPos);
//					if (tagOpenPos > -1 && tagClosePos > -1) {
//						// Found; breaks down
//						tempText = texts[j];
//						tempStyle = tStyles[j];
//
//						texts.splice(j, 1);
//						tStyles.splice(j, 1);
//
//						texts.splice(j, 0, tempText.substr(0, tagOpenPos), tempText.substr(tagOpenPos + tagOpen.length, tagClosePos - tagOpenPos - tagOpen.length), tempText.substr(tagClosePos + tagClose.length));
//						tStyles.splice(j, 0, tempStyle, styles[i].name, tempStyle);
//					}
//				}
//			}

//			for (i = 0; i < texts.length; i++) {
//				trace(tStyles[i], texts[i]);
//			}

//			var elements:Vector.<ContentElement> = new Vector.<ContentElement>();
//			for (i = 0; i < texts.length; i++) {
//				// TODO: using too many elements? try to re-use elements...
//				if (Boolean(tStyles[i])) {
//					// Special text style
//					elements.push(new TextElement(texts[i], getStyle(tStyles[i]).getAsElementFormat(__ef, __fd)));
//				} else {
//					// Default text style
//					elements.push(new TextElement(texts[i], __ef));
//				}
//			}
			//elements.push(new TextElement(_text, ef));
			return new GroupElement(elements);
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onMouseOver(e:MouseEvent):void {
			if (Boolean(textBlock)) {
				addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
				addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);
				onMouseMove(null);
			}
		}

		protected function onMouseClick(e:MouseEvent):void {
			if (Boolean(_currentLinkHref)) {
				dispatchEvent(new RichTextSpriteEvent(RichTextSpriteEvent.LINK, _currentLinkHref, _currentLinkTarget));
			}
		}

		protected function onMouseMove(e:MouseEvent):void {
			// Check to see if it's over a link
//			var p:Point = new Point(stage.mouseX, stage.mouseY);
//			var lastLine:TextLine = textBlock.firstLine;
//			var pos:int = -1;
//			while (Boolean(lastLine)) {
//				pos = lastLine.getAtomIndexAtPoint(p.x, p.y);
//				if (pos > -1) {
//					pos += lastLine.getAtomTextBlockBeginIndex(0);
//					break;
//				}
//				lastLine = lastLine.nextLine;
//			}

			var pos:int = getCharAtMousePosition();

			if (pos > -1) {
				var elementUnderMouse:ContentElement = getElementAtPos(textBlock.content, pos);
				//trace ("el under mouse ["+pos+"] = " + elementUnderMouse, " / " + elementUnderMouse.rawText + " / ");
				if (Boolean(elementUnderMouse) && Boolean(elementUnderMouse.userData)) {
					// Has some kind of XML data
					var elx:XML = elementUnderMouse.userData as XML;
					if (Boolean(elx) && elx.attribute("href").toString().length > 0) {
						// Has link!
						buttonMode = true;
						_currentLinkHref = elx.attribute("href");
						_currentLinkTarget = elx.attribute("target");
					} else {
						// Doesn't have a link
						buttonMode = false;
						_currentLinkHref = null;
						_currentLinkTarget = null;
					}
					System.disposeXML(elx);
					elx = null;
				} else {
					// No XML data
					buttonMode = false;
					_currentLinkHref = null;
					_currentLinkTarget = null;
				}
//				var groupElement:GroupElement = textBlock.content as GroupElement;
//				if (Boolean(groupElement)) {
//
//					groupElement.elementCount
//					trace (pos + ", el = " + groupElement.getElementAtCharIndex(pos) + " -- " + groupElement.rawText);
//				}
			}

		}

		protected function onMouseOut(e:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			removeEventListener(MouseEvent.CLICK, onMouseClick);
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setStyle(__name:String, __fontName:String = "", __fontSize:Number = NaN, __color:Number = NaN, __alpha:Number = NaN, __trackingAsPhotoshop:Number = NaN):void {
			removeStyle(__name);

			var style:TextStyle = new TextStyle();
			style.name = __name;

			style.fontName = __fontName;
			style.fontSize = __fontSize;
			style.color = __color;
			style.alpha = __alpha;
			style.trackingAsPhotoshop = __trackingAsPhotoshop;

			styles.push(style);

			redraw();
		}

		public function removeStyle(__name:String):void {
			for (var i:int = 0; i < styles.length; i++) {
				if (styles[i].name == __name) {
					styles.splice(i, 1);
					i--;
				}
			}

			redraw();
		}

		public function getTextStyles(): Vector.<TextStyle> {
			return styles.concat();
		}

		public function setTextStyles(__styles:Vector.<TextStyle>):void {
			// Dangerous thing to be done
			styles = __styles;
		}
	}
}
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
class TextStyle {

	// Properties
	public var name:String;

	public var fontName:String;
	public var color:Number;
	public var fontSize:Number;
	public var alpha:Number;
	public var trackingAsPhotoshop:Number;

	// Element format
	//public var tracking:Number;

	// TODO: this must use fontdescription and elementformat instances of its own!

	public function TextStyle() {
	}

	public function getAsElementFormat(__baseElementFormat:ElementFormat, __baseFontDescription:FontDescription): ElementFormat {
		var fd:FontDescription = __baseFontDescription.clone();
		if (Boolean(fontName)) fd.fontName = fontName;

		var ef:ElementFormat = __baseElementFormat.clone();
		ef.fontDescription = fd;
		if (!isNaN(color)) ef.color = color;
		if (!isNaN(fontSize)) ef.fontSize = fontSize;
		if (!isNaN(alpha)) ef.alpha = alpha;
		if (!isNaN(trackingAsPhotoshop)) ef.trackingLeft = ef.trackingRight = trackingAsPhotoshop / 1000 * ef.fontSize;

		return ef;
	}
}