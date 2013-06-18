package com.zehfernando.display.abstracts {

	import com.zehfernando.utils.RenderUtils;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;

	/**
	 * @author zeh
	 */
	public class PerspectiveSprite extends Sprite {

		// Properties
		private var _assumedWidth:Number;
		private var _assumedHeight:Number;

		//private var _redrawScheduled:Boolean;

		// Instances
		private var _topLeft:Point;
		private var _topRight:Point;
		private var _bottomLeft:Point;
		private var _bottomRight:Point;
		private var _container3d:Sprite;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function PerspectiveSprite(__assumedWidth:Number = 640, __assumedHeight:Number = 480) {
			_assumedWidth = __assumedWidth;
			_assumedHeight = __assumedHeight;

			_container3d = new Sprite();
			super.addChild(_container3d);

			_topLeft = new Point(0, 0);
			_topRight = new Point(_assumedWidth, 0);
			_bottomLeft = new Point(0, _assumedHeight);
			_bottomRight = new Point(_assumedWidth, _assumedHeight);

			scheduleRedraw();
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function redrawPerspective():void {
			// 3D Transforms

			// Based on wh0's work:
			// http://wonderfl.net/c/sxQJ
			// With original matrix equations from Mathlab
			var w:Number = _assumedWidth;
			var h:Number = _assumedHeight;

			removeTransform();

			_container3d.rotationX = 0;

			var pp:PerspectiveProjection = new PerspectiveProjection();
			pp.projectionCenter = new Point (640, 400); // Doesn't matter?
			transform.perspectiveProjection = pp;

			var v:Vector.<Number> = _container3d.transform.matrix3D.rawData;

			var cx:Number = transform.perspectiveProjection.projectionCenter.x;
			var cy:Number = transform.perspectiveProjection.projectionCenter.y;
			var cz:Number = transform.perspectiveProjection.focalLength;

			v[12] = _topLeft.x;
			v[13] = _topLeft.y;
			v[0] = -(cx*_topLeft.x*_bottomLeft.y-cx*_bottomLeft.x*_topLeft.y-cx*_topLeft.x*_bottomRight.y-cx*_topRight.x*_bottomLeft.y+cx*_bottomLeft.x*_topRight.y+cx*_bottomRight.x*_topLeft.y+cx*_topRight.x*_bottomRight.y-cx*_bottomRight.x*_topRight.y-_topLeft.x*_bottomLeft.x*_topRight.y+_topRight.x*_bottomLeft.x*_topLeft.y+_topLeft.x*_bottomRight.x*_topRight.y-_topRight.x*_bottomRight.x*_topLeft.y+_topLeft.x*_bottomLeft.x*_bottomRight.y-_topLeft.x*_bottomRight.x*_bottomLeft.y-_topRight.x*_bottomLeft.x*_bottomRight.y+_topRight.x*_bottomRight.x*_bottomLeft.y)/(_topRight.x*_bottomLeft.y-_bottomLeft.x*_topRight.y-_topRight.x*_bottomRight.y+_bottomRight.x*_topRight.y+_bottomLeft.x*_bottomRight.y-_bottomRight.x*_bottomLeft.y) / w;
			v[1] = -(cy*_topLeft.x*_bottomLeft.y-cy*_bottomLeft.x*_topLeft.y-cy*_topLeft.x*_bottomRight.y-cy*_topRight.x*_bottomLeft.y+cy*_bottomLeft.x*_topRight.y+cy*_bottomRight.x*_topLeft.y+cy*_topRight.x*_bottomRight.y-cy*_bottomRight.x*_topRight.y-_topLeft.x*_topRight.y*_bottomLeft.y+_topRight.x*_topLeft.y*_bottomLeft.y+_topLeft.x*_topRight.y*_bottomRight.y-_topRight.x*_topLeft.y*_bottomRight.y+_bottomLeft.x*_topLeft.y*_bottomRight.y-_bottomRight.x*_topLeft.y*_bottomLeft.y-_bottomLeft.x*_topRight.y*_bottomRight.y+_bottomRight.x*_topRight.y*_bottomLeft.y)/(_topRight.x*_bottomLeft.y-_bottomLeft.x*_topRight.y-_topRight.x*_bottomRight.y+_bottomRight.x*_topRight.y+_bottomLeft.x*_bottomRight.y-_bottomRight.x*_bottomLeft.y) / w;
			v[2] = (cz*_topLeft.x*_bottomLeft.y-cz*_bottomLeft.x*_topLeft.y-cz*_topLeft.x*_bottomRight.y-cz*_topRight.x*_bottomLeft.y+cz*_bottomLeft.x*_topRight.y+cz*_bottomRight.x*_topLeft.y+cz*_topRight.x*_bottomRight.y-cz*_bottomRight.x*_topRight.y)/(_topRight.x*_bottomLeft.y-_bottomLeft.x*_topRight.y-_topRight.x*_bottomRight.y+_bottomRight.x*_topRight.y+_bottomLeft.x*_bottomRight.y-_bottomRight.x*_bottomLeft.y) / w;
			v[4] = (cx*_topLeft.x*_topRight.y-cx*_topRight.x*_topLeft.y-cx*_topLeft.x*_bottomRight.y+cx*_topRight.x*_bottomLeft.y-cx*_bottomLeft.x*_topRight.y+cx*_bottomRight.x*_topLeft.y+cx*_bottomLeft.x*_bottomRight.y-cx*_bottomRight.x*_bottomLeft.y-_topLeft.x*_topRight.x*_bottomLeft.y+_topRight.x*_bottomLeft.x*_topLeft.y+_topLeft.x*_topRight.x*_bottomRight.y-_topLeft.x*_bottomRight.x*_topRight.y+_topLeft.x*_bottomRight.x*_bottomLeft.y-_bottomLeft.x*_bottomRight.x*_topLeft.y-_topRight.x*_bottomLeft.x*_bottomRight.y+_bottomLeft.x*_bottomRight.x*_topRight.y)/(_topRight.x*_bottomLeft.y-_bottomLeft.x*_topRight.y-_topRight.x*_bottomRight.y+_bottomRight.x*_topRight.y+_bottomLeft.x*_bottomRight.y-_bottomRight.x*_bottomLeft.y) / h;
			v[5] = (cy*_topLeft.x*_topRight.y-cy*_topRight.x*_topLeft.y-cy*_topLeft.x*_bottomRight.y+cy*_topRight.x*_bottomLeft.y-cy*_bottomLeft.x*_topRight.y+cy*_bottomRight.x*_topLeft.y+cy*_bottomLeft.x*_bottomRight.y-cy*_bottomRight.x*_bottomLeft.y-_topLeft.x*_topRight.y*_bottomLeft.y+_bottomLeft.x*_topLeft.y*_topRight.y+_topRight.x*_topLeft.y*_bottomRight.y-_bottomRight.x*_topLeft.y*_topRight.y+_topLeft.x*_bottomLeft.y*_bottomRight.y-_bottomLeft.x*_topLeft.y*_bottomRight.y-_topRight.x*_bottomLeft.y*_bottomRight.y+_bottomRight.x*_topRight.y*_bottomLeft.y)/(_topRight.x*_bottomLeft.y-_bottomLeft.x*_topRight.y-_topRight.x*_bottomRight.y+_bottomRight.x*_topRight.y+_bottomLeft.x*_bottomRight.y-_bottomRight.x*_bottomLeft.y) / h;
			v[6] = -(cz*_topLeft.x*_topRight.y-cz*_topRight.x*_topLeft.y-cz*_topLeft.x*_bottomRight.y+cz*_topRight.x*_bottomLeft.y-cz*_bottomLeft.x*_topRight.y+cz*_bottomRight.x*_topLeft.y+cz*_bottomLeft.x*_bottomRight.y-cz*_bottomRight.x*_bottomLeft.y)/(_topRight.x*_bottomLeft.y-_bottomLeft.x*_topRight.y-_topRight.x*_bottomRight.y+_bottomRight.x*_topRight.y+_bottomLeft.x*_bottomRight.y-_bottomRight.x*_bottomLeft.y) / h;

			try {
				_container3d.transform.matrix3D.rawData = v;
			} catch(e:Error) {
				trace("PerspectiveSprite :: Error: " + e);
			}

		}

		private function scheduleRedraw():void {
			RenderUtils.addFunction(redrawPerspective);
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

//		protected function onExitFrameRedraw(e:Event):void {
//			_redrawScheduled = false;
//			removeEventListener(Event.EXIT_FRAME, onExitFrameRedraw);
//			redrawPerspective();
//		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function removeTransform():void {
			_container3d.transform.matrix3D = null;
		}

//		public function redraw():void {
//			onExitFrameRedraw(null);
//		}

		// Public overrides
		override public function addChild(__child:DisplayObject): DisplayObject {
			return _container3d.addChild(__child);
		}

		override public function addChildAt(__child:DisplayObject, __index:int): DisplayObject {
			return _container3d.addChildAt(__child, __index);
		}

		override public function getChildAt(__index:int): DisplayObject {
			return _container3d.getChildAt(__index);
		}

		override public function getChildByName(__name:String): DisplayObject {
			return _container3d.getChildByName(__name);
		}

		override public function getChildIndex(__child:DisplayObject):int {
			return _container3d.getChildIndex(__child);
		}

		override public function removeChild(__child:DisplayObject): DisplayObject {
			return _container3d.removeChild(__child);
		}

		override public function removeChildAt(__index:int): DisplayObject {
			return _container3d.removeChildAt(__index);
		}

		override public function setChildIndex(__child:DisplayObject, __index:int):void {
			_container3d.setChildIndex(__child, __index);
		}

		override public function swapChildren(__child1:DisplayObject, __child2:DisplayObject):void {
			_container3d.swapChildren(__child1, __child2);
		}

		override public function swapChildrenAt(__index1:int, __index2:int):void {
			_container3d.swapChildrenAt(__index1, __index2);
		}

		override public function get numChildren() :int {
			return _container3d.numChildren;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get topLeft(): Point {
			return _topLeft;
		}
		public function set topLeft(__value:Point):void {
			_topLeft = __value;
			scheduleRedraw();
		}

		public function get topRight(): Point {
			return _topRight;
		}
		public function set topRight(__value:Point):void {
			_topRight = __value;
			scheduleRedraw();
		}

		public function get bottomLeft(): Point {
			return _bottomLeft;
		}
		public function set bottomLeft(__value:Point):void {
			_bottomLeft = __value;
			scheduleRedraw();
		}

		public function get bottomRight(): Point {
			return _bottomRight;
		}
		public function set bottomRight(__value:Point):void {
			_bottomRight = __value;
			scheduleRedraw();
		}

		public function get assumedWidth():Number {
			return _assumedWidth;
		}

		public function get assumedHeight():Number {
			return _assumedHeight;
		}
	}
}
