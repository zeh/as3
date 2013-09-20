package com.zehfernando.data.types {
	/**
	 * @author zeh fernando
	 */
	public class NoisePlane {

		// Actually, a pseudo-noise sequence that is always repeatable and tileable (on the phase 0-1)

		// Constants
		private static const TWO_PI:Number = Math.PI * 2;

		// Properties
		private var octaves:int;
		private var randoms:Vector.<NoiseSequence>;
		private var powers:Vector.<int>;

		// Temp vars to reduce garbage collection
		private var r:Number;
		private var v:Number;
		private var i:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function NoisePlane(__octaves:int = 5) {
			octaves = __octaves;
			randoms = new Vector.<NoiseSequence>();
			while (randoms.length < octaves) randoms.push(new NoiseSequence(__octaves));
			powers = new Vector.<int>();
			while (powers.length < octaves) powers.push(Math.pow(2, powers.length));
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getNumber(__phaseX:Number, __phaseY:Number):Number {
			// Phase is 0-1

			r = __phaseX * TWO_PI;

			v = 0;
			for (i = 0; i < octaves; i++) v += Math.sin(r * powers[i] + randoms[i].getNumber(__phaseY) * Math.PI);
			v /= octaves;

			return v;
		}
	}
}
