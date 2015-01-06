package com.zehfernando.utils {
	import flash.sampler.getMasterString;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class StringUtils {

		private static const VALUE_TRUE:String = "true";			// Array considered as explicit "true" when reading data from a XML
		private static const VALUE_FALSE:String = "false";		// Array considered as explicit "false" when reading data from a XML

		public static const VALIDATION_EMAIL:RegExp = /^[a-z][\w.-]+@\w[\w.-]+\.[\w.-]*[a-z][a-z]$/i;

		private static var savedBytes:uint = 0;
		private static var savedByteTimes:uint = 0;

		private static var uniqueSerialNumber:int = 0;

		public static var reportCleanedStrings:Boolean = false;

		public static function stripDoubleCRLF(__text:String):String {
			if (__text == null) return null;
			return __text.split("\r\n").join("\n");
		}

		public static function wrapSpanStyle(__text:String, __style:String = null):String {
			return (Boolean(__style) ? "<span class='" + __style + "'>" : "<span>")  + __text + "</span>";
		}

		public static function wrapCDATA(__text:String):String {
			return "<![CDATA[" + __text + "]]>";
		}

		public static function stripInvalidFileCharacters(__text:String):String {
			__text = __text.split(":").join("");
			return __text;
		}

		public static function makeStub(__text:String):String {
			// Transforms a title into a stub
			return __text.toLowerCase().replace(" ", "-").replace(/[^a-z0-9\-]/gi, "");
		}

		public static function slugify(__text:String):String {
			// Source: http://active.tutsplus.com/articles/roundups/15-useful-as3-snippets-on-snipplr-com/
			const pattern1:RegExp = /[^\w- ]/g; // Matches anything except word characters, space and -
			const pattern2:RegExp = / +/g; // Matches one or more space characters
			var s:String = __text;
			return s.replace(pattern1, "").replace(pattern2, "-").toLowerCase();
		}

		public static function parseBBCodeToHTML(__text:String):String {

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

			if (__text.length <= __maximumLength) return __text;

			// Crops a long text, to get excerpts
			if (__breakAnywhere) {
				// Break anywhere
				return __text.substr(0, Math.min(__maximumLength, __text.length)) + __postText;
			}

			// Break on words only
			var lastIndex:Number = 0;
			var prevIndex:Number = -1;
			while (lastIndex < __maximumLength && lastIndex > -1) {
				prevIndex = lastIndex;
				lastIndex = __text.indexOf(" ", lastIndex+1);
			}

			if (prevIndex == -1) {
				trace ("##### COULD NOT CROP ==> ", prevIndex, lastIndex, __text);
				prevIndex = __maximumLength;
			}

			return __text.substr(0, Math.max(0, prevIndex)) + __postText;
		}

		public static function getQuerystringParameterValue(__url:String, __parameterName:String):String {
			// Finds the value of a parameter given a querystring/url and the parameter name
			var qsRegex:RegExp = new RegExp("[?&]" + __parameterName + "(?:=([^&]*))?","i");
			var match:Object = qsRegex.exec(__url);

			if (Boolean(match)) return match[1];
			return null;
		}

		public static function replaceHTMLLinksInsideHTML(__text:String, __target:String = "_blank", __twitterSearchTemplate:String = "http://twitter.com/search?q=[[string]]", __twitterUserTemplate:String = "http://twitter.com/[[user]]"):String {
			// Replaces links like replaceHTMLLinks(), but preserving existing HTML code (avoid creating double links)

			var __txt:String = "";
			var i:int;

			var xml:XML = new XML(__text);

			// Tag open begin
			__txt += "<"+xml.name();

			// Add attributes
			for (i = 0; i < xml.attributes().length(); i++) {
				__txt += " " + (xml.attributes()[i] as XML).name() + "=\"" + (xml.attributes()[i] as XML).toString() + "\"";
			}

			// Tag open end
			__txt += ">";

			// Add children
			for (i = 0; i < xml.children().length(); i++) {
				if ((xml.children()[i] as XML).nodeKind() == "element") {
					if (String((xml.children()[i] as XML).name()) == "a") {
						__txt += (xml.children()[i] as XML).toXMLString();
					} else {
						__txt += replaceHTMLLinksInsideHTML((xml.children()[i] as XML).toXMLString(), __target, __twitterSearchTemplate, __twitterUserTemplate);
					}
				} else {
					__txt += replaceHTMLLinks((xml.children()[i] as XML).toString(), __target, __twitterSearchTemplate, __twitterUserTemplate);
				}
			}

			// Tag close
			__txt += "</"+xml.name()+">";

			return getCleanString(__txt);

		}

		public static function getHTMLWithStrippedTags(__text:String, __tagsToKeep:Array = null):String {
			if (__tagsToKeep == null) __tagsToKeep = [];

			var xml:XML = new XML(__text);
			var __txt:String = "";
			var i:int;

			if (__tagsToKeep.indexOf(String(xml.name())) > -1) {
				// Keep tag

				// Tag open begin
				__txt += "<"+xml.name();

				// Add attributes
				for (i = 0; i < xml.attributes().length(); i++) {
					__txt += " " + (xml.attributes()[i] as XML).name() + "=\"" + (xml.attributes()[i] as XML).toString() + "\"";
				}

				// Tag open end
				__txt += ">";
			}

			// Add children
			for (i = 0; i < xml.children().length(); i++) {
				if ((xml.children()[i] as XML).nodeKind() == "element") {
					__txt += getHTMLWithStrippedTags((xml.children()[i] as XML).toXMLString(), __tagsToKeep);
				} else {
					__txt += (xml.children()[i] as XML).toString();
				}
			}

			if (__tagsToKeep.indexOf(String(xml.name())) > -1) {
				// Tag close
				__txt += "</"+xml.name()+">";
			}

			return getCleanString(__txt);

		}

		public static function replaceHTMLLinks(__text:String, __target:String = "_blank", __twitterSearchTemplate:String = "http://twitter.com/search?q=[[string]]", __twitterUserTemplate:String = "http://twitter.com/[[user]]"):String {

			// Create links for urls, hashtags and whatnot on the text
			var regexSearch:RegExp;
			var regexResult:Object;
			var str:String;

			var linkStart:Vector.<int> = new Vector.<int>();
			var linkLength:Vector.<int> = new Vector.<int>();
			var linkURL:Vector.<String> = new Vector.<String>();

			var i:int;

			// Links for hashtags
			//regexSearch = /\s#+\w*(\s|,|!|\.|\n)*?/gi;
			regexSearch = /\B#+\w*(\s|,|!|\.|\n)*?/gi;
			regexResult = regexSearch.exec(__text);
			while (regexResult != null) {
				str = regexResult[0];
				linkURL.push(__twitterSearchTemplate.split("[[string]]").join(escape(str)));
				linkStart.push(regexResult["index"]);
				linkLength.push(str.length);
				regexResult = regexSearch.exec(__text);
			}

			// Links for user names
			regexSearch = /@+\w*(\s|,|!|\.|\n)*?/gi;
			regexResult = regexSearch.exec(__text);
			while (regexResult != null) {
				str = regexResult[0];
				// Inserts in a sorted manner otherwise it won't work when looping
				for (i = 0; i <= linkStart.length; i++) {
					if (i == linkStart.length || regexResult["index"] < linkStart[i]) {
						linkURL.splice(i, 0, __twitterUserTemplate.split("[[user]]").join(str.substr(1)));
						linkStart.splice(i, 0, regexResult["index"]);
						linkLength.splice(i, 0, str.length);
						break;
					}
				}
				regexResult = regexSearch.exec(__text);
			}

			// Links for URLs
			regexSearch = /(http:\/\/+[\S]*)/gi;
			regexResult = regexSearch.exec(__text);
			while (regexResult != null) {
				str = regexResult[0];
				// Inserts in a sorted manner otherwise it won't work when looping
				for (i = 0; i <= linkStart.length; i++) {
					if (i == linkStart.length || regexResult["index"] < linkStart[i]) {
						linkURL.splice(i, 0, str);
						linkStart.splice(i, 0, regexResult["index"]);
						linkLength.splice(i, 0, str.length);
						break;
					}
				}
//				linkURL.push(str);
//				linkStart.push(regexResult["index"]);
//				linkLength.push(str.length);
				regexResult = regexSearch.exec(__text);
				//trace ("URL --> [" + str + "]");
			}

			// More links for URLs
			regexSearch = /(www\.[\S]*)/gi;
			regexResult = regexSearch.exec(__text);
			while (regexResult != null) {
				str = regexResult[0];
				// Inserts in a sorted manner otherwise it won't work when looping
				for (i = 0; i <= linkStart.length; i++) {
					if (i == linkStart.length || regexResult["index"] < linkStart[i]) {
						linkURL.splice(i, 0, str);
						linkStart.splice(i, 0, regexResult["index"]);
						linkLength.splice(i, 0, str.length);
						break;
					}
				}
//				linkURL.push(str);
//				linkStart.push(regexResult["index"]);
//				linkLength.push(str.length);
				regexResult = regexSearch.exec(__text);
				//trace ("URL --> [" + str + "]");
			}

			// Finally, add the links as HTML links
			var newText:String = "";
			var lastPos:int = 0;
			i = 0;
			while (i < linkStart.length) {
				newText += __text.substr(lastPos, linkStart[i] - lastPos);
				newText += "<a href=\"" + linkURL[i] + "\" target=\""+__target+"\">";
				newText += __text.substr(linkStart[i], linkLength[i]);
				newText += "</a>";

				lastPos = linkStart[i] + linkLength[i];

				i++;
			}


			newText += __text.substr(lastPos);
			//trace ("--> " + newDescription);

			return newText;
		}

		public static function URLEncode(__text:String):String {
			__text = escape(__text);
			__text = __text.split("@").join("%40");
			__text = __text.split("+").join("%2B");
			__text = __text.split("/").join("%2F");
			return __text;
		}

		public static function generatePropertyName():String {
			return "f" + getRandomAlphanumericString(16) + ("00000000" + getUniqueSerialNumber().toString(16)).substr(-8,8);
		}

		public static function getRandomAlphanumericString(__chars:int = 1):String {
			// Returns a random alphanumeric string with the specific number of chars
			var chars:String = "0123456789AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz";
			var i:int;

			var str:String = "";

			for (i = 0; i < __chars; i++) {
				str += chars.substr(Math.floor(Math.random() * chars.length), 1);
			}

			return str;
		}

		public static function generateGUID():String {
			// http://en.wikipedia.org/wiki/Globally_unique_identifier
			// This one is actually more unorthodox
			var i:int;

			var nums:Vector.<int> = new Vector.<int>();
			nums.push(getUniqueSerialNumber());
			nums.push(getUniqueSerialNumber());
			for (i = 0; i < 10; i++) {
				nums.push(Math.round(Math.random() * 255));
			}

			var strs:Vector.<String> = new Vector.<String>();
			for (i = 0; i < nums.length; i++) {
				strs.push(("00" + nums[i].toString(16)).substr(-2,2));
			}
			var now:Date = new Date();

			var secs:String = ("0000" + now.getMilliseconds().toString(16)).substr(-4, 4);

			// 4-2-2-6
			return strs[0]+strs[1]+strs[2]+strs[3]+"-"+secs+"-"+strs[4]+strs[5]+"-"+strs[6]+strs[7]+strs[8]+strs[9]+strs[10]+strs[11];
		}

		public static function getUniqueSerialNumber():int {
			return uniqueSerialNumber++;
		}

		public static function validate(__text:String, __expression:RegExp):Boolean {
			return __expression.test(__text);
		}

		public static function trim(__text:String):String {
			// Removes whitespace at the beginning and end of a string
			var whitespace:Array = [" ", "\r", "\n", "\t"];

			// Beginning
			while (__text.length > 0 && whitespace.indexOf(__text.charAt(0)) > -1) {
				__text = __text.substr(1);
			}

			// End
			while (__text.length > 0 && whitespace.indexOf(__text.charAt(__text.length - 1)) > -1) {
				__text = __text.substr(0, __text.length - 1);
			}

			return __text;
		}

		public static function toBoolean(__string:String, __default:Boolean = false):Boolean {
			if (__string == null || __string.length == 0) return __default;
			if (__string.toLowerCase() == VALUE_TRUE) return true;
			if (__string.toLowerCase() == VALUE_FALSE) return false;
			return __default;
		}

		public static function getCleanString(__string:String):String {
			// "Cleans" a string, by separating it from its "master" string
			// http://jacksondunstan.com/articles/2260
			// http://jacksondunstan.com/articles/2551
			if (__string == null) return null;
			if (reportCleanedStrings) {
				var str:String = getMasterString(__string);
				if (str != null) {
					savedBytes += str.length;
					savedByteTimes++;
					if (savedByteTimes % 1000 == 0) trace("Saved " + (savedBytes/1024/1024).toFixed(2) + " string MB so far (" + (savedBytes / (getTimer() / 1000)).toFixed(2) + " bytes/s)");
				}
			}

			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(__string);
			bytes.position = 0;
			return bytes.readUTFBytes(bytes.length);
		}
	}
}
