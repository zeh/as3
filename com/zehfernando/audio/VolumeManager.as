package com.zehfernando.audio {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	/**
	 * @author zeh
	 */
	public class VolumeManager extends EventDispatcher {

		// Constants
		public static const EVENT_CHANGE_VOLUME:String = "onChangeVolume";

		// Static properties
		protected static var managers:Vector.<VolumeManager>;

		// Properties
		protected var _name:String;
		protected var _mute:Number;						// 0 (not mute) to 1 (mute). Mute is a separate multiplier, so it can always be toggled and return to the original volume
		protected var _volume:Number;					// 0 - 1
		protected var _panning:Number;
		protected var _globalControl:Boolean;

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		{
			managers = new Vector.<VolumeManager>();
		}

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function VolumeManager(__name:String = null) {
			super(null);

			_name = __name;
			_mute = 0;
			_volume = 1;
			_panning = 0;
			_globalControl = !Boolean(__name);

			VolumeManager.addManager(this);

			dispatchVolumeChangeEvent();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function dispatchVolumeChangeEvent():void {
			if (_globalControl) {
				// This is global, so update the global SoundTransform
				SoundMixer.soundTransform = getSoundTransform();
			}
			dispatchEvent(new Event(EVENT_CHANGE_VOLUME));
		}

		public function getSoundTransform(): SoundTransform {
			// Get a generic sound transform for sounds
			return new SoundTransform(_volume * (1-_mute), _panning);
		}

		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------

		public static function addManager(__manager:VolumeManager):void {
			managers.push(__manager);
		}

		public static function getManager(__name:String = null, __autoCreate:Boolean = true): VolumeManager {
			// Search on the list of existing sound instances
			for (var i:int = 0; i < managers.length; i++) {
				if (managers[i].name == __name) return managers[i];
			}

			// Not found
			// If allowed to create a single instance, just create and return it
			if (__autoCreate) {
				return new VolumeManager(__name);
			}

			// Otherwise, not found
			return null;
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get volume():Number {
			return _volume;
		}
		public function set volume(__value:Number):void {
			if (_volume != __value) {
				_volume = __value;
				dispatchVolumeChangeEvent();
			}
		}

		public function get mute():Number {
			return _mute;
		}
		public function set mute(__value:Number):void {
			if (_mute != __value) {
				_mute = __value;
				dispatchVolumeChangeEvent();
			}
		}

		public function get name():String {
			return _name;
		}
	}
}