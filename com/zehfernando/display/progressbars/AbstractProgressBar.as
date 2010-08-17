package com.zehfernando.display.progressbars {
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
		protected var _amount:Number;								// Virtual amount
		protected var _displayAmount:Number;						// Amount actually displayed (with easing)
		

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function AbstractProgressBar() {
			_amount = _displayAmount = 0;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		protected function setAmount(__value:Number, __immediate:Boolean = false): void {
			if (isNaN(__value)) __value = 0;
			
			if (__immediate) {
				_displayAmount = _amount = __value;
				if (Boolean(stage)) redrawAmount();
			} else {
				_amount = __value;
			}
		}

		protected function redrawAmount(): void {
			// Redraws graphics to represent the correct amount
			throw new Error("AbstractLoader :: ERROR: redrawAmount() is not overridden!");
		}


		// ================================================================================================================
		// EVENT INTERFACE ------------------------------------------------------------------------------------------------

		protected function onAddedToStage(e:Event): void {
			addEventListener(Event.ENTER_FRAME, onEnterFrameDraw, false, 0, true);
			redrawAmount();
		}

		protected function onRemovedFromStage(e:Event): void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrameDraw);
		}

		protected function onEnterFrameDraw(e:Event): void {
			_displayAmount += (_amount - _displayAmount) / 2;
			redrawAmount();
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setAmountImmediately(__f:Number): void {
			setAmount(__f, true);
		}

		
		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------
		
		public function get amount(): Number {
			return _amount;
		}
		
		public function set amount(__value:Number): void {
			if (_amount != __value) {
				setAmount(__value);
			}
		}
	}
}
