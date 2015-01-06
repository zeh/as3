package com.zehfernando.display.debug.statgraph {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * @author zeh fernando
	 */

	public class StatGraphBlock extends Sprite {

		// Visuals for one stat graph entry

		// Properties
		protected var _width:Number;
		protected var _height:Number;


		// Instances
		protected var graphBitmapData:BitmapData;
		protected var graphBitmap:Bitmap;

		protected var textLabel:TextField;

		protected var dataPoint:AbstractDataPoint;


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function StatGraphBlock(__dataPoint:AbstractDataPoint, __width:int, __height:int) {
			super();

			dataPoint = __dataPoint;
			_width = __width;
			_height = __height;

			graphBitmapData = new BitmapData(_width, _height, false, 0x000000);

			graphBitmap = new Bitmap(graphBitmapData);
			addChild(graphBitmap);

			var fmt:TextFormat = new TextFormat("_sans", 10, 0xffffff);

			textLabel = new TextField();
			textLabel.defaultTextFormat = fmt;
			textLabel.selectable = false;
			textLabel.autoSize = TextFieldAutoSize.LEFT;
			addChild(textLabel);

		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function addGraphicLine(__val:Number, __minY:int, __maxY:int, __color:Number):void {
			var py:Number = Math.round(__minY + __val * (__maxY - __minY));
			graphBitmapData.fillRect(new Rectangle(_width-1, __maxY, 1, __minY-__maxY+1), colorAsBackground(__color));
			graphBitmapData.fillRect(new Rectangle(_width-1, py, 1, 1), __color);
		}

		protected function colorAsBackground(__color:Number):Number {
			var a:Number = 0.2;
			var r:Number = (__color >> 16 & 0xff) * a;
			var g:Number = (__color >> 8 & 0xff) * a;
			var b:Number = (__color & 0xff) * a;
			return r << 16 | g << 8 | b;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function update(__timeSpentMS:uint):void {
			graphBitmapData.lock();

			// Scroll bitmap to the side
			graphBitmapData.copyPixels(graphBitmapData, new Rectangle(1, 0, graphBitmapData.width - 1, graphBitmapData.height), new Point(0, 0));
			graphBitmapData.fillRect(new Rectangle(graphBitmapData.width-1, 0, 1, graphBitmapData.height), 0x000000); // TODO: set some background color?

			var valUnit:Number = dataPoint.getValueLabelUnit();
			var valUnitDecimal:int = dataPoint.getValueLabelUnitDecimalPoints();
			var valMult:Number = Math.pow(10, valUnitDecimal);

			// Multiplying and dividing is better than using toFixed() because it doesn't produce things like "0."

			var valCurrentRaw:Number = dataPoint.getValueCurrent(__timeSpentMS);
			var valCurrent:Number = Math.floor((valCurrentRaw / valUnit) * valMult) / valMult;
			var valMin:Number = Math.floor((dataPoint.getValueMin() / valUnit) * valMult) / valMult;
			var valMax:Number = Math.floor((dataPoint.getValueMax() / valUnit) * valMult) / valMult;

			var strCurrent:String = isNaN(valCurrent) ? "?" : valCurrent.toString(10);
			var strMin:String = isNaN(valMin) ? "?" : valMin.toString(10);
			var strMax:String = isNaN(valMax) ? "?" : valMax.toString(10);

			addGraphicLine(valCurrentRaw / dataPoint.getValueMaxChart(), _height-1, 0, dataPoint.getColor());

			textLabel.text = dataPoint.getLabel() + ": " + strCurrent + " (" + strMin  + "-" + strMax + ")";
			textLabel.x = 2;
			textLabel.y = _height * 0.5 - textLabel.height * 0.5;

			graphBitmapData.unlock();
		}

		public function dispose():void {
			removeChild(graphBitmap);
			graphBitmap = null;

			graphBitmapData.dispose();
			graphBitmapData = null;

			removeChild(textLabel);
			textLabel = null;
		}

	}
}
