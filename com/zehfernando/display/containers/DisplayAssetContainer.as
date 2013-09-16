package com.zehfernando.display.containers {

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 */
	public class DisplayAssetContainer extends Sprite {

		/*
		StageScaleMode.SHOW_ALL;		// Fit to inside, can create margins
		StageScaleMode.EXACT_FIT;		// Distort to fit, breaks aspect ratio
		StageScaleMode.NO_BORDER;		// Fit to outside, can crop
		StageScaleMode.NO_SCALE;		// 1:1, centered
		*/

		// Properties
		protected var _width:Number;
		protected var _height:Number;

		protected var _margin:Number;
		protected var _contentWidth:Number;
		protected var _contentHeight:Number;
		protected var _backgroundColor:Number;

		protected var _scaleMode:String;
		protected var _contentScale:Number;					// Default = 1
		protected var _scrollX:Number;						// -1 to 1
		protected var _scrollY:Number;						// -1 to 1

		protected var _minimumScale:Number;					// Minimum scale for scaleMode (1 = 1:1, 100%)
		protected var _maximumScale:Number;					// Maximum scale for scaleMode (1 = 1:1, 100%)

		protected var _roundPositions:Boolean;				//

		// Instances
		protected var boundingBox:Sprite;
		protected var contentHolder:Sprite;
		protected var contentAsset:DisplayObject;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function DisplayAssetContainer(__width:Number = 100, __height:Number = 100, __backgroundColor:Number = 0x000000) {

			_backgroundColor = __backgroundColor;
			_width = __width;
			_height = __height;
			_roundPositions = false;

			setDefaultData();

			createBackground();
			createContentHolder();

			redraw();
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected function setDefaultData():void {
			_scaleMode = StageScaleMode.NO_SCALE;

			_contentWidth = NaN;
			_contentHeight = NaN;

			_margin = 0;
			_contentScale = 1;
			_scrollX = 0;
			_scrollY = 0;

			_minimumScale = NaN;
			_maximumScale = NaN;
		}

		protected function createBackground():void {
			boundingBox = new Sprite();
			addChild(boundingBox);
		}

		protected function createContentHolder():void {
			contentHolder = new Sprite();
			addChild(contentHolder);
		}

		protected function redrawBackground():void {
			boundingBox.graphics.clear();
			boundingBox.graphics.lineStyle();
			boundingBox.graphics.beginFill(_backgroundColor, 1);
			boundingBox.graphics.drawRect(0, 0, _width, _height);
			boundingBox.graphics.endFill();
		}

		protected function redrawScrollRect():void {
			scrollRect = new Rectangle(0, 0, _width, _height);
		}

		protected function redrawContent():void {

			var baseScale:Point = getBaseScale();

			var newScaleX:Number = baseScale.x * _contentScale;
			var newScaleY:Number = baseScale.y * _contentScale;

			var minX:Number = _margin;
			var maxX:Number = _width - _margin - _contentWidth * newScaleX;
			var minY:Number = _margin;
			var maxY:Number = _height - _margin - _contentHeight * newScaleY;
			// TODO - in some cases (SHOW_ALL) moving is not desirable?

			var px:Number = minX + (maxX-minX) * ((_scrollX+1)/2);
			var py:Number = minY + (maxY-minY) * ((_scrollY+1)/2);

			contentHolder.x = _roundPositions ? Math.round(px) : px;
			contentHolder.y = _roundPositions ? Math.round(py) : py;
			//contentHolder.width = _contentWidth * newScaleX;
			//contentHolder.height = _contentHeight * newScaleY;
			contentHolder.scaleX = newScaleX;
			contentHolder.scaleY = newScaleY;
		}

		// Returns the base scale, which is what is the vertical and horizontal content scale for the current scaleMode
		protected function getBaseScale(__scaleMode:String = ""): Point {

			if (__scaleMode == "") __scaleMode = scaleMode;

			var baseScaleX:Number, baseScaleY:Number;

			var fullW:Number = _width - _margin * 2;
			var fullH:Number = _height - _margin * 2;

			// Fit content to container
			switch (__scaleMode) {
				case StageScaleMode.EXACT_FIT:
					// Distort to fit, ignore content scale or position
					baseScaleX = fullW/_contentWidth;
					baseScaleY = fullH/_contentHeight;
					break;
				case StageScaleMode.NO_SCALE:
					// 1:1, centered, fixed size
					baseScaleX = baseScaleY = 1;
					break;
				case StageScaleMode.SHOW_ALL:
					// Fit to inside, can create margins
				case StageScaleMode.NO_BORDER:
					// Fit to outside, can crop
					var contentRatio:Number = _contentWidth/_contentHeight;
					var containerRatio:Number = fullW/fullH;

					if (contentRatio > containerRatio && __scaleMode == StageScaleMode.SHOW_ALL || contentRatio < containerRatio && __scaleMode == StageScaleMode.NO_BORDER) {
						// The content is "longer" than the container AND it should fit inside,
						// or the content is "higher" than the container AND it should fit outside
						// Use the ratio of the container width as the base
						baseScaleX = baseScaleY = fullW/_contentWidth;
					} else {
						// The content is "higher" than the container AND it should fit inside,
						// or the content is "longer" than the container AND it should fit outside
						// Use the ratio of the container height as the base
						baseScaleX = baseScaleY = fullH/_contentHeight;
					}
					break;
				default:
					trace ("ERROR :: VideoContainer :: redraw :: No known resize method: "+__scaleMode);
			}

			if (!isNaN(minimumScale)) {
				if (baseScaleX < _minimumScale) baseScaleX = _minimumScale;
				if (baseScaleY < _minimumScale) baseScaleY = _minimumScale;
			}
			if (!isNaN(_maximumScale)) {
				if (baseScaleX > _maximumScale) baseScaleX = _maximumScale;
				if (baseScaleY > _maximumScale) baseScaleY = _maximumScale;
			}

			return new Point(baseScaleX, baseScaleY);
		}

		protected function redraw():void {
			if (!isNaN(_contentWidth) && !isNaN(_contentHeight)) redrawContent();

			redrawBackground();
			redrawScrollRect();
		}


		// ================================================================================================================
		// PUBLIC API functions -------------------------------------------------------------------------------------------

		public function dispose():void {
			// Remove asset
			removeAsset();

			// Remove content holder
			removeChild(contentHolder);
			contentHolder = null;;

			// Remove background
			removeChild(boundingBox);
			boundingBox = null;
		}

		// Returns the correct content scale for a showAll equivalent, regardless of the current scaleMode
		public function getContentScaleForShowAll():Number {
			// Slightly wrong: this only takes x into consideration. Must think for different content scales types...
			var myScale:Point = getBaseScale();
			var altScale:Point = getBaseScale(StageScaleMode.SHOW_ALL);
			return altScale.x / myScale.x;
			//return 1;
		}

		public function setAsset(__displayObject:DisplayObject, __forcedWidth:Number = NaN, __forcedHeight:Number = NaN):void {
			removeAsset();

			contentAsset = __displayObject;
			contentHolder.addChild(contentAsset);

			_contentWidth = isNaN(__forcedWidth) ? contentAsset.width : __forcedWidth;
			_contentHeight = isNaN(__forcedHeight) ? contentAsset.height : __forcedHeight;

			redraw();
		}

		public function removeAsset():void {
			if (Boolean(contentAsset) && contentHolder.contains(contentAsset)) {
				contentHolder.removeChild(contentAsset);
				contentAsset = null;
			}
		}

		public function getTransformedPoint(__point:Point): Point {
			// Based on a given point on the original content, returns the transformed point based on this container position

			var p:Point = __point.clone();
			p = contentHolder.localToGlobal(p);
			p = parent.globalToLocal(p);

			return p;
		}

		public function getTransformedContentScale():Number {
			return contentHolder.scaleX;
		}


		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		// Container sizes ----------------------------------

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			_width = __value;
			redraw();
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			_height = __value;
			redraw();
		}

		public function get margin():Number {
			return _margin;
		}
		public function set margin(__value:Number):void {
			_margin = __value;
			redraw();
		}

		// Content scaling and display ----------------------------------

		public function get scaleMode():String {
			return _scaleMode;
		}
		public function set scaleMode(__value:String):void {
			if (_scaleMode != __value) {
				_scaleMode = __value;
				redraw();
			}
		}

		public function get minimumScale():Number {
			return _minimumScale;
		}
		public function set minimumScale(__value:Number):void {
			if (_minimumScale != __value) {
				_minimumScale = __value;
				redraw();
			}
		}

		public function get maximumScale():Number {
			return _maximumScale;
		}
		public function set maximumScale(__value:Number):void {
			if (_maximumScale != __value) {
				_maximumScale = __value;
				redraw();
			}
		}

		public function get scrollX():Number {
			return _scrollX;
		}
		public function set scrollX(__value:Number):void {
			if (_scrollX != __value) {
				_scrollX = __value;
				redraw();
			}
		}

		public function get scrollY():Number {
			return _scrollY;
		}
		public function set scrollY(__value:Number):void {
			if (_scrollY != __value) {
				_scrollY = __value;
				redraw();
			}
		}

		public function get contentScale():Number {
			return _contentScale;
		}
		public function set contentScale(__value:Number):void {
			if (_contentScale != __value) {
				_contentScale = __value;
				redraw();
			}
		}

		// Background stuff ----------------------------------

		public function get backgroundAlpha():Number {
			return boundingBox.alpha;
		}
		public function set backgroundAlpha(__value:Number):void {
			if (__value != boundingBox.alpha) {
				boundingBox.alpha = __value;
				boundingBox.visible = __value > 0;
			}
		}

		public function get backgroundColor():int {
			return _backgroundColor;
		}
		public function set backgroundColor(__value:int):void {
			if (_backgroundColor != __value) {
				_backgroundColor = __value;
				redrawBackground();
			}
		}

		// Content information ----------------------------------

		public function get contentWidth():Number {
			return _contentWidth;
		}
		public function get contentHeight():Number {
			return _contentHeight;
		}

		// Round position

		public function get roundPositions():Boolean {
			return _roundPositions;
		}
		public function set roundPositions(__value:Boolean):void {
			if (_roundPositions != __value) {
				_roundPositions = __value;
				redraw();
			}
		}

		public function hasContent():Boolean {
			return Boolean(contentAsset);
		}
	}
}
