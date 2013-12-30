package com.zehfernando.data {
	import starling.textures.Texture;

	import flash.net.NetStream;
	/**
	 * @author zeh fernando
	 */
	public class GarbageCan {

		// Gathers stuff to be cleared later

		// Properties
		private var items:Array;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function GarbageCan() {
			items = [];
		}

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		private function removeItem(__item:Object):void {
			if (__item is NetStream) removeItemNetStream(__item as NetStream);
			if (__item is Texture) (__item as Texture).dispose();
		}

		private function removeItemNetStream(__item:NetStream):void {
			__item.close();
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function put(__object:Object):void {
			items.push(__object);
		}

		public function get numItems():int {
			return items.length;
		}

		public function clearOne():void {
			if (items.length > 0) removeItem(items.pop());
		}
	}
}
