package com.zehfernando.transitions {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;

	/**
	 * @author Zeh Fernando
	 */
	public class ZTween {

		/*
		Versions
		1.3.2	2010-09-07	fixed: stupid bug on onStart/onComplete/onUpdate getter/setters
		1.3.1				added onStartParams, onUpdateParams, onCompleteParams
		1.2.1				signals now have getters
		1.2.0				using signals for onStart/onUpdate/onComplete
		1.1.0				made the secondary parameters (time, transition, delay) into an object
		1.0.0
		*/
		
		// Static properties
		public static var currentTime:int;					// The current time. This is generic for all tweenings for a "time grid" based update
		public static var currentTimeFrame:int;				// The current frame. Used on frame-based tweenings

		protected static var eventContainer:Sprite;				// Event container
		protected static var tweens:Vector.<ZTween> = new Vector.<ZTween>();				// List of active tweens
//		protected static var tt:Vector.<ZTween>;											// Temp tween list

		// Properties
		protected var _target					:Object;		// Object affected by this tweening
		protected var properties				:Vector.<ZTweenProperty>;		// List of properties that are tweened
		protected var numProps					:int;

		protected var timeStart					:int;			// Time when this tweening should start
		protected var timeCreated				:int;			// Time when this tweening was created
		protected var timeComplete				:int;			// Time when this tweening should end
		protected var timeDuration				:int;			// Time this tween takes (cache)
		protected var transition				:Function;		// Equation to control the transition animation
		//private var transitionParams			:Object;		// Additional parameters for the transition
		//private var rounded					:Boolean;		// Use rounded values when updating
		protected var timePaused				:int;			// Time when this tween was paused
		//private var skipUpdates				:uint;			// How many updates should be skipped (default = 0; 1 = update-skip-update-skip...)
		//private var updatesSkipped			:uint;			// How many updates have already been skipped
		protected var started					:Boolean;		// Whether or not this tween has already started executing
		
		protected var _onStart					:ZTweenSignal;
		protected var _onUpdate					:ZTweenSignal;
		protected var _onComplete				:ZTweenSignal;

		// External properties
		protected var _paused					:Boolean;		// Whether or not this tween is currently paused
		protected var _useFrames				:Boolean;		// Whether or not to use frames instead of seconds
		
		// Temporary variables to avoid disposal
		protected var t							:Number;		// Current time (0-1)
		protected var tProperty					:ZTweenProperty;	// Property being checked
		protected var pv						:Number;		// Property value
		protected var i							:int;			// Loop iterator
		protected var cTime						:int;			// Current engine time (in frames or seconds)
		
		// Temp vars
		protected static var i:uint;
		protected static var l:uint;
		
		// ================================================================================================================
		// STATIC PSEUDO-CONSTRUCTOR --------------------------------------------------------------------------------------

		{
			init();
		}
		
		protected static function init(): void {
			// Starts the engine
		//	tweens = new Vector.<ZTween>(); // This can't be here, so it's moved to the property initialization
			
			eventContainer = new Sprite();
			eventContainer.addEventListener(Event.ENTER_FRAME, frameTick);
			
			currentTimeFrame = 0;
			currentTime = getTimer();
		}
	
		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		/**
		 * Creates a new Tween.
		 *
		 * @param	p_scope				Object		Object that this tweening refers to.
		 */
		public function ZTween(__target:Object, __properties:Object = null, __parameters:Object = null) {
			
			_target				=	__target;

			properties			=	new Vector.<ZTweenProperty>();
			for (var pName:String in __properties) {
				properties.push(new ZTweenProperty(pName, __properties[pName]));
				//addProperty(pName, __properties[pName]);
			}
			numProps = properties.length;

			timeCreated			=	currentTime;
			timeStart			=	timeCreated;

			// Parameters
			time				=	0;
			delay				=	0;
			transition			=	Equations.none;

			_onStart			=	new ZTweenSignal();
			_onUpdate			=	new ZTweenSignal();
			_onComplete			=	new ZTweenSignal();
			
			// Read parameters
			if (Boolean(__parameters)) {
				pv = __parameters["time"];
				if (pv is Number && !isNaN(pv)) time = pv;
				
				pv = __parameters["delay"];
				if (pv is Number && !isNaN(pv)) delay = pv;
	
				if (Boolean(__parameters["transition"])) transition = __parameters["transition"];
				
				if (Boolean(__parameters["onStart"])) _onStart.add(__parameters["onStart"], __parameters["onStartParams"]);
				if (Boolean(__parameters["onUpdate"])) _onUpdate.add(__parameters["onUpdate"], __parameters["onUpdateParams"]);
				if (Boolean(__parameters["onComplete"])) _onComplete.add(__parameters["onComplete"], __parameters["onCompleteParams"]);
			}
			//transitionParams	=	new Array();

			_useFrames			=	false;
			
			_paused				=	false;
			//skipUpdates		=	0;
			//updatesSkipped	=	0;
			started				=	false;
		}

		// ================================================================================================================
		// INTERNAL functions ---------------------------------------------------------------------------------------------

		protected function updateCache(): void {
			timeDuration = timeComplete - timeStart;
		}


		// ==================================================================================================================================
		// ENGINE functions -----------------------------------------------------------------------------------------------------------------
	
		/**
		 * Updates all existing tweenings.
		 */
		protected static function updateTweens(): void {
			//trace ("updateTweens");
			
			l = tweens.length;
			for (i = 0; i < l; i++) { // ++i had no impact, must test more
				if (!Boolean(tweens[i]) || !tweens[i].update(currentTime, currentTimeFrame)) {
					tweens.splice(i, 1);
					i--;
					l--;
				}
			}
		}

		/**
		 * Ran once every frame. It's the main engine; updates all existing tweenings.
		 */
		protected static function frameTick(e:Event):void {
			// Update time
			currentTime = getTimer();
			
			// Update frame
			currentTimeFrame++;
			
			// Update all tweens
			updateTweens();
		}


		// ================================================================================================================
		// PUBLIC STATIC functions ----------------------------------------------------------------------------------------

		/**
		 * Create a new tweening for an object and starts it.
		 */
		public static function add(__target:Object, __properties:Object = null, __parameters:Object = null): ZTween {
			var t:ZTween = new ZTween(__target, __properties, __parameters);
			tweens.push(t);
			return t;
		}

		/**
		 * Remove tweenings for a given object from the active tweening list.
		 */
		/*
		public static function remove(__target:Object, ...__args): Boolean {
			// Create the list of valid property list
			//var properties:Vector.<String> = new Vector.<String>();
			//l = args["length"];
			//for (i = 0; i < l; i++) {
			//	properties.push(args[i]);
			//}
			
			// Call the affect function on the specified properties
			return affectTweens(removeTweenByIndex, __target, __args);
		}
		*/

		public static function remove(__target:Object, ...__props): Boolean {
			// TODO: mark for removal, but don't remove immediately
			//var tl:Vector.<ZTween> = getTweens(__target, __props);

			var tl:Vector.<ZTween> = new Vector.<ZTween>();
			
			var l:int = tweens.length;
			var i:int;
			var j:int;
			// TODO: use filter?

			for (i = 0; i < l; i++) {
				if (Boolean(tweens[i]) && tweens[i]._target == __target) {
					if (__props.length > 0) {
						for (j = 0; j < tweens[i].properties.length; j++) {
							if (__props.indexOf(tweens[i].properties[j].name) > -1) {
								tweens[i].properties.splice(j, 1);
								j--;
							}
						}
						if (tweens[i].properties.length == 0) tl.push(tweens[i]);
					} else {
						tl.push(tweens[i]);
					}
				}
			}

			var removedAny:Boolean;
			
			l = tl.length;

			for (i = 0; i < l; i++) {
				j = tweens.indexOf(tl[i]);
				removeTweenByIndex(j);
				removedAny = true;
			}
			
			return removedAny;
		}

		public static function hasTween(__target:Object, ...__props): Boolean {
			//return (getTweens.apply(([__target] as Array).concat(__props)) as Vector.<ZTween>).length > 0;

			var l:int = tweens.length;
			var i:int;
			var j:int;
			// TODO: use filter?

			for (i = 0; i < l; i++) {
				if (Boolean(tweens[i]) && tweens[i]._target == __target) {
					if (__props.length > 0) {
						for (j = 0; j < tweens[i].properties.length; j++) {
							if (__props.indexOf(tweens[i].properties[j].name) > -1) {
								return true;
							}
						}
					} else {
						return true;
					}
				}
			}
			
			return false;

		}

		public static function getTweens(__target:Object, ...__props): Vector.<ZTween> {
			var tl:Vector.<ZTween> = new Vector.<ZTween>();
			
			var l:int = tweens.length;
			var i:int;
			var j:int;
			var found:Boolean = false;
			// TODO: use filter?

			//trace ("ZTween :: getTweens() :: getting tweens for "+__target+", "+__props+" ("+__props.length+" properties)");

			for (i = 0; i < l; i++) {
				if (Boolean(tweens[i]) && tweens[i]._target == __target) {
					if (__props.length > 0) {
						found = false;
						for (j = 0; j < tweens[i].properties.length; j++) {
							if (__props.indexOf(tweens[i].properties[j].name) > -1) {
								found = true;
								break;
							}
						}
						if (found) tl.push(tweens[i]);
					} else {
						tl.push(tweens[i]);
					}
				}
			}

			return tl;
		}
		
		public static function pause(__target:Object, ...__props): Boolean {
			var pausedAny:Boolean = false;
			
			var ftweens:Vector.<ZTween> = getTweens.apply(null, [__target].concat(__props));
			var i:int;
			
			//trace ("ZTween :: pause() :: pausing tweens for " + __target + ": " + ftweens.length + " actual tweens");
					
			// TODO: use filter/apply?
			for (i = 0; i < ftweens.length; i++) {
				if (!ftweens[i].paused) {
					ftweens[i].pause();
					pausedAny = true;
				}
			}
			
			return pausedAny;
		}

		public static function resume(__target:Object, ...__props): Boolean {
			var resumedAny:Boolean = false;
			
			var ftweens:Vector.<ZTween> = getTweens.apply(null, [__target].concat(__props));
			var i:int;
			
			// TODO: use filter/apply?
			for (i = 0; i < ftweens.length; i++) {
				if (ftweens[i].paused) {
					ftweens[i].resume();
					resumedAny = true;
				}
			}
			
			return resumedAny;
		}

		/**
		 * Remove a specific tweening from the tweening list.
		 *
		 * @param		p_tween				Number		Index of the tween to be removed on the tweenings list
		 * @return							Boolean		Whether or not it successfully removed this tweening
		 */
		public static function removeTweenByIndex(__i:Number): void {
			//__finalRemoval:Boolean = false
			tweens[__i] = null;
			//if (__finalRemoval) tweens.splice(__i, 1);
			//tweens.splice(__i, 1);
			//return true;
		}

		/**
		 * Do some generic action on specific tweenings (pause, resume, remove, more?)
		 *
		 * @param		__function			Function	Function to run on the tweenings that match
		 * @param		__target			Object		Object that must have its tweens affected by the function
		 * @param		__properties		Array		Array of strings that must be affected
		 * @return							Boolean		Whether or not it successfully affected something
		 */
		/*
		private static function affectTweens (__affectFunction:Function, __target:Object, __properties:Array):Boolean {
			var affected:Boolean = false;
			
			l = tweens.length;
			
			for (i = 0; i < l; i++) {
				if (tweens[i].target == __target) {
					if (__properties.length == 0) {
						// Can affect everything
						__affectFunction(i);
						affected = true;
					} else {
						// Must check whether this tween must have specific properties affected
						var affectedProperties:Array = new Array();
						var j:uint;
						for (j = 0; j < p_properties.length; j++) {
							if (Boolean(_tweenList[i].properties[p_properties[j]])) {
								affectedProperties.push(p_properties[j]);
							}
						}
						if (affectedProperties.length > 0) {
							// This tween has some properties that need to be affected
							var objectProperties:uint = AuxFunctions.getObjectLength(_tweenList[i].properties);
							if (objectProperties == affectedProperties.length) {
								// The list of properties is the same as all properties, so affect it all
								p_affectFunction(i);
								affected = true;
							} else {
								// The properties are mixed, so split the tween and affect only certain specific properties
								var slicedTweenIndex:uint = splitTweens(i, affectedProperties);
								p_affectFunction(slicedTweenIndex);
								affected = true;
							}
						}
					}
				}
			}
			return affected;
		}
		*/

		// ================================================================================================================
		// PUBLIC INSTANCE functions --------------------------------------------------------------------------------------

		// Event interceptors for caching
		public function update(currentTime:int, currentTimeFrame:int): Boolean {
			
			if (_paused) return true;
			
			cTime = _useFrames ? currentTimeFrame : currentTime;

			if (started || cTime >= timeStart) {
				if (!started) {
					_onStart.dispatch();
					
					for (i = 0; i < properties.length; i++) {
						// Property value not initialized yet
						tProperty = ZTweenProperty(properties[i]);
						
						// Directly read property
						pv = _target[tProperty.name];
	
						tProperty.valueStart = isNaN(pv) ? tProperty.valueComplete : pv; // If the property has no value, use the final value as the default
						tProperty.valueChange = tProperty.valueComplete - tProperty.valueStart;
					}
					started = true;
				}
			
				if (cTime >= timeComplete) {
					// Tweening time has finished, just set it to the final value
					for (i = 0; i < properties.length; i++) {
						tProperty = ZTweenProperty(properties[i]);
						_target[tProperty.name] = tProperty.valueComplete;
					}
				
					_onUpdate.dispatch();
					
					_onComplete.dispatch();
					
					return false;
					
				} else {
					// Tweening must continue
					t = transition((cTime - timeStart) / timeDuration);
					for (i = 0; i < numProps; i++) {
						tProperty = ZTweenProperty(properties[i]);
						_target[tProperty.name] = tProperty.valueStart + t * tProperty.valueChange;
					}
					
					_onUpdate.dispatch();
				}
				
			}
			
			return true;

		}
		
		public function pause(): void {
			if (!_paused) {
				_paused = true;
				timePaused = _useFrames ? ZTween.currentTimeFrame : ZTween.currentTime; 
			}
		}
		
		public function resume(): void {
			if (_paused) {
				_paused = false;
				var timeNow:Number = _useFrames ? ZTween.currentTimeFrame : ZTween.currentTime;
				timeStart += timeNow - timePaused;
				timeComplete += timeNow - timePaused;
			}
		}

		
		// ==================================================================================================================================
		// ACESSOR functions ----------------------------------------------------------------------------------------------------------------

		public function get delay(): Number {
			return (timeStart - timeCreated) / (_useFrames ? 1 : 1000);
		}

		public function set delay(__value:Number): void {
			timeStart = timeCreated + (__value * (_useFrames ? 1 : 1000));
			timeComplete = timeStart + timeDuration;
			//updateCache();
			// TODO: take pause into consideration!
		}

		public function get time(): Number {
			return (timeComplete - timeStart) / (_useFrames ? 1 : 1000);
		}

		public function set time(__value:Number): void {
			timeComplete = timeStart + (__value * (_useFrames ? 1 : 1000));
			updateCache();
			// TODO: take pause into consideration!
		}

		public function get paused(): Boolean {
			return _paused;
		}

		/*
		public function set paused(p_value:Boolean): void {
			if (p_value == _paused) return;
			_paused = p_value;
			if (paused) {
				// pause
			} else {
				// resume
			}
		}
		*/

		public function get useFrames(): Boolean {
			return _useFrames;
		}

		public function set useFrames(__value:Boolean): void {
			var tDelay:Number = delay;
			var tTime:Number = time;
			_useFrames = __value;
			timeStart = _useFrames ? currentTimeFrame : currentTime;
			delay = tDelay;
			time = tTime;
		}

		public function get target():Object {
			return _target;
		}
		public function set target(target:Object):void {
			_target = target;
		}
		
		public function get onStart(): ZTweenSignal {
			return _onStart;
		}
		public function get onUpdate(): ZTweenSignal {
			return _onUpdate;
		}
		public function get onComplete(): ZTweenSignal {
			return _onComplete;
		}
	}
}
