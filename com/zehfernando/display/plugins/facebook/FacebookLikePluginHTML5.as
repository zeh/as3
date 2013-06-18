package com.zehfernando.display.plugins.facebook {

	import com.zehfernando.utils.HTMLUtils;
	import com.zehfernando.utils.MathUtils;
	import com.zehfernando.utils.RenderUtils;
	import com.zehfernando.utils.StringUtils;

	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Point;

	/**
	 * @author zeh
	 */
	public class FacebookLikePluginHTML5 extends Sprite {

		// https://developers.facebook.com/docs/reference/plugins/like/
		// http://code.google.com/apis/analytics/docs/tracking/gaTrackingSocial.html#facebook

		// Enums
		public static const LAYOUT_STANDARD:String = "standard"; // displays social text to the right of the button and friends' profile photos below. Minimum width: 225 pixels. Default width: 450 pixels. Height: 35 pixels (without photos) or 80 pixels (with photos).
		public static const LAYOUT_BUTTON_COUNT:String = "button_count"; // displays the total number of likes to the right of the button. Minimum width: 90 pixels. Default width: 90 pixels. Height: 20 pixels.
		public static const LAYOUT_BOX_COUNT:String = "box_count"; // displays the total number of likes above the button. Minimum width: 55 pixels. Default width: 55 pixels. Height: 65 pixels.

		public static const ACTION_LIKE:String = "like";
		public static const ACTION_RECOMMEND:String = "recommend";

		public static const FONT_ARIAL:String = "arial";
		public static const FONT_LUCIDA_GRANDE:String = "lucida grande";
		public static const FONT_SEGOE_UI:String = "segoe ui";
		public static const FONT_TAHOMA:String = "tahoma";
		public static const FONT_TREBUCHET_MS:String = "trebuchet ms";
		public static const FONT_VERDANA:String = "verdana";

		public static const COLOR_SCHEME_LIGHT:String = "light";
		public static const COLOR_SCHEME_DARK:String = "dark";

		// Properties
		protected var _href:String; // the URL to like
		protected var _layout:String;
		protected var _showFaces:Boolean;
		protected var _action:String;
		protected var _font:String;
		protected var _colorScheme:String;
		protected var _ref:String;

		protected var _desiredWidth:Number;
		protected var _desiredHeight:Number;

		protected var id:String;
		protected var hasDiv:Boolean;

		protected var _stage:Stage;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function FacebookLikePluginHTML5(__href:String) {
			_href = __href;
			_layout = LAYOUT_STANDARD;
			_showFaces = false;
			_action = ACTION_LIKE;
			_font = FONT_TAHOMA;
			_colorScheme = COLOR_SCHEME_LIGHT;
			_ref = "";

			_desiredWidth = 0;
			_desiredHeight = 0;

			id = "facebooklike_" + StringUtils.getRandomAlphanumericString(16);
			hasDiv = false;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function createDiv():void {
			destroyDiv();

			var js:XML;
			/*FDT_IGNORE*/
			js = <script><![CDATA[
				function(__id, __content) {
					var newDiv = document.createElement("div");
					newDiv.setAttribute("id", __id);
					newDiv.setAttribute("style", "visibility: hidden; border:none; overflow:hidden; position:absolute; top:0px; left:0px; width:1px; height:1px;");
					newDiv.setAttribute("scrolling", "no");
					newDiv.setAttribute("allowTransparency", "true");
					newDiv.innerHTML = __content;
					document.body.appendChild(newDiv);

					// Fix for IE7 positioning
					newDiv.style["position"] = "absolute";

					try {
						FB.XFBML.parse();
					} catch(e) {
					}
				}
			]]></script>;
			/*FDT_IGNORE*/

			ExternalInterface.call(js, id, getDivContent());

			hasDiv = true;

			applyDivDimensions();
			applyDivOpacity();
		}

		protected function getDivContent():String {
			var str:String = "";

			//str += '<script src="http://connect.facebook.net/en_US/all.js#xfbml=1"></script>';

  			str += '<div class="fb-like"';
				str += ' data-href="' + _href + '"';
				str += ' data-send="false"';
				str += ' data-width="' + getWidth() + '"';
				str += ' data-layout="' + _layout + '"';
				str += ' data-show-faces="' + (_showFaces ? "true" : "false") + '"';
				str += ' data-action="' + _action + '"';
				str += ' data-colorscheme="' + _colorScheme + '"';
				str += ' data-font="' + _font + '"';
			str += '>';
			str += '</div>';

			return str;

			// data-action="recommend" data-colorscheme="dark" data-font="lucida grande"></div>
		}

		protected function destroyDiv():void {
			if (hasDiv) {
				var js:XML;
				/*FDT_IGNORE*/
				js = <script><![CDATA[
					function(__id) {
						var parentDiv = document.body;
						var childDiv = document.getElementById(__id);
						parentDiv.removeChild(childDiv);
					}
				]]></script>;
				/*FDT_IGNORE*/

				ExternalInterface.call(js, id);

				hasDiv = false;
			}
		}

		protected function applyDivDimensions():void {

			var p1:Point = localToGlobal(new Point(0, 0));
			var p2:Point = localToGlobal(new Point(getWidth(), getHeight()));

			setDivStyleProperty("left", Math.round(p1.x) + "px");
			setDivStyleProperty("top", Math.round(p1.y) + "px");
			setDivStyleProperty("width", (Math.round(p2.x) - Math.round(p1.x)) + "px"); // Proper rounding to absolute value
			setDivStyleProperty("height",(Math.round(p2.y) - Math.round(p1.y)) + "px"); // Proper rounding to absolute value
		}

		protected function applyDivOpacity():void {
			setDivStyleProperty("visibility", visible ? "visible" : "hidden");
			setDivStyleProperty("opacity", alpha.toString(10));
			setDivStyleProperty("filter", "alpha(opacity=" + Math.round(alpha * 100) + ")");
		}

		protected function requestCreateDiv():void {
			RenderUtils.addFunction(createDiv);
		}

		protected function requestApplyDivDimensions():void {
			RenderUtils.addFunction(applyDivDimensions);
		}

//		protected function requestApplyDivOpacity():void {
//			RenderUtils.addFunction(applyDivOpacity);
//		}

		protected function setDivStyleProperty(__property:String, __value:String):void {

			if (HTMLUtils.isJavaScriptAvailable && hasDiv) {

				var js:XML;
				/*FDT_IGNORE*/
				js = <script><![CDATA[
					function(__id, __property, __value) {
						document.getElementById(__id).style[__property] = __value;
					}
				]]></script>;
				/*FDT_IGNORE*/

				ExternalInterface.call(js, id, __property, __value);
			}
		}

		protected function getWidth():Number {
			var minWidth:Number = 0;
			var maxWidth:Number = 9999;

			if (_layout == LAYOUT_STANDARD) minWidth = 225;
			if (_layout == LAYOUT_BUTTON_COUNT) minWidth = 90;
			if (_layout == LAYOUT_BOX_COUNT) minWidth = 55;

			return MathUtils.clamp(_desiredWidth, minWidth, maxWidth);
		}

		protected function getHeight():Number {
			var minHeight:Number = 0;
			var maxHeight:Number = 9999;

			if (_layout == LAYOUT_STANDARD) minHeight = maxHeight = (_showFaces ? 80 : 35);
			if (_layout == LAYOUT_BUTTON_COUNT) minHeight = maxHeight = 20;
			if (_layout == LAYOUT_BOX_COUNT) minHeight = maxHeight = 65;

			return MathUtils.clamp(_desiredHeight, minHeight, maxHeight);
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void {
			createDiv();
			_stage = stage;
			_stage.addEventListener(Event.RESIZE, onStageResize);
		}

		protected function onStageResize(e:Event):void {
			requestApplyDivDimensions();
		}

		protected function onRemovedFromStage(e:Event):void {
			_stage.removeEventListener(Event.RESIZE, onStageResize);
			destroyDiv();
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function set x(__value:Number):void {
			if (super.x != __value) {
				super.x = __value;
				applyDivDimensions();
			}
		}

		override public function set y(__value:Number):void {
			if (super.y != __value) {
				super.y = __value;
				applyDivDimensions();
			}
		}

		override public function get width():Number {
			return getWidth();
		}
		override public function set width(__value:Number):void {
			if (_desiredWidth != __value) {
				_desiredWidth = __value;
				requestCreateDiv();
				//applyDivDimensions();
			}
		}

		override public function get height():Number {
			return getHeight();
		}
		override public function set height(__value:Number):void {
			if (_desiredHeight != __value) {
				_desiredHeight = __value;
				requestCreateDiv();
				//applyDivDimensions();
			}
		}

		override public function set alpha(__value:Number):void {
			if (super.alpha != __value) {
				super.alpha = __value;
				applyDivOpacity();
			}
		}

		override public function set visible(__value:Boolean):void {
			if (super.visible != __value) {
				super.visible = __value;
				applyDivOpacity();
			}
		}

		public function get layout():String {
			return _layout;
		}
		public function set layout(__value:String):void {
			if (_layout != __value) {
				_layout = __value;
				requestCreateDiv();
			}
		}
	}
}
