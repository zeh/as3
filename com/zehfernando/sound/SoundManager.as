package com.zehfernando.sound {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.media.SoundTransform;

	/**
	 * @author zeh
	 */
	public class SoundManager extends EventDispatcher {

		// Constants
		public static const EVENT_CHANGE_VOLUME:String = "onChangeVolume";

		// Static instances
		protected static var instance:SoundManager;

		// Properties
		protected var _mute:Number;						// 0 (not mute) to 1 (mute). Mute is a separate multiplier, so it can always be toggled and return to the original volume
		protected var _musicVolume:Number;				// 0-1 volume for background music
		protected var _soundFXVolume:Number;			// 0-1 volume for sound effects
		protected var _volume:Number;					// 0-1 master volume
		
		protected var sounds:Vector.<SoundItemInfo>;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function SoundManager(target:IEventDispatcher = null) {
			super(target);

			setInstance(this);

			sounds = new Vector.<SoundItemInfo>;

			_mute = 0;
			_volume = 1;
			_musicVolume = 1;
			_soundFXVolume = 1;
			dispatchVolumeChangeEvent();
		}


		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
		
		protected function dispatchVolumeChangeEvent(): void {
			dispatchEvent(new Event(EVENT_CHANGE_VOLUME));
		}

		protected function getSoundIndex(__class:Class): Number {
			for (var i:Number = 0; i < sounds.length; i++) {
				if (sounds[i].isOfType(__class)) return i;
			}
			return NaN;
		}

		// Public API -----------------------------------------------------------------------------------------------------

		public function playSound(__soundClass:Class, __loops:Number = 0, __volume:Number = 1, __pan:Number = 0, __startTime:Number = 0): void {
			var sii:SoundItemInfo = new SoundItemInfo(__soundClass);
			sii.volume = __volume;
			sii.pan = __pan;
			sii.play(__startTime, __loops);
			sounds.push(sii);
		}

		public function playMusic(__soundClass:Class): void {
			var sii:SoundItemInfo = new SoundItemInfo(__soundClass, true);
			sii.play(0, 999999999);
			sounds.push(sii);
		}

		public function pauseSound(__class:Class): void {
			var i:Number = getSoundIndex(__class);
			if (!isNaN(i)) sounds[i].pause();
		}

		public function resumeSound(__class:Class): void {
			var i:Number = getSoundIndex(__class);
			if (!isNaN(i)) sounds[i].resume();
		}

		public function stopSound(__class:Class): void {
			var i:Number = getSoundIndex(__class);
			if (!isNaN(i)) {
				sounds[i].dispose();
				sounds.splice(i, 1);
			}
		}

		public function getSoundTransform(__isMusic:Boolean = false): SoundTransform {
			// Get a generic sound transform for sounds
			return new SoundTransform(_volume * (1-_mute) * (__isMusic ? _musicVolume : _soundFXVolume));
		}

		/*
		public function getSoundVolume(__linkage:String): Number {
			var i:Number = getSoundIndex(__linkage);
			if (!isNaN(i)) return usedTransforms[i].volume;
			return 0;
		}

		public function setSoundVolume(__linkage:String, __volume:Number): void {
			var i:Number = getSoundIndex(__linkage);
			if (!isNaN(i)) {
				usedTransforms[i].volume = __volume;
				updateVolume(i);
			}
		}
		*/

		// Higher-level API for eased volume control ----------------------------------------------------------------------
		
		// ================================================================================================================
		// STATIC functions -----------------------------------------------------------------------------------------------
		
		public static function setInstance(__instance:SoundManager): void {
			instance = __instance;
		}
		
		public static function getInstance(): SoundManager {
			if (!Boolean(instance)) instance = new SoundManager();
			return instance;
		}

		// ================================================================================================================
		// ACCESSOR functions ---------------------------------------------------------------------------------------------

		public function get volume(): Number {
			return _volume;
		}
		public function set volume(__value:Number): void {
			if (_volume != __value) {
				_volume = __value;
				dispatchVolumeChangeEvent();
			}
		}

		public function get mute(): Number {
			return _mute;
		}
		public function set mute(__value:Number): void {
			if (_mute != __value) {
				_mute = __value;
				dispatchVolumeChangeEvent();
			}
		}

		public function get musicVolume(): Number {
			return _musicVolume;
		}
		public function set musicVolume(__value:Number): void {
			if (_musicVolume != __value) {
				_musicVolume = __value;
				dispatchVolumeChangeEvent();
			}
		}

		public function get soundFXVolume(): Number {
			return _soundFXVolume;
		}
		public function set soundFXVolume(__value:Number): void {
			if (_soundFXVolume != __value) {
				_soundFXVolume = __value;
				dispatchVolumeChangeEvent();
			}
		}

	}
}

