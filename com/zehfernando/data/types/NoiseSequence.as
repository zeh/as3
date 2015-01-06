package com.zehfernando.data.types {
	import com.zehfernando.utils.RandomGenerator;
	/**
	 * @author zeh fernando
	 */
	public class NoiseSequence {

		// Actually, a pseudo-noise sequence that is always repeatable and tileable (on the phase 0-1)

		// Constants
		private static const TWO_PI:Number = Math.PI * 2;

		// Properties
		private var octaves:int;
		private var randoms:Vector.<Number>;
		private var powers:Vector.<int>;

		// Temp vars to reduce garbage collection
		private var r:Number;
		private var v:Number;
		private var i:Number;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function NoiseSequence(__octaves:int = 5, __randomSeed:int = -1) {
			octaves = __octaves;
			randoms = new Vector.<Number>();
			var pos:int = 0;
			while (randoms.length < octaves) randoms.push(RandomGenerator.getFromSeed(__randomSeed < 0 ? -1 : __randomSeed + (pos++)) * TWO_PI);
			powers = new Vector.<int>();
			while (powers.length < octaves) powers.push(Math.pow(2, powers.length));
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function getNumber(__phase:Number):Number {
			// Phase is 0-1

			r = __phase * TWO_PI;

			v = 0;
			for (i = 0; i < octaves; i++) v += Math.sin(r * powers[i] + randoms[i]);
			v /= octaves;

			return v;
		}
	}
}
