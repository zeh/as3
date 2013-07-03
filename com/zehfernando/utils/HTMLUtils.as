package com.zehfernando.utils {
	import com.zehfernando.utils.console.error;

	import flash.external.ExternalInterface;

	/**
	 * @author zeh
	 */
	public class HTMLUtils {

		protected static var _isJavaScriptAvailable:Boolean;
		protected static var _isJavaScriptAvailableKnown:Boolean;
		protected static var _SWFName:String;

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected static function testJavascript():Boolean {
			if (!isJavaScriptAvailable) {
				error("ERROR: no javascript available!");
				return false;
			}
			return true;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function setCookie(__name:String, __value:String = "", __expireDays:Number = 0):void {

			if (!testJavascript()) return;

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function(__name, __value, __expireDays) {
					var expDate = new Date();
					expDate.setDate(expDate.getDate() + __expireDays);
					document.cookie = escape(__name) + "=" + escape(__value) + ((__expireDays == 0) ? "" : ";expires=" + expDate.toGMTString()) + "; path=/";
				}
			]]></script>;
			/*FDT_IGNORE*/

			ExternalInterface.call(js, __name, __value, __expireDays);
		}

		public static function getCookie(__name:String):String {

			if (!testJavascript()) return null;

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function(__name) {
					var exp = new RegExp(escape(__name) + "=([^;]+)");
					if (exp.test (document.cookie + ";")) {
						exp.exec (document.cookie + ";");
						return unescape(RegExp.$1);
					} else {
						return "";
					}
				}
			]]></script>;
			/*FDT_IGNORE*/

			return ExternalInterface.call(js, __name);
		}

		// Set the element height:
		// ExternalInterface.call("function(){document.getElementById(this.attributes.id).style.height = '" + $height + "px'}");

		public static function getSWFObjectName():String {
			// Based on https://github.com/millermedeiros/Hasher_AS3_helper/blob/master/dev/src/org/osflash/hasher/Hasher.as
			// Also http://blog.iconara.net/2009/02/06/how-to-work-around-the-lack-of-externalinterfaceobjectid-in-actionscript-2/
			// Returns the SWF's object name for getElementById

			// If already found, just return the existing name
			if (Boolean(_SWFName)) return _SWFName;

			if (Boolean(ExternalInterface.objectID)) return ExternalInterface.objectID;

			if (!testJavascript()) return null;

			// Reliable only if attributes.id and attributes.name is defined
			// if (Boolean(ExternalInterface.objectID)) return ExternalInterface.objectID;

			// Always work?
			// return ExternalInterface.call("function(){return this.attributes.id;}");

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function(__randomFunction) {
					var check = function(objects){
						for (var i = 0; i < objects.length; i++){
							if (objects[i][__randomFunction]) return objects[i].id;
						}
						return undefined;
					};

					return check(document.getElementsByTagName("object")) || check(document.getElementsByTagName("embed"));
				}
			]]></script>;
			/*FDT_IGNORE*/

			var __randomFunction:String = StringUtils.generatePropertyName();
			ExternalInterface.addCallback(__randomFunction, getSWFObjectName);

			_SWFName = ExternalInterface.call(js, __randomFunction);

			return _SWFName;
		}

		public static function openPopup(__url:String, __width:int = 600, __height:int = 400, __name:String = "_blank", __onClosed:Function = null):void {

			if (!testJavascript()) return;

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function(__url, __width, __height, __name, __SWFContext, __onClosed) {

					//alert("caller is " + __SWFContext);
					//alert("caller is " + arguments.callee.caller.toString());

					if (__onClosed != "") {
						// If 'onClosed' is supplied, call a function when the popup window is closed

						var HTMLUtils_checkForWindow = function() {
							if (HTMLUtils_newWindow.closed) {
								clearInterval(HTMLUtils_windowCheckInterval);
								document.getElementById(__SWFContext)[__onClosed]();
							}
						};

						var HTMLUtils_windowCheckInterval = setInterval(HTMLUtils_checkForWindow, 250);
					}

					//http://www.yourhtmlsource.com/javascript/popupwindows.html

					var wx = (screen.width - __width)/2;
					var wy = (screen.height - __height)/2;

					var HTMLUtils_newWindow = window.open(__url, __name, "top="+wy+",left="+wx+",width="+__width+",height="+__height);
					if (HTMLUtils_newWindow.focus) HTMLUtils_newWindow.focus();

//					function getFlashMovie() {
//						return document.getElementById(movieName)
//					}

				}
			]]></script>;
			/*FDT_IGNORE*/

			var __onClosedString:String = "";

			if (!ExternalInterface.available) {
				trace ("No ExternalInterface available!");
				return;
			}

			if (Boolean(__onClosed)) {
				__onClosedString = StringUtils.generatePropertyName();
				ExternalInterface.addCallback(__onClosedString, __onClosed);
			}

			ExternalInterface.call(js, __url, __width, __height, __name, getSWFObjectName(), __onClosedString);
		}

		public static function closeWindow():void {

			if (!testJavascript()) return;

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function() {

					window.close();

				}
			]]></script>;
			/*FDT_IGNORE*/

			ExternalInterface.call(js);
		}

		public static function reload():void {

			if (!testJavascript()) return;

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function() {

					window.location.reload();

				}
			]]></script>;
			/*FDT_IGNORE*/

			ExternalInterface.call(js);
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public static function get isJavaScriptAvailable():Boolean {
			if (!_isJavaScriptAvailableKnown) {
				// Test to see if javascript is available

				if (ExternalInterface.available) {
					try {
						_isJavaScriptAvailable = Boolean(ExternalInterface.call("function() { return true; }"));
					} catch (e:Error) {
						_isJavaScriptAvailable = false;
					}
				} else {
					_isJavaScriptAvailable = false;
				}

				_isJavaScriptAvailableKnown = true;

			}
			return _isJavaScriptAvailable;
		}

//		public static function setSessionCookie(__name:String, __value:String = ""):void {
//
//			var js:XML;
//			/*FDT_IGNORE*/
//			js = <script><![CDATA[
//				function(__name, __value) {
//					document.cookie = escape(__name) + "=" + escape(__value) + "; path=/";
//				}
//			]]></script>;
//			/*FDT_IGNORE*/
//
//    		ExternalInterface.call(js, __name, __value);
//		}
//
//		public static function getSessionCookie(__name:String):String {
//
//			var js:XML;
//			/*FDT_IGNORE*/
//			js = <script><![CDATA[
//				function(__name) {
//					var exp = new RegExp(escape(__name) + "=([^;]+)");
//					if (exp.test (document.cookie + ";")) {
//						exp.exec (document.cookie + ";");
//						return unescape(RegExp.$1);
//					} else {
//  						return "";
//					}
//			  	}
//			]]></script>;
//			/*FDT_IGNORE*/
//
//    		return ExternalInterface.call(js, __name);
//		}
	}
}