import com.zehfernando.sound.SoundManager;

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
	
	protected var _isMusic:Boolean;
	
	protected var _volume:Number;
	protected var _pan:Number;
	
	protected var _pauseTime:Number;
	protected var _isPlaying:Boolean;
	
	protected var _loops:Number;
	
	// ================================================================================================================
	// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

	public function SoundItemInfo(__soundClass:Class, __isMusic:Boolean = false) {
		_class = __soundClass;
		_sound = new _class();
		_isMusic = __isMusic;
		
		_volume = 1;
		_pan = 0;
		
		updateSoundTransform();
		
		SoundManager.getInstance().addEventListener(SoundManager.EVENT_CHANGE_VOLUME, onChangeVolume);
	}

	// ================================================================================================================
	// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------
	
	protected function updateSoundTransform(): void {
		var generalSoundTransform:SoundTransform = SoundManager.getInstance().getSoundTransform(_isMusic);
		_transform = new SoundTransform(_volume * generalSoundTransform.volume, _pan); // TODO: add pan!
	}
	
	protected function updateVolume(): void {
		if (_isPlaying && Boolean(_channel)) {
			_channel.soundTransform = _transform;
		}
	}
	
	protected function destroyChannel(): void {
		if (Boolean(_channel)) {
			_channel.removeEventListener(Event.SOUND_COMPLETE, onSoundCompleteRemove);
			_channel.stop();
			_channel = null;
		}
	}
			
	
	// ================================================================================================================
	// EVENT INTERFACE ------------------------------------------------------------------------------------------------
	
	protected function onChangeVolume(e:Event): void {
		updateSoundTransform();
		updateVolume();
	}
	
	protected function onSoundCompleteRemove(e:Event): void {
		SoundManager.getInstance().stopSound(_class);
	}

	// ================================================================================================================
	// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

	public function isOfType(__soundClass:Class): Boolean {
		//return _sound is __soundClass;
		return _class == __soundClass;
	}

	public function play(__startTime:Number = 0, __loops:Number = 0): void {
		if (!_isPlaying) {
			_channel = _sound.play(__startTime, __loops, _transform);
			_loops = __loops;
			if (_loops == 0 && Boolean(_channel)) {
			 	_channel.addEventListener(Event.SOUND_COMPLETE, onSoundCompleteRemove);
			}
			_isPlaying = true;
		}
	}
	
	public function pause(): void {
		if (_isPlaying) {
			_pauseTime = Boolean(_channel) ? _channel.position : 0;
			stop();
		}
	}

	public function resume(): void {
		if (!_isPlaying) {
			play(_pauseTime, _loops); // TODO: this is wrong because it restarts loops in case a sound is paused after the first loop
		}
	}
	
	public function stop(): void {
		if (_isPlaying) {
			destroyChannel();
			_isPlaying = false;
		}
		
	}
	
	public function dispose(): void {
		stop();
		SoundManager.getInstance().removeEventListener(SoundManager.EVENT_CHANGE_VOLUME, onChangeVolume);
	}

	// ================================================================================================================
	// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

	public function get volume(): Number {
		return _volume;
	}
	public function set volume(__value:Number): void {
		if (_volume != __value) {
			_volume = __value;
			updateSoundTransform();
			updateVolume();
		}
	}
	
	public function get pan(): Number {
		return _pan;
	}
	public function set pan(__value:Number): void {
		if (_pan != __value) {
			_pan = __value;
			updateSoundTransform();
			updateVolume();
		}
	}
}