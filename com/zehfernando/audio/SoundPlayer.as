package com.zehfernando.audio {


	/**
	 * @author zeh
	 */
	public class SoundPlayer {

		// Properties
		protected static var sounds:Vector.<SoundItemInfo>;

		// ================================================================================================================
		// STATIC CONSTRUCTOR ---------------------------------------------------------------------------------------------

		// Cannot initialize vectors of internal classes on the static init block (internal classes don't exist yet?), so this won't work :(
//		{
//
//			sounds = new Vector.<SoundItemInfo>();
//		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		// Todo: use instances instead?

		protected static function init():void {
			if (!Boolean(sounds)) sounds = new Vector.<SoundItemInfo>();
		}

		protected static function getSoundIndex(__class:Class):Number {
			init();
			for (var i:Number = 0; i < sounds.length; i++) {
				if (sounds[i].isOfType(__class)) return i;
			}
			return NaN;
		}

		// Public API -----------------------------------------------------------------------------------------------------

		public static function playSound(__soundClass:Class, __loops:Number = 0, __volume:Number = 1, __pan:Number = 0, __startTime:Number = 0):void {
			init();
			var sii:SoundItemInfo = new SoundItemInfo(__soundClass);
			sii.volume = __volume;
			sii.pan = __pan;
			sii.play(__startTime, __loops);
			sounds.push(sii);
		}

		public static function pauseSound(__class:Class):void {
			var i:Number = getSoundIndex(__class);
			if (!isNaN(i)) sounds[i].pause();
		}

		public static function resumeSound(__class:Class):void {
			var i:Number = getSoundIndex(__class);
			if (!isNaN(i)) sounds[i].resume();
		}

		public static function stopSound(__class:Class):void {
			var i:Number = getSoundIndex(__class);
			if (!isNaN(i)) {
				sounds[i].dispose();
				sounds.splice(i, 1);
			}
		}

		public static function setSoundVolume(__class:Class, __volume:Number):void {
			var i:Number = getSoundIndex(__class);
			if (!isNaN(i)) sounds[i].volume = __volume;
		}

		public static function getSoundVolume(__class:Class):Number {
			var i:Number = getSoundIndex(__class);
			if (!isNaN(i)) return sounds[i].volume;
			return NaN;
		}
	}
}

import com.zehfernando.audio.SoundPlayer;

import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

class SoundItemInfo {

	// Properties
	protected var _sound:Sound;
	protected var _class:Class;
	protected var _channel:SoundChannel;
	protected var _transform:SoundTransform;

	protected var _volume:Number;
	protected var _pan:Number;

	protected var _pauseTime:Number;
	protected var _isPlaying:Boolean;

	protected var _loops:Number;

	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function SoundItemInfo(__soundClass:Class) {
		_class = __soundClass;
		_sound = new _class();

		_volume = 1;
		_pan = 0;

		updateSoundTransform();
	}

	// ================================================================================================================
	// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

	protected function updateSoundTransform():void {
		_transform = new SoundTransform(_volume, _pan);
	}

	protected function updateVolume():void {
		if (_isPlaying && Boolean(_channel)) {
			_channel.soundTransform = _transform;
		}
	}

	protected function destroyChannel():void {
		if (Boolean(_channel)) {
			_channel.stop();
			_channel = null;
		}
	}


	// ================================================================================================================
	// EVENT INTERFACE ------------------------------------------------------------------------------------------------

	protected function onSoundCompleteRemove(e:Event):void {
		SoundPlayer.stopSound(_class);
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function isOfType(__soundClass:Class):Boolean {
		//return _sound is __soundClass;
		return _class == __soundClass;
	}

	public function play(__startTime:Number = 0, __loops:Number = 0):void {
		if (!_isPlaying) {
			_channel = _sound.play(__startTime, __loops, _transform);
			_loops = __loops;
			if (_loops == 0 && Boolean(_channel)) {
			 	_channel.addEventListener(Event.SOUND_COMPLETE, onSoundCompleteRemove, false, 0, true);
			}
			_isPlaying = true;
		}
	}

	public function pause():void {
		if (_isPlaying) {
			_pauseTime = Boolean(_channel) ? _channel.position : 0;
			stop();
		}
	}

	public function resume():void {
		if (!_isPlaying) {
			play(_pauseTime, _loops); // TODO: this is wrong because it restarts loops in case a sound is paused after the first loop
		}
	}

	public function stop():void {
		if (_isPlaying) {
			destroyChannel();
			_isPlaying = false;
		}

	}

	public function dispose():void {
		stop();
	}

	// ================================================================================================================
	// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

	public function get volume():Number {
		return _volume;
	}
	public function set volume(__value:Number):void {
		if (_volume != __value) {
			_volume = __value;
			updateSoundTransform();
			updateVolume();
		}
	}

	public function get pan():Number {
		return _pan;
	}
	public function set pan(__value:Number):void {
		if (_pan != __value) {
			_pan = __value;
			updateSoundTransform();
			updateVolume();
		}
	}
}