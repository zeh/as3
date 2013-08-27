package com.zehfernando.display.progressbars {
	import com.zehfernando.data.types.AutoAttenuatedNumber;

	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * @author zeh
	 */
	public class AbstractProgressBar extends Sprite {

		/*
		A nice loader with value easing.
		*/

		// Properties
		protected var _value:AutoAttenuatedNumber;								// Virtual amount


		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AbstractProgressBar() {
			_value = new AutoAttenuatedNumber(8, 0, 0, true);

			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function setAmount(__value:Number, __immediate:Boolean = false):void {
			if (isNaN(__value)) __value = 0;

			if (__immediate) {
				_value.target = _value.current = __value;
				if (Boolean(stage)) redrawAmount();
			} else {
				_value.target = __value;
			}
		}

		protected function redrawAmount():void {
			// Redraws graphics to represent the correct amount
			throw new Error("AbstractLoader :: ERROR: redrawAmount() is not overridden!");
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event):void {
			_value.start();
			addEventListener(Event.ENTER_FRAME, onEnterFrameDraw, false, 0, true);
			redrawAmount();
		}

		protected function onRemovedFromStage(e:Event):void {
			_value.stop();
			removeEventListener(Event.ENTER_FRAME, onEnterFrameDraw);
		}

		protected function onEnterFrameDraw(e:Event):void {
			redrawAmount();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setAmountImmediately(__f:Number):void {
			setAmount(__f, true);
		}


		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get amount():Number {
			return _value.target;
		}

		public function set amount(__value:Number):void {
			if (_value.target != __value) {
				setAmount(__value);
			}
		}

		public function get visibleAmount():Number {
			return _value.current;
		}
	}
}
