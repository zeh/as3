package com.zehfernando.math.equations {

	import com.zehfernando.math.equations.operations.BasicOperation;
	import com.zehfernando.math.equations.operations.functions.CosFunctionOperation;
	import com.zehfernando.math.equations.operations.functions.RoundFunctionOperation;
	import com.zehfernando.math.equations.operations.functions.SinFunctionOperation;
	import com.zehfernando.math.equations.operations.modifiers.NegativeModifierOperation;
	import com.zehfernando.math.equations.operations.modifiers.PositiveModifierOperation;
	import com.zehfernando.math.equations.operations.operators.AddOperation;
	import com.zehfernando.math.equations.operations.operators.DivideOperation;
	import com.zehfernando.math.equations.operations.operators.ModOperation;
	import com.zehfernando.math.equations.operations.operators.MultiplyOperation;
	import com.zehfernando.math.equations.operations.operators.ParenthesisCloseOperation;
	import com.zehfernando.math.equations.operations.operators.ParenthesisOpenOperation;
	import com.zehfernando.math.equations.operations.operators.PowerOperation;
	import com.zehfernando.math.equations.operations.operators.SubtractOperation;
	import com.zehfernando.utils.console.error;
	import com.zehfernando.utils.console.log;
	/**
	 * @author zeh at zehfernando.com
	 */
	public class EquationInterpreter {

		// Interprets equations to be used by the game
		// http://en.wikipedia.org/wiki/Abstract_syntax_tree
		// http://en.wikipedia.org/wiki/Shunting_yard_algorithm#Detailed_example
		// http://en.wikipedia.org/wiki/Order_of_operations
		
		// Constants
		protected static const CHARS_IGNORED:String = " \r\n\t";
		protected static const CHARS_NUMBERS:String = "1234567890.";
		
		// Properties
		protected var _equation:String;			// Actual equation
		protected var _tokenizedEquation:Array;
		protected var _result:Number;			// Cached result
		
		protected var _areResultsInvalid:Boolean;		// If true, variables changed and tokens need to be recalculated
		protected var _areTokensInvalid:Boolean;		// If true, equation changed and tokens need to be reorganized
		protected var _isEquationInvalid:Boolean;		// Equation iss invalid due to error; result is wrong
		protected var variables:Object;
		protected var functions:Object;
		protected var operators:Object;
		protected var modifiers:Object;
		protected var _errorMessage:String;
		protected var _errorChar:int;

		// ================================================================================================================
		// CONSTRUCTOR ----------------------------------------------------------------------------------------------------

		public function EquationInterpreter(__equation:String) {
			_equation = __equation;
			_result = 0;
			_areResultsInvalid = true;
			_areTokensInvalid = true;
			_errorMessage = "";
			_errorChar = 0;
			
			variables = {
				pi:Math.PI
			};

			functions = {
				sin: new SinFunctionOperation(),
				cos: new CosFunctionOperation(),
				round: new RoundFunctionOperation()
			};
			
			modifiers = {
				"-": new NegativeModifierOperation(),
				"+": new PositiveModifierOperation()
			};
			
			operators = {
				"+": new AddOperation(),
				"-": new SubtractOperation(),
				"*": new MultiplyOperation(),
				"/": new DivideOperation(),
				"%": new ModOperation(),
				"^": new PowerOperation(),
				")": new ParenthesisCloseOperation(),
				"(": new ParenthesisOpenOperation()
			};
		}
		
		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected function retokenize():void {
			// Finds the token order again
			
			log("Judging -> " + _equation + " <---------------------");
			var i:int, j:int;
			
			// Do it as in http://en.wikipedia.org/wiki/Shunting_yard_algorithm#Detailed_example
			var valueTokens:Array = [];
			var operatorTokens:Vector.<BasicOperation> = new Vector.<BasicOperation>();
			var collectedString:String = "";
			var char:String;
			
			_isEquationInvalid = false;
			
			var HAS_NUMBER:Boolean = false;
			var HAS_STRING:Boolean = false;
			var HAS_PARENTHESIS:Boolean = false;
			var HAS_WHITESPACE:Boolean = false;
//			var LAST_PUSHED:String = "";
//			
//			const TYPE_NUMBER = "number";
//			const TYPE_STRING = "string";
			
			_errorMessage = "";
			_errorChar = 0;
			
			for (i = 0; i < +_equation.length; i++) {
				char = _equation.substr(i, 1);
				
				if (CHARS_IGNORED.indexOf(char) >= 0) {
					// Whitespace
					//log("    ignored");
					HAS_WHITESPACE = true;
				} else if (CHARS_NUMBERS.indexOf(char) >= 0) {
					// A real number
					log ("  NUMBER @ "+i+" --> [" + char + "], hasNumber = " + HAS_NUMBER + ", hasString = " + HAS_STRING +", hasWhiteSpace = " + HAS_WHITESPACE);

					if (HAS_NUMBER && HAS_WHITESPACE) {
						registerError(i, "Invalid whitespace between numbers");
						break;
					}
					if (HAS_STRING) {
						registerError(i, "Invalid number mixed with variable");
						break;
					}
					collectedString += char;
					HAS_NUMBER = true;
					HAS_WHITESPACE = false;
				} else if (operators.hasOwnProperty(char)) {
					// An operand
					log ("  OPERATOR @ "+i+" --> [" + char + "], hasNumber = " + HAS_NUMBER + ", hasString = " + HAS_STRING +", hasWhiteSpace = " + HAS_WHITESPACE);
					if (operators[char] is ParenthesisOpenOperation) {
						HAS_PARENTHESIS = false;
						pushToOperatorTokens(valueTokens, operatorTokens, operators[char]);
						if (HAS_NUMBER) {
							registerError(i, "Open parenthesis with no operator after a number");
							break;
						} else if (HAS_STRING) {
							// Had a string (which was probably a function)
							pushToOperatorTokens(valueTokens, operatorTokens, functions[collectedString]);
							collectedString = "";
							HAS_STRING = false;
						}
					} else if (operators[char] is ParenthesisCloseOperation) {
						HAS_PARENTHESIS = true;
						if (HAS_NUMBER || HAS_STRING) pushToValueTokens(valueTokens, collectedString, HAS_NUMBER);
						pushToOperatorTokens(valueTokens, operatorTokens, operators[char]);
						collectedString = "";
						HAS_NUMBER = false;
						HAS_STRING = false;
					} else if (HAS_NUMBER) {
						// Completed number
						pushToValueTokens(valueTokens, collectedString, HAS_NUMBER);
						pushToOperatorTokens(valueTokens, operatorTokens, operators[char]);
						collectedString = "";
						HAS_NUMBER = false;
					} else if (HAS_STRING) {
						// Completed string, check for variables
						if (variables.hasOwnProperty(collectedString)) {
							pushToValueTokens(valueTokens, collectedString, HAS_NUMBER);
							pushToOperatorTokens(valueTokens, operatorTokens, operators[char]);
							collectedString = "";
							HAS_STRING = false;
						} else {
							registerError(i, "Unknown variable [" + collectedString + "]");
							break;
						}
					} else if (HAS_PARENTHESIS) {
						pushToOperatorTokens(valueTokens, operatorTokens, operators[char]);
						collectedString = "";
						HAS_PARENTHESIS = false;
					} else if (modifiers.hasOwnProperty(char)) {
						pushToOperatorTokens(valueTokens, operatorTokens, modifiers[char]);
					} else {
						registerError(i, "Operand " + char + " before a number or variable");
						break;
					}
				} else {
					log ("  STRING @ "+i+" --> [" + char + "], hasNumber = " + HAS_NUMBER + ", hasString = " + HAS_STRING +", hasWhiteSpace = " + HAS_WHITESPACE);
					if (HAS_STRING && HAS_WHITESPACE) {
						registerError(i, "Invalid whitespace between variables");
						break;
					}
					if (HAS_NUMBER) {
						registerError(i, "Invalid variable mixed with number");
						break;
					}
					collectedString += char;
					HAS_STRING = true;
					HAS_WHITESPACE = false;
				}
			}
			
			// Completes current value, if needed
			if (collectedString.length > 0) {
				pushToValueTokens(valueTokens, collectedString, HAS_NUMBER);
			}
			
			// Pop rest of operation stack to values
			for (i = 0; i < operatorTokens.length; i++) {
				valueTokens.push(operatorTokens[i]);
			}
			
			log ("DONE; value tokens = " + valueTokens);
			log ("DONE; operator tokens = " + operatorTokens);

			_tokenizedEquation = valueTokens;
			_areTokensInvalid = false;
		}
		
		protected function pushToValueTokens(__valueTokens:Array, __value:String, __isNumber:Boolean):void {
			if (__isNumber) {
				// Number
				__valueTokens.push(parseFloat(__value));
			} else {
				// Variable
				__valueTokens.push(__value);
			}
			log("  --> push to values: "+__value + " =====> " + __valueTokens);
		}

		protected function pushToOperatorTokens(__valueTokens:Array, __operatorTokens:Vector.<BasicOperation>, __operator:BasicOperation):void {
			var pos:int = 0;
			var i:int;
			
			if (__operator.precedence >= 0) {
				for (i = 0; i < __operatorTokens.length; i++) {
					if (__operatorTokens[i].precedence >= __operator.precedence && __operatorTokens[i] != __operator) {
						__valueTokens.push(__operatorTokens[i]);
						log("  --> push to values: "+__operatorTokens[i] + " =====> " + __valueTokens);
						__operatorTokens.splice(i, 1);
						log("  --> pop from operators: (same) =====> " + __operatorTokens);
						pos = i;
						i--;
					} else if (__operatorTokens[i].precedence < __operator.precedence) {
						pos = i;
						break;
					}
				}
			}

			if (__operator is ParenthesisCloseOperation) {
				// Goes back until the next parenthesis open
				var closedParenthesis:Boolean = false;
				while (__operatorTokens.length > 0) {
					if (__operatorTokens[0] is ParenthesisOpenOperation) {
						__operatorTokens.splice(0, 1);
						closedParenthesis = true;
						break;
					} else {
						__valueTokens.push(__operatorTokens[0]);
						__operatorTokens.splice(0, 1);
					}
				}
				if (!closedParenthesis) {
					registerError(-1, "Unnecessary closing parenthesis");
				} else {
					log ("  --> complete push to operators: values = " + __valueTokens + ", operators = " + __operatorTokens);
				}
			} else {
				__operatorTokens.splice(i, 0, __operator);
				log("  --> push to operators: "+__operator + " @ " + i + " =====> " + __operatorTokens);
			}
		}
		
		protected function registerError(__position:int, __message:String):void {
			_errorMessage = __message;
			_errorChar = __position;
			error("Error parsing: " + __message + " [at col " + __position + "]");
			_isEquationInvalid = true;
		}
		
		protected function recalculate():void {
			// Reads the tokenized equation and gets the result

			if (_isEquationInvalid || _tokenizedEquation.length == 0) {
				_result = 0;
				_areResultsInvalid = false;
			}

			var values:Vector.<Number> = new Vector.<Number>();
			
			var i:int, j:int;
			var t:Object;
			var val:Number;
			var isValid:Boolean = true;
			
			_result = 0;
			
			for (i = 0; i < _tokenizedEquation.length; i++) {
				//log(" vals == " + values);
				t = _tokenizedEquation[i];
				if (t is Number) {
					values.push(t);
					//log("     number = " + t);
				} else if (t is BasicOperation) {
					var numParams:int = (t as BasicOperation).numParameters;
					if (values.length < numParams) {
						registerError(-1, "Not enough values for equation token (" + numParams + " required, had "+values.length+"): " + t);
						isValid = false;
						break;
					} else {
						//log("     operation = " + t);
						//var params:Array = values.slice(values.length-1-numParams, values.length-1);
						var params:Array = [];
						for (j = 0; j < numParams; j++) params.push(values[values.length-numParams+j]);
						//values[values.length-2], values[values.length-1]
						val = (t as BasicOperation).operate.apply(this, params);
						//val = (t as BasicOperation).operate(values[values.length-2], values[values.length-1]);
						values.splice(values.length-numParams, numParams);
						values.push(val);
					}
				} else if (t is String && variables.hasOwnProperty(t)) {
					// It's a variable
					values.push(variables[t]);
				} else {
					registerError(-1, "Found invalid token when reading equation: " + t);
					isValid = false;
					break;
				}
			}
			
			//log("1============> " + ( 4 + 4 * 2 / ( 1 - 5 ) ^ 2 ^ 3));
			//log("2============> " + _result);
			
			if (isValid) {
				if (values.length > 0) {
					_result = values[0];
				} else {
					registerError(-1, "Equation has no valid tokens -- too short?");
				}
			} else {
				_isEquationInvalid = true;
			}

			//log("============> " + _result);

			_areResultsInvalid = false;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public function setVariable(__variable:String, __value:Number):void {
			// Sets the current value of a given variable
			_areResultsInvalid = true;
			variables[__variable] = __value;
		}

		public function getResult():Number {
			if (_areTokensInvalid) retokenize();
			if (_areResultsInvalid) recalculate();
			return _result;
		}
		
		// ================================================================================================================
		// ACCESSOR INTERFACE ---------------------------------------------------------------------------------------------

		public function get equation():String {
			return _equation;
		}
		public function set equation(__value:String):void {
			if (_equation != __value) {
				_equation = __value;
				_areTokensInvalid = true;
				_areResultsInvalid = true;
			}
		}

		public function get errorMessage():String {
			return _errorMessage;
		}

		public function get errorChar():int {
			return _errorChar;
		}

		public function get isEquationInvalid():Boolean {
			return _isEquationInvalid;
		}

	}
}


