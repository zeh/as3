package com.zehfernando.utils {

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class StringUtils {

		public static function stripDoubleCRLF(__text:String): String {
			if (__text == null) return null;
			return __text.split("\r\n").join("\n");
		}

		public static function wrapSpanStyle(__text:String, __style:String = null): String {
			return (Boolean(__style) ? "<span class='" + __style + "'>" : "<span>")  + __text + "</span>";
		}
		
		public static function wrapCDATA(__text:String):String {
			return "<![CDATA[" + __text + "]]>";
		}
		
		public static function stripInvalidFileCharacters(__text:String): String {
			__text = __text.split(":").join("");
			return __text;
		}
		
		public static function makeStub(__text:String): String {
			// Transforms a title into a stub
			return __text.toLowerCase().replace(" ", "-").replace(/[^a-z0-9\-]/gi, "");
		}

		public static function parseBBCodeToHTML(__text:String): String {

			var rx:RegExp; // For when /gi does not work
		
			// \r\n
			__text = __text.replace(/\r\n/gi, "\n");
	
			// [size="n"]...[/size]
			// <font size="n">...</font>
			rx = /\[size=\u0022([0-9]*?)\u0022\]((.|\n|\r)*?)\[\/size\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<font size=\"$1\">$2</font>");
	
			// [color="c"]...[/color]
			// <font color="c">...</font>
			rx = /\[color=\u0022(#[0-9a-f]*?)\u0022\]((.|\n|\r)*?)\[\/color\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<font color=\"$1\">$2</font>");
	
			// [url="u"]...[/url]
			// <a href="u">...</a>
			rx = /\[url=\u0022(.*?)\u0022\]((.|\n|\r)*?)\[\/url\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<a href=\"$1\">$2</a>");
	
			// [b]...[/b]
			// <b>...</b>
			rx = /\[b\]((.|\n|\r)*?)\[\/b\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<b>$1</b>");
	
			// [i]...[/i]
			// <i>...</i>
			rx = /\[i\]((.|\n|\r)*?)\[\/i\]?/i;
			while (rx.test(__text)) __text = __text.replace(rx, "<i>$1</i>");
	
			return (__text);
		}
		
		public static function cropText(__text:String, __maximumLength:Number, __breakAnywhere:Boolean = false, __postText:String = ""):String {
			
			// Crops a long text, to get excerpts
			if (__breakAnywhere) {
				// Break anywhere
				return __text.substr(0, Math.min(__maximumLength, __text.length)) + __postText;
			}
			
			// Break on words only
			var lastIndex:Number = -1;
			var prevIndex:Number = -1;
			while (lastIndex < __maximumLength) {
				prevIndex = lastIndex;
				lastIndex = __text.indexOf(" ", lastIndex+1);
			}
			return __text.substr(0, Math.max(0, prevIndex)) + __postText;
		}
	}
}
