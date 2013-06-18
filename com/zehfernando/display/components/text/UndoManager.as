package com.zehfernando.display.components.text {
	/**
	 * @author zeh
	 */
	public class UndoManager {

		// Properties
		protected var _currentState:int;

		protected var states:Vector.<Object>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function UndoManager() {
			clear();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getState():Object {
			if (_currentState > -1) return states[_currentState];

			return null;
		}

		public function saveState(__state:Object):void {
			currentState++;
			states[currentState] = __state;

			// Delete additional states
			if (states.length > _currentState+1) {
				states.splice(_currentState+1, states.length - _currentState - 1);
			}
		}

		public function clear():void {
			states = new Vector.<Object>();
			currentState = -1;
		}

		public function prevState():Boolean {
			if (_currentState > 0) {
				_currentState--;
				return true;
			}
			return false;
		}

		public function nextState():Boolean {
			if (_currentState < states.length - 1) {
				_currentState++;
				return true;
			}
			return false;
		}

		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get currentState():int {
			return _currentState;
		}
		public function set currentState(__value:int):void {
			if (_currentState != __value) {
				_currentState = __value;
			}
		}
	}
}
