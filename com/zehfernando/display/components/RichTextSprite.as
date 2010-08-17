package com.zehfernando.display.components {
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

		
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function RichTextSprite(__font:String = "_sans", __size:Number = 12, __color:Number = 0x000000) {
			styles = new Vector.<TextStyle>();

			super(__font, __size, __color);
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
		
		override protected function getTextElement(__text:String): ContentElement {
			var texts:Vector.<String> = new Vector.<String>();
			var tStyles:Vector.<String> = new Vector.<String>();
			
			texts.push(__text);
			tStyles.push("");
			
			// Looks for all style tags inside __text
			// TODO: Very manual for proper nesting = use regexp instead?
			// NESTING DOESN'T WORK!
			var i:int, j:int;
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

			// Finally, create elements
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
			//elements.push(new TextElement(_text, ef));
			return new GroupElement(elements);
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setStyle(__name:String, __fontName:String = "", __fontSize:Number = NaN, __color:Number = NaN):void {
			var style:TextStyle = new TextStyle();
			style.name = __name;
			style.fontName = __fontName;
			style.fontSize = __fontSize;
			style.color = __color;
			
			styles.push(style);
		}

		public function getTextStyles(): Vector.<TextStyle> {
			return styles.concat();
		}

		public function setTextStyles(__styles:Vector.<TextStyle>): void {
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
	public var color:uint;
	public var fontSize:Number;
	
	// Element format
	//public var tracking:Number;

	// TODO: this must use fontdescription and elementformat instances of its own!

	public function TextStyle() {
	}
	
	public function getAsElementFormat(__baseElementFormat:ElementFormat, __baseFontDescription:FontDescription): ElementFormat {
		var fd:FontDescription = __baseFontDescription.clone();
		fd.fontName = fontName;

		var ef:ElementFormat = __baseElementFormat.clone();
		ef.fontDescription = fd;
		ef.color = color;
		ef.fontSize = fontSize;

		return ef;
	}
}