package com.zehfernando.transitions {

	/*
	Disclaimer for Robert Penner's Easing Equations license:
	
	TERMS OF USE - EASING EQUATIONS
	
	Open source under the BSD License.
	
	Copyright © 2001 Robert Penner
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
	
	    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	    * Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	*/

	/**
	 * @author Zeh Fernando - z at zeh.com.br
	 * Based on Robert Penner's easing equations - remade from Tweener's equations but SIMPLIFIED
	 * Not fully tested!
	 */
	public class Equations {
		
		// Constants
		protected static const HALF_PI:Number = Math.PI/2;
		protected static const TWO_PI:Number = Math.PI * 2;
		
		// ================================================================================================================
		// EQUATIONS ------------------------------------------------------------------------------------------------------
				
		/**
		 * Easing equation function for a simple linear tweening, with no easing.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function none(t:Number): Number {
			return t;
		}
	
		/**
		 * Easing equation function for a quadratic (t^2) easing in: accelerating from zero velocity.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function quadIn(t:Number): Number {
			return t*t;
		}
	
		/**
		 * Easing equation function for a quadratic (t^2) easing out: decelerating to zero velocity.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function quadOut(t:Number): Number {
			return -t * (t-2);
		}

		/**
		 * Easing equation function for a quadratic (t^2) easing in and then out: accelerating from zero velocity, then decelerating.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function quadInOut(t:Number): Number {
			//return t < 0.5 ? quadIn(t*2) : quadOut((t-0.5)*2);
			return ((t *= 2) < 1) ? t * t * 0.5 : -0.5 * (--t * (t-2) - 1);
		}

		/**
		 * Easing equation function for a cubic (t^3) easing in: accelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function cubicIn(t:Number): Number {
			return t*t*t;
		}
	
		/**
		 * Easing equation function for a cubic (t^3) easing out: decelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function cubicOut(t:Number): Number {
			return (t = t-1) * t * t + 1;
		}

		public static function cubicInOut(t:Number): Number {
			return (t *= 2) < 1 ? cubicIn(t)/2 : cubicOut(t-1)/2+0.5; // TODO: redo with in-line calculation
		}
	
		/**
		 * Easing equation function for a quartic (t^4) easing in: accelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function quartIn(t:Number): Number {
			return t*t*t*t;
		}
	
		/**
		 * Easing equation function for a quartic (t^4) easing out: decelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function quartOut(t:Number): Number {
			t--;
			return -1 * (t * t * t * t - 1);
		}
	
		public static function quartInOut(t:Number): Number {
			return (t *= 2) < 1 ? quartIn(t)/2 : quartOut(t-1)/2+0.5; // TODO: redo with in-line calculation
		}

		/**
		 * Easing equation function for a quintic (t^5) easing in: accelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function quintIn(t:Number): Number {
			return t*t*t*t*t;
		}
	
		/**
		 * Easing equation function for a quintic (t^5) easing out: decelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function quintOut(t:Number): Number {
			t--;
			return t*t*t*t*t + 1;
		}

		public static function quintInOut(t:Number): Number {
			return (t *= 2) < 1 ? quintIn(t)/2 : quintOut(t-1)/2+0.5; // TODO: redo with in-line calculation
		}

		/**
		 * Easing equation function for a sinusoidal (sin(t)) easing in: accelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function sineIn(t:Number): Number {
			return -1 * Math.cos(t * HALF_PI) + 1;
		}
	
		/**
		 * Easing equation function for a sinusoidal (sin(t)) easing out: decelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function sineOut(t:Number): Number {
			return Math.sin(t * HALF_PI);
		}

		public static function sineInOut(t:Number): Number {
			return (t *= 2) < 1 ? sineIn(t)/2 : sineOut(t-1)/2+0.5; // TODO: redo with in-line calculation
		}

		/**
		 * Easing equation function for an exponential (2^t) easing in: accelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function expoIn(t:Number): Number {
			// return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b; // original
			// return (t==0) ? 0 : Math.pow(2, 10 * (t - 1)); // ztween
			// return (t == 0) ? b : c * Math.pow(2, 10 * (t / d - 1)) + b - c * 0.001; // tweener fixed
			return (t==0) ? 0 : Math.pow(2, 10 * (t - 1)) - 0.001; // ztween fixed
		}
	
		/**
		 * Easing equation function for an exponential (2^t) easing out: decelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function expoOut(t:Number): Number {
			// return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b; // original
			// return (t==1) ? 1 : (-Math.pow(2, -10 * t) + 1); // ztween
			// return (t == d) ? b + c : c * 1.001 * (-Math.pow(2, -10 * t / d) + 1) + b; // tweener fixed
			return (t==1) ? 1 : 1.001 * (-Math.pow(2, -10 * t) + 1); // ztween fixed
		}

		public static function expoInOut(t:Number): Number {
			return (t *= 2) < 1 ? expoIn(t)/2 : expoOut(t-1)/2+0.5; // TODO: redo with in-line calculation
		}

		/**
		 * Easing equation function for a circular (sqrt(1-t^2)) easing in: accelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function circIn(t:Number): Number {
			return -1 * (Math.sqrt(1 - t*t) - 1);
		}
	
		/**
		 * Easing equation function for a circular (sqrt(1-t^2)) easing out: decelerating from zero velocity.
 		 *
		 * @param	t			Current time/phase (0-1).
		 * @return				The new value/phase (0-1).
		 */
		public static function circOut(t:Number): Number {
			t--;
			return Math.sqrt(1 - t*t);
		}

		public static function circInOut(t:Number): Number {
			return (t *= 2) < 1 ? circIn(t)/2 : circOut(t-1)/2+0.5; // TODO: redo with in-line calculation
		}

		/**
		 * Easing equation function for an elastic (exponentially decaying sine wave) easing in: accelerating from zero velocity.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @param	a			Amplitude.
		 * @param	p			Period.
		 * @return				The new value/phase (0-1).
		 */
		public static function elasticIn(t:Number, a:Number = 0, p:Number = 0.3): Number {
			if (t==0) return 0;
			if (t==1) return 1;
			var s:Number;
			if (a < 1) {
				a = 1;
				s = p/4;
			} else {
				s = p/TWO_PI * Math.asin (1/a);
			}
			return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t-s)*TWO_PI/p));
		}
	
		/**
		 * Easing equation function for an elastic (exponentially decaying sine wave) easing out: decelerating from zero velocity.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @param	a			Amplitude.
		 * @param	p			Period.
		 */
		public static function elasticOut(t:Number, a:Number = 0, p:Number = 0.3): Number {
			if (t==0) return 0;
			if (t==1) return 1;
			var s:Number;
			if (a < 1) {
				a = 1;
				s = p/4;
			} else {
				s = p/TWO_PI * Math.asin (1/a);
			}
			return (a*Math.pow(2,-10*t) * Math.sin( (t-s)*p/TWO_PI/p ) + 1);
		}
	
		/**
		 * Easing equation function for a back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing in: accelerating from zero velocity.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @param	s			Overshoot ammount: higher s means greater overshoot (0 produces cubic easing with no overshoot, and the default value of 1.70158 produces an overshoot of 10 percent).
		 * @param	p			Period.
		 */
		public static function backIn(t:Number, s:Number = 1.70158): Number {
			return t*t*((s+1)*t - s);
		}
	
		/**
		 * Easing equation function for a back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing out: decelerating from zero velocity.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @param	s			Overshoot ammount: higher s means greater overshoot (0 produces cubic easing with no overshoot, and the default value of 1.70158 produces an overshoot of 10 percent).
		 * @param	p			Period.
		 */
		public static function backOut(t:Number, s:Number = 1.70158): Number {
			t--;
			return t*t*((s+1)*t + s) + 1;
		}

		public static function backInOut(t:Number): Number {
			return (t *= 2) < 1 ? backIn(t)/2 : backOut(t-1)/2+0.5; // TODO: redo with in-line calculation
		}
	
		/**
		 * Easing equation function for a bounce (exponentially decaying parabolic bounce) easing in: accelerating from zero velocity.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @param	p			Period.
		 */
		public static function bounceIn(t:Number): Number {
			return 1 - bounceOut(1-t);
		}
	
		/**
		 * Easing equation function for a bounce (exponentially decaying parabolic bounce) easing out: decelerating from zero velocity.
		 *
		 * @param	t			Current time/phase (0-1).
		 * @param	p			Period.
		 */
		public static function bounceOut(t:Number): Number {
			if (t < (1/2.75)) {
				return 7.5625*t*t;
			} else if (t < (2/2.75)) {
				return 7.5625*(t-=(1.5/2.75))*t + .75;
			} else if (t < (2.5/2.75)) {
				return 7.5625*(t-=(2.25/2.75))*t + .9375;
			} else {
				return 7.5625*(t-=(2.625/2.75))*t + .984375;
			}
		}


		// ================================================================================================================
		// COMBINATOR -----------------------------------------------------------------------------------------------------

		public static function combined(t:Number, __equations:Array): Number {
			var l:int = __equations.length; 
			var eq:int = int(t * l);
			if (eq == __equations.length) eq = l - 1;
			//trace (t, eq, t * l - eq);
			return Number(__equations[eq](t * l - eq));
		}
	}
}
