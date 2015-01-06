package com.zehfernando.display.debug {
	import flash.display.Sprite;

	/**
	 * @author zeh fernando
	 */
	public class QuickButtonPanel extends Sprite {

		// Properties
		private var buttons:Vector.<QuickButton>;
		private var col:int;
		private var row:int;
		private var buttonWidth:Number;
		private var buttonHeight:Number;
		private var marginHorizontal:Number;
		private var marginVertical:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function QuickButtonPanel(__buttonWidth:Number = 140, __buttonHeight:Number = 35, __marginHorizontal:Number = 10, __marginVertical:Number = 5) {
			buttons = new Vector.<QuickButton>();

			buttonWidth = __buttonWidth;
			buttonHeight = __buttonHeight;
			marginHorizontal = __marginHorizontal;
			marginVertical = __marginVertical;

			col = 0;
			row = 0;
		}


		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function addButton(__text:String, __onClick:Function = null):void {
			var ix:Number = col * (buttonWidth + marginHorizontal);
			var iy:Number = row * (buttonHeight + marginVertical);

			var button:QuickButton = new QuickButton(__text, ix, iy, __onClick, buttonWidth, buttonHeight);
			addChild(button);
			buttons.push(button);

			row++;
		}

		public function addEmptySpace():void {
			row++;
		}

		public function addNewColumn():void {
			col++;
			row = 0;
		}
	}
}
