package com.zehfernando.display.abstracts {
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class ResizableSprite extends Sprite {

		// Properties
		protected var _width:Number;
		protected var _height:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function ResizableSprite() {
			_width = 100;
			_height = 100;

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function redrawWidth():void {
			throw new Error("Error: the method redrawWidth() of ResizableSprite has to be overridden.");
		}

		protected function redrawHeight():void {
			throw new Error("Error: the method redrawHeight() of ResizableSprite has to be overridden.");
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(__e:Event):void {
			redrawWidth();
			redrawHeight();
		}

		protected function onRemovedFromStage(__e:Event):void {
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
