package com.zehfernando.data.types {
	import com.zehfernando.utils.MathUtils;

	import flash.geom.ColorTransform;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class Color {

		// Constants
		private static const BUILT_IN_COLOR_NAMES:Vector.<String>  = new <String>["aqua",    "black",   "blue",    "fuchsia", "gray",    "green",   "lime",    "maroon", "navy",     "olive",	"purple",  "red",     "silver",  "teal",    "white",   "yellow"];
		private static const BUILT_IN_COLOR_VALUES:Vector.<String> = new <String>["#0000ff", "#ffffff", "#0000ff", "#ff00ff", "#808080", "#008000", "#00ff00", "#800000", "#000080", "#808000",	"#800080", "#ff0000", "#c0c0c0", "#008080", "#ffffff", "#ffff00"];

		// Properties
		protected var _r:Number;
		protected var _g:Number;
		protected var _b:Number;
		protected var _a:Number;

		protected var _h:Number = 0;		// for hue preservation when desaturated

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function Color() {
			_r = 0;
			_g = 0;
			_b = 0;
			_a = 0;
		}

		// ================================================================================================================
		// INSTANCE functions ---------------------------------------------------------------------------------------------

		/**
		 * Converts this color to an integer number in the AARRGGBB format (for example: 0xff000000 for opaque black).
		 */
		public function toAARRGGBB():uint {
			// Returns this color as a number in the 0xAARRGGBB format
			return Math.round(_a * 255) << 24 | toRRGGBB();
		}

		/**
		 * Converts this color to an integer number in the RRGGBB format, ignoring its alpha (for example: 0x000000 for black).
		 */
		public function toRRGGBB():Number {
			// Returns this color as a number in the 0xRRGGBB format
			return Math.round(_r * 255) << 16 | Math.round(_g * 255) << 8 | Math.round(_b * 255);
		}

		/**
		 * Converts this color to a ColorTransform instance that applies the correct tinting to a DisplayObject. The alpha value of the color is ignored.
		 * @return	The new ColorTransform object.
		 * @example To apply a white tinting to a DisplayObject:
		 * <listing version="3.0">
		 * var colorWhite:Color = Color.fromRRGGBB(0xffffff);
		 * myDisplayObject.transform.colorTransform = colorWhite.toColorTransform();
		 * </listing>
		 */
		public function toColorTransform(__amount:Number = 1):ColorTransform {
			// Return this color as a tinting color transform
			return new ColorTransform(1 - __amount, 1 - __amount, 1 - __amount, 1, _r*255*__amount, _g*255*__amount, _b*255*__amount, 0);
		}

		/**
		 * Converts this color to a ColorTransform instance that applies the correct tinting to a DisplayObject, by multiplying (expects the original object to be white). The alpha value of the color is ignored.
		 * @return	The new ColorTransform object.
		 * @example To apply a white tinting to a DisplayObject:
		 * <listing version="3.0">
		 * var colorWhite:Color = Color.fromRRGGBB(0xffffff);
		 * myDisplayObject.transform.colorTransform = colorWhite.toColorTransformMultiplied();
		 * </listing>
		 */
		public function toColorTransformMultiplied():ColorTransform {
			// Return this color as a tinting color transform
			return new ColorTransform(_r, _g, _b, 1);
		}

		/**
		 * Converts this color to a ColorTransform instance that applies the correct tinting to a DisplayObject. The alpha value of the color is kept and used as the new DisplayObject's alpha value. This is not meant to be used for interpolated tinting!
		 * @return	The new ColorTransform object.
		 * @example To apply a black tinting to a DisplayObject:
		 * <listing version="3.0">
		 * var colorBlack:Color = Color.fromRRGGBB(0xff000000);
		 * myDisplayObject.transform.colorTransform = colorBlack.toColorTransformAlpha();
		 * </listing>
		 */
		public function toColorTransformAlpha():ColorTransform {
			// Return this color as a tinting + alpha color transform
			var cf:ColorTransform = toColorTransform();
			cf.alphaMultiplier = _a;
			return cf;
		}

		/**
		 * Converts this color to a readable string.
		 * @return	A string describing this color.
		 */
		public function toString() :String {
			var txt:String = "";
			txt += "[";
			txt += "r="+_r.toString(10);
			txt += ",";
			txt += "g="+_g.toString(10);
			txt += ",";
			txt += "b="+_b.toString(10);
			txt += ",";
			txt += "a="+_a.toString(10);
			txt += "]";

			return txt;
		}

		public function clone():Color {
			var cc:Color = new Color();
			cc.r = _r;
			cc.g = _g;
			cc.b = _b;
			cc.a = _a;
			return cc;
		}


		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		protected static function getRFromNumber(__color:Number, __max:Number):Number {
			return ((__color >> 16 & 0xff) / 255) * __max;
		}

		protected static function getGFromNumber(__color:Number, __max:Number):Number {
			return ((__color >> 8 & 0xff) / 255) * __max;
		}

		protected static function getBFromNumber(__color:Number, __max:Number):Number {
			return ((__color & 0xff) / 255) * __max;
		}

		protected static function getAFromNumber(__color:Number, __max:Number):Number {
			return ((__color >> 24 & 0xff) / 255) * __max;
		}

		/**
		 * Creates a new Color object from a number in the RRGGBB format (for example: 0x000000 for black, or 0xffffff for white). The color's alpha property is set to 1 (totally opaque).
		 * @return	The new color object.
		 */
		public static function fromRRGGBB(__value:Number):Color {
			var newColor:Color = new Color();
			newColor.r = getRFromNumber(__value, 1);
			newColor.g = getGFromNumber(__value, 1);
			newColor.b = getBFromNumber(__value, 1);
			newColor.a = 1;

			return newColor;
		}

		/**
		 * Creates a new Color object from a number in the AARRGGBB format (for example: 0x00ffffff for transparent white, or 0xffffffff for opaque white).
		 * @return	The new color object.
		 */
		public static function fromAARRGGBB(__value:Number):Color {
			var newColor:Color = Color.fromRRGGBB(__value);
			newColor.a = getAFromNumber(__value, 1);
			return newColor;
		}

		/**
		 * Creates a new Color object from a combination of the Red, Green, Blue and Alpha values in the 0-1 range.
		 * @return	The new color object.
		 */
		public static function fromRGB(__r:Number, __g:Number, __b:Number, __a:Number = 1):Color {
			var newColor:Color = new Color();
			newColor.r = __r;
			newColor.g = __g;
			newColor.b = __b;
			newColor.a = __a;
			return newColor;
		}

		/**
		 * Creates a new Color object from the desired Hue (0-360), Saturation (0-1), and Value (0-1) values.
		 * @see http://en.wikipedia.org/wiki/HSL_color_space
		 * @return	The new color object.
		 */
		public static function fromHSV(__h:Number, __s:Number, __v:Number, __a:Number = 1):Color {
			var newColor:Color = new Color();
			newColor.v = __v;
			newColor.s = __s;
			newColor.h = __h;
			newColor.a = __a;
			return newColor;
		}

		public static function fromString(__value:String):Color {
			// Based on any HTML/CSS compatible string value, returns the corresponding color

			var newColor:Color = new Color();

			__value = String(__value).toLowerCase().split(" ").join(""); // trimStringSpaces(p_value);

			if (__value.substr(0, 1) == "#") {
				// Hexadecimal color
				var colorValue:String = __value.substr(1);
				if (colorValue.length == 6) {
					// Usual #RRGGBB
					newColor.r = parseInt(colorValue.substr(0, 2), 16) / 255;
					newColor.g = parseInt(colorValue.substr(2, 2), 16) / 255;
					newColor.b = parseInt(colorValue.substr(4, 2), 16) / 255;
					newColor.a = 1;
				} else if (colorValue.length == 8) {
					// #AARRGGBB
					newColor.r = parseInt(colorValue.substr(2, 2), 16) / 255;
					newColor.g = parseInt(colorValue.substr(4, 2), 16) / 255;
					newColor.b = parseInt(colorValue.substr(6, 2), 16) / 255;
					newColor.a = parseInt(colorValue.substr(0, 2), 16) / 255;
				} else if (colorValue.length == 3) {
					// #RGB that turns into #RRGGBB
					newColor.r = parseInt(colorValue.substr(0, 1) + colorValue.substr(0, 1), 16) / 255;
					newColor.g = parseInt(colorValue.substr(1, 1) + colorValue.substr(1, 1), 16) / 255;
					newColor.b = parseInt(colorValue.substr(2, 1) + colorValue.substr(2, 1), 16) / 255;
					newColor.a = 1;
				} else if (colorValue.length == 4) {
					// #ARGB that turns into #AARRGGBB
					newColor.r = parseInt(colorValue.substr(1, 1) + colorValue.substr(1, 1), 16) / 255;
					newColor.g = parseInt(colorValue.substr(2, 1) + colorValue.substr(2, 1), 16) / 255;
					newColor.b = parseInt(colorValue.substr(3, 1) + colorValue.substr(3, 1), 16) / 255;
					newColor.a = parseInt(colorValue.substr(0, 1) + colorValue.substr(0, 1), 16) / 255;
				} else {
					// Wrong type!
					trace ("ERROR! Wrong number of atributes in color number: " + __value + " (" + __value.length + ")");
				}
			} else if (__value.substr(0, 4) == "rgb(" && __value.substr(-1, 1) == ")") {
				// rgb() function
				var colorValues:Array = __value.substr(4, __value.length - 5).split(",");
				if (colorValues.length == 3) {
					// R,G,B
					newColor.r = getColorFunctionNumber(colorValues[0], 1);
					newColor.g = getColorFunctionNumber(colorValues[1], 1);
					newColor.b = getColorFunctionNumber(colorValues[2], 1);
					newColor.a = 1;
				} else if (colorValues.length == 4) {
					// R,G,B,A
					newColor.r = getColorFunctionNumber(colorValues[0], 1);
					newColor.g = getColorFunctionNumber(colorValues[1], 1);
					newColor.b = getColorFunctionNumber(colorValues[2], 1);
					newColor.a = getColorFunctionNumber(colorValues[3], 1);
				} else {
					trace ("ERROR! Wrong number of parameter in color function");
				}
			} else {
				// Must be a named color
				var i:int = 0;
				for (i = 0; i < BUILT_IN_COLOR_NAMES.length; i++) {
					if (__value == BUILT_IN_COLOR_NAMES[i]) {
						// Found the color
						return Color.fromString(BUILT_IN_COLOR_VALUES[i]);
					}
				}
				trace("ERROR! Impossible to parse color name [" + __value + "]");
			}

			return newColor;
		}

		public static function interpolate(__c1:Color, __c2:Color, f:Number):Color {
			// Linear RGB interpolation between two colors
			var newColor:Color = new Color();
			var nf:Number = 1 - f;
			newColor.r = __c1.r * f + __c2.r * nf;
			newColor.g = __c1.g * f + __c2.g * nf;
			newColor.b = __c1.b * f + __c2.b * nf;
			newColor.a = __c1.a * f + __c2.a * nf;
			return newColor;
		}

		public static function interpolateAARRGGBB(__c1:int, __c2:int, f:Number):uint {
			var nf:Number = 1-f;
			return (((__c1 & 0xff000000) * f + (__c2 & 0xff000000) * nf) & 0xff000000) |
				(((__c1 & 0xff0000) * f + (__c2 & 0xff0000) * nf) & 0xff0000) |
				(((__c1 & 0xff00) * f + (__c2 & 0xff00) * nf) & 0xff00) |
				(((__c1 & 0xff) * f + (__c2 & 0xff) * nf) & 0xff);
		}

		public static function interpolateRRGGBB(__c1:int, __c2:int, f:Number):int {
			var nf:Number = 1-f;
			return (((__c1 & 0xff0000) * f + (__c2 & 0xff0000) * nf) & 0xff0000) |
				(((__c1 & 0xff00) * f + (__c2 & 0xff00) * nf) & 0xff00) |
				(((__c1 & 0xff) * f + (__c2 & 0xff) * nf) & 0xff);
		}

		/*
		public static function interpolateHSL(__c1:Color, __c2:Color, f:Number):Color {
			// Linear HSL interpolation between two colors
			var newColor:Color = new Color();
			var nf:Number = 1 - f;
			newColor.l = __c1.l * f + __c2.l * nf;
			newColor.s = __c1.s * f + __c2.s * nf;
			if (__c1.h - __c2.h > 180) {
				newColor.h = (__c1.h - 360) * f + __c2.h * nf;
			} else if (__c2.h - __c1.h > 180) {
				newColor.h = __c1.h * f + (__c2.h - 360) * nf;
			} else {
				newColor.h = __c1.h * f + __c2.h * nf;
			}
			newColor.a = __c1.a * f + __c2.a * nf;
			return newColor;
		}
		*/

		public static function interpolateHSV(__c1:Color, __c2:Color, f:Number):Color {
			// Linear HSL interpolation between two colors
			var newColor:Color = new Color();
			var nf:Number = 1 - f;
			newColor.v = __c1.v * f + __c2.v * nf;
			newColor.s = __c1.s * f + __c2.s * nf;
			if (__c1.h - __c2.h > 180) {
				newColor.h = (__c1.h - 360) * f + __c2.h * nf;
			} else if (__c2.h - __c1.h > 180) {
				newColor.h = __c1.h * f + (__c2.h - 360) * nf;
			} else {
				newColor.h = __c1.h * f + __c2.h * nf;
			}
			newColor.a = __c1.a * f + __c2.a * nf;
			return newColor;
		}

		/*
		public static function fromHSL(__h:Number, __s:Number, __l:Number):Color {
			var newColor:Color = new Color();
			newColor.l = __l;
			newColor.s = __s;
			newColor.h = __h;
			return newColor;
		}
		*/

		public static function getColorFunctionNumber(__value:String, __max:Number):Number {
			// Based on a HTML/CSS string value, returns the correct color number (0-255)
			// Examples:
			// 0 -> 0
			// 200 -> 200 - 0.7843...
			// 100% -> 255 -> 1
			// 256 -> 255 -> 1
			// 156.7 -> 0.614...

			var finalValue:Number;

			__value = String(__value).toLowerCase().split(" ").join("");
			if (__value.substr(-1,1) == "%") {
				// Percentage
				finalValue = parseFloat(__value.substr(0, __value.length-1)) / 100;
			} else {
				// Normal value
				finalValue = parseFloat(__value) / 255;
			}

			return MathUtils.clamp(finalValue) * __max;
		}

		protected function setHSV(__h:Number, __s:Number, __v:Number):void {
			//var hi:Number = Math.floor(__h/60) % 6;
			var hi:Number = MathUtils.rangeMod(Math.floor(__h/60), 0, 6);
			var f:Number = __h/60 - Math.floor(__h/60);
			var p:Number = __v * (1 - __s);
			var q:Number = __v * (1 - f * __s);
			var t:Number = __v * (1 - (1 - f) * __s);
			switch (hi) {
				case 0:
					_r = __v;
					_g = t;
					_b = p;
					break;
				case 1:
					_r = q;
					_g = __v;
					_b = p;
					break;
				case 2:
					_r = p;
					_g = __v;
					_b = t;
					break;
				case 3:
					_r = p;
					_g = q;
					_b = __v;
					break;
				case 4:
					_r = t;
					_g = p;
					_b = __v;
					break;
				case 5:
					_r = __v;
					_g = p;
					_b = q;
					break;
				default:
					trace ("ERROR!" + hi);
			}
		}

		/*
		protected function setHSL(__h:Number, __s:Number, __l:Number):void {

			var q:Number = __l < 0.5 ? __l * (1+__s) : __l + __s - (__l * __s);
			var p:Number = 2 * __l - q;
			var hk:Number = __h / 360;

			var tr:Number = hk + 1/3;
			var tg:Number = hk;
			var tb:Number = hk - 1/3;

			_r = calculateHSLComponent(tr, p, q) * 255;
			_g = calculateHSLComponent(tg, p, q) * 255;
			_b = calculateHSLComponent(tb, p, q) * 255;
		}

		protected function calculateHSLComponent(c:Number, p:Number, q:Number):Number {
			c = c < 0 ? c+1 : c > 1 ? c - 1 : c;
			if (c < 1/6) {
				return p + ((q - p) * 6 * c);
			} else if (c < 1/2) {
				return q;
			} else if (c < 2/3) {
				return p + ((q - p) * 6 * (2/3 - c));
			} else {
				return p;
			}
		}
		*/


		// ================================================================================================================
		// GETTER and SETTER functions ------------------------------------------------------------------------------------

		// Default RGB representation
		public function get r():Number				{ return _r; }
		public function set r(__value:Number):void	{ _r = MathUtils.clamp(__value, 0, 255); } // { _r = value & 0xff; }

		public function get g():Number				{ return _g; }
		public function set g(__value:Number):void	{ _g = MathUtils.clamp(__value, 0, 255); }

		public function get b():Number				{ return _b; }
		public function set b(__value:Number):void	{ _b = MathUtils.clamp(__value, 0, 255); }

		public function get a():Number				{ return _a; }
		public function set a(__value:Number):void	{ _a = MathUtils.clamp(__value, 0, 255); }

		public function get h():Number {
			// Return Hue (0-360)
			var max:Number = Math.max(_r, _g, _b);
			var min:Number = Math.min(_r, _g, _b);
			if (max == min) {
				return _h;
			} else if (_r == max) {
				if (_g > _b) {
					return 60 * (_g - _b) / (_r - _b);
				} else {
					return (60 * (6 - (_b - _g) / (_r - _g))) % 360;
				}
			} else if (_g == max) {
				if (_r > _b) {
					return 60 * (2 - (_r - _b) / (_g - _b));
				} else {
					return 60 * (2 + (_b - _r) / (_g - _r));
				}
			} else {
				if (_g > _r) {
					return 60 * (4 - (_g - _r) / (_b - _r));
				} else {
					return 60 * (4 + (_r - _g) / (_b - _g));
				}
			}
		}
		public function set h(__value:Number):void {
			// Set Hue (0-360)
			_h = MathUtils.rangeMod(__value, 0, 360);
			setHSV(_h, s, v);
		}

		public function get s():Number {
			// Return HSV-compliant Saturation (0-1)
			var max:Number = Math.max(_r, _g, _b);
			var min:Number = Math.min(_r, _g, _b);
			if (max == min) {
				return 0;
			} else {
				return 1 - (min/max);
			}
		}
		public function set s(__value:Number):void {
			// Set HSV-style saturation (0-1)
			setHSV(h, MathUtils.clamp(__value), v);
		}

		public function get v():Number {
			// Return Value (0-1)
			var max:Number = Math.max(_r, _g, _b);
			return max;
		}

		public function set v(__value:Number):void {
			// Set lightness (0-1)
			setHSV(h, s, MathUtils.clamp(__value));
		}

		/*
		HSL:
		public function get h():Number {
			// Return Hue (0-360)
			var __r:Number = MathUtils.map(_r, 0, 255);
			var __g:Number = MathUtils.map(_g, 0, 255);
			var __b:Number = MathUtils.map(_b, 0, 255);
			var max:Number = Math.max(__r, __g, __b);
			var min:Number = Math.min(__r, __g, __b);
			if (max == min) {
				return _h;
			} else if (__r == max) {
				return (60 * ((__g - __b) / (max - min))) % 360;
			} else if (__g == max) {
				return 60 * ((__b - __r) / (max - min)) + 120;
			} else {
				return 60 * ((__r - __g) / (max - min)) + 240;
			}
		}
		public function set h(__value:Number):void {
			// Set Hue (0-360)
			_h = MathUtils.roundClamp(__value, 0, 360);
			setHSL(_h, s, l);
		}

		public function get s():Number {
			// Return HSL-style Saturation (0-1)
			var __r:Number = MathUtils.map(_r, 0, 255);
			var __g:Number = MathUtils.map(_g, 0, 255);
			var __b:Number = MathUtils.map(_b, 0, 255);
			var max:Number = Math.max(__r, __g, __b);
			var min:Number = Math.min(__r, __g, __b);
			var __l:Number = (max+min) / 2;
			if (max == min) {
				return 0;
			} else if (__l < 0.5) {
				return (max-min) / (2 * l);
			} else {
				return (max-min) / (2 - (2 * l));
			}
		}
		public function set s(__value:Number):void {
			// Set HSL-style saturation (0-1)
			setHSL(h, MathUtils.clamp(__value), l);
		}

		public function get l():Number {
			// Return Lightness (0-1)
			var __r:Number = MathUtils.map(_r, 0, 255);
			var __g:Number = MathUtils.map(_g, 0, 255);
			var __b:Number = MathUtils.map(_b, 0, 255);
			var max:Number = Math.max(__r, __g, __b);
			var min:Number = Math.min(__r, __g, __b);
			return (max+min) / 2;
		}

		public function set l(__value:Number):void {
			// Set lightness (0-1)
			setHSL(h, s, MathUtils.clamp(__value));
		}
		*/

	}
}
