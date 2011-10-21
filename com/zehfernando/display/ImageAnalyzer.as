package com.zehfernando.display {

	import com.zehfernando.data.types.Color;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * @author zeh
	 */
	public class ImageAnalyzer {

		// Computes the light from a BitmapData image, based on histogram... max color, min color, average color
		// TODO: Ugh, create a better API for this

		// Properties
		protected var _min:Color;
		protected var _max:Color;
		protected var _average:Color;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ImageAnalyzer(__bitmapData:BitmapData, __rect:Rectangle = null) {

			var hstg:Vector.<Vector.<Number>> = __bitmapData.histogram(__rect);
			var i:int, j:int;
			var tot:Number;			// Total color
			var items:Number;		// Number of items
			var cmin:Number;
			var cmax:Number;

			var population:int;

			_min = new Color();
			_max = new Color();
			_average = new Color();

			for (i = 0; i < 4; i++) {
				tot = 0;
				items = 0;
				cmin = 255;
				cmax = 0;
				for (j = 0; j < 256; j++) {
					population = hstg[i][j];
					items += population;
					tot += population * j;

					if (population > 0 && j < cmin) cmin = j;

					if (population > 0 && j > cmax) cmax = j;
				}

				switch(i) {
					case 0:
						_min.r = cmin/255;
						_max.r = cmax/255;
						_average.r = tot/items/255;
						break;
					case 1:
						_min.g = cmin/255;
						_max.g = cmax/255;
						_average.g = tot/items/255;
						break;
					case 2:
						_min.b = cmin/255;
						_max.b = cmax/255;
						_average.b = tot/items/255;
						break;
					case 3:
						_min.a = cmin/255;
						_max.a = cmax/255;
						_average.a = tot/items/255;
						break;
				}
			}

			// Luma values - http://www.faqs.org/faqs/graphics/colorspace-faq/
			// var cavg:Number = avg[0] * 0.212671 + avg[1] * 0.71516 + avg[2] * 0.072169;
		}

		public function get min():Color {
			return _min;
		}

		public function get max():Color {
			return _max;
		}

		public function get average():Color {
			return _average;
		}
	}
}
