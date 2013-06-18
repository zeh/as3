package com.zehfernando.navigation {

	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class ResizableNavigableSprite extends NavigableSprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;

		// Ugh

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ResizableNavigableSprite() {
			super();

			_width = 100;
			_height = 100;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function redrawWidth():void {
			for (var i:int = 0; i < createdChildren.length; i++) {
				if (createdChildren[i].parent == _childrenContainer) createdChildren[i].width = _width;
			}
		}

		protected function redrawHeight():void {
			for (var i:int = 0; i < createdChildren.length; i++) {
				if (createdChildren[i].parent == _childrenContainer) createdChildren[i].height = _height;
			}
		}

		override protected function createChild(__stub:String): NavigableSprite {
			var ns:NavigableSprite = super.createChild(__stub);
			if (Boolean(ns)) {
				redrawWidth();
				redrawHeight();
			}
			return ns;
		}

		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void {
			redrawWidth();
			redrawHeight();
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		override public function get width():Number {
			return _width;
		}
		override public function set width(__value:Number):void {
			if (_width != __value) {
				_width = __value;
				redrawWidth();
			}
		}

		override public function get height():Number {
			return _height;
		}
		override public function set height(__value:Number):void {
			if (_height != __value) {
				_height = __value;
				redrawHeight();
			}
		}
	}
}
