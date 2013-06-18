package com.zehfernando.data.serialization.json {
	/**
	 * @author zeh
	 */
	public class JSON {

		// Constants
		protected static const VALUE_BOOLEAN_TRUE:String = "true";
		protected static const VALUE_BOOLEAN_FALSE:String = "false";

		protected static const VALUE_STRING_START:String = "\"";
		protected static const VALUE_STRING_END:String = "\"";

		protected static const KEY_START:String = "\"";
		protected static const KEY_END:String = "\"";

		protected static const VALUE_ARRAY_START:String = "[";
		protected static const VALUE_ARRAY_END:String = "]";
		protected static const VALUE_ARRAY_ITEM_SEPARATOR:String = ",";

		protected static const VALUE_OBJECT_START:String = "{";
		protected static const VALUE_OBJECT_END:String = "}";
		protected static const VALUE_OBJECT_ITEM_SEPARATOR:String = ",";

		protected static const SEPARATOR_KEY_VALUE:String = " : ";

		protected static const VALUE_NULL:String = "null";

		protected static const SEPARATOR_INLINE:String = " ";
		protected static const SEPARATOR_NEWLINE:String = "\n";

		protected static const INDENT_ONE:String = "    ";


		// Internal constants, used when parsing
		protected static const PARSING_TYPE_UNKNOWN:String = "";
		protected static const PARSING_TYPE_VALUE_OBJECT_PRE_ITEM:String = "objectPreItem";
		protected static const PARSING_TYPE_VALUE_OBJECT_POST_ITEM:String = "objectPostItem";
		protected static const PARSING_TYPE_VALUE_ARRAY_PRE_ITEM:String = "arrayPreItem";
		protected static const PARSING_TYPE_VALUE_ARRAY_POST_ITEM:String = "arrayPostItem";
		protected static const PARSING_TYPE_VALUE_STRING:String = "string";
		protected static const PARSING_TYPE_VALUE_NUMBER:String = "number";
		protected static const PARSING_TYPE_KEY_NAME:String = "keyName";
		protected static const PARSING_TYPE_POST_KEY_NAME:String = "postKeyName";

		// ================================================================================================================
		// INTERNAL INTERFACE ---------------------------------------------------------------------------------------------

		protected static function encodeObject(__input:Object, __allowCarriageReturn:Boolean = true, __indentLevel:Number = 0):String {
			// Depending on type, does a different thing

			var txt:String = "";
			var i:int;
			var iis:String;

			var hasItemsInList:Boolean = false;

			if (__input is String) {
				// It's a String
				txt += VALUE_STRING_START + encodeString(__input as String) + VALUE_STRING_END;
			} else if (__input is Number) {
				// It's a Number
				txt += (__input as Number).toString(10);
			} else if (__input === true || __input === false) {
				// It's a Boolean
				txt += __input ? VALUE_BOOLEAN_TRUE : VALUE_BOOLEAN_FALSE;
			} else if (__input === null) {
				// it's a null object
				txt += VALUE_NULL;
			} else if (__input is Array) {
				// It's an array
				txt += VALUE_ARRAY_START;
				for (i = 0; i < (__input as Array).length; i++) {
					if (hasItemsInList) {
						txt += VALUE_ARRAY_ITEM_SEPARATOR;
					}

					txt += __allowCarriageReturn ? SEPARATOR_NEWLINE + getIndents(__indentLevel+1) : SEPARATOR_INLINE;

					txt += encodeObject(__input[i], __allowCarriageReturn, __indentLevel + 1);

					hasItemsInList = true;
				}

				txt += __allowCarriageReturn ? SEPARATOR_NEWLINE + getIndents(__indentLevel) : SEPARATOR_INLINE;
				txt += VALUE_ARRAY_END;
			} else {
				// It's an object
				txt += VALUE_OBJECT_START;
				for (iis in __input) {
					if (hasItemsInList) {
						txt += VALUE_OBJECT_ITEM_SEPARATOR;
					}

					txt += __allowCarriageReturn ? SEPARATOR_NEWLINE + getIndents(__indentLevel+1) : SEPARATOR_INLINE;

					txt += KEY_START + iis + KEY_END + SEPARATOR_KEY_VALUE + encodeObject(__input[iis], __allowCarriageReturn, __indentLevel + 1);

					hasItemsInList = true;
				}

				txt += __allowCarriageReturn ? SEPARATOR_NEWLINE + getIndents(__indentLevel) : SEPARATOR_INLINE;
				txt += VALUE_OBJECT_END;
			}

			return txt;
		}

		protected static function decodeObject(__input:String): ParsedJSONValue {
			var i:int;
			var c:String;

			var returnObject:ParsedJSONValue = new ParsedJSONValue();

			var parsingType:String = PARSING_TYPE_UNKNOWN;
			var parsingObject:Object = null;
			var parsingName:String;

			var parsedObject:ParsedJSONValue;

			i = 0;

			var mustEnd:Boolean = false;

			while (i < __input.length && !mustEnd) {
				c = __input.charAt(i);

				switch (parsingType) {
					case PARSING_TYPE_UNKNOWN:
						switch (c) {
							case "{":
								// Starting object
								//trace ("-> starting object @ ",__input.length-i);
								parsingType = PARSING_TYPE_VALUE_OBJECT_PRE_ITEM;
								parsingObject = {};
								break;
							case "[":
								// Starting array
								//trace ("-> starting array @ ",__input.length-i);
								parsingType = PARSING_TYPE_VALUE_ARRAY_PRE_ITEM;
								parsingObject = [];

								break;
							case "\"":
								// Starting string
//								trace ("-> starting string @ ",__input.length-i);
								parsingType = PARSING_TYPE_VALUE_STRING;
								parsingObject = "";
								break;
							case "0":
							case "1":
							case "2":
							case "3":
							case "4":
							case "5":
							case "6":
							case "7":
							case "8":
							case "9":
							case "-":
								// Starting number
//								trace ("-> starting number @ ",__input.length-i);
								parsingType = PARSING_TYPE_VALUE_NUMBER;
								parsingObject = c;
								break;
							case VALUE_NULL.charAt(0):
								// Starting "null"
//								trace ("-> starting null @ ",__input.length-i);

								if (compareStringValue(VALUE_NULL, __input.substr(i))) {
//									trace ("-> ending null @ ",__input.length-i);
									mustEnd = true;
									returnObject.object = null;
									returnObject.length = i+VALUE_NULL.length;
								}

								break;
							case VALUE_BOOLEAN_TRUE.charAt(0):
								// Starting "true"
//								trace ("-> starting boolean [true] @ ",__input.length-i);

								if (compareStringValue(VALUE_BOOLEAN_TRUE, __input.substr(i))) {
//									trace ("-> ending boolean [true] @ ",__input.length-i);
									mustEnd = true;
									returnObject.object = true;
									returnObject.length = i+VALUE_BOOLEAN_TRUE.length;
								}

								break;
							case VALUE_BOOLEAN_FALSE.charAt(0):
								// Starting "false"
//								trace ("-> starting boolean [false] @ ",__input.length-i);

								if (compareStringValue(VALUE_BOOLEAN_FALSE, __input.substr(i))) {
//									trace ("-> ending boolean [false] @ ",__input.length-i);
									mustEnd = true;
									returnObject.object = false;
									returnObject.length = i+VALUE_BOOLEAN_FALSE.length;
								}

								break;
						}
						break;
					case PARSING_TYPE_VALUE_STRING:
						switch(c) {
							case '"':
								// Ended string
//								trace ("-> ending string ["+parsingObject+"] @ ",__input.length-i);
								mustEnd = true;

								returnObject.object = parsingObject as String;
								returnObject.length = i+1;

								break;
							case "\\":
								// Some special character
								if (i < __input.length - 1) {
									var nc:String = c = __input.charAt(i+1);
									switch (nc) {
										case "\"":
											parsingObject += "\"";
											i++;
											break;
										case "\\":
											parsingObject += "\\";
											i++;
											break;
										case "/":
											parsingObject += "/";
											i++;
											break;
										case "b":
											parsingObject += "\b";
											i++;
//											if ((parsingObject as String).length > 0) {
//												parsingObject = (parsingObject as String).substr(0, (parsingObject as String).length-1);
//											}
											break;
										case "f":
											parsingObject += "\f";
											i++;
											break;
										case "n":
											parsingObject += "\n";
											i++;
											break;
										case "t":
											parsingObject += "\t";
											i++;
											break;
										case "r":
											parsingObject += "\r";
											i++;
											break;
										case "u":
											i++;
											if (i < __input.length - 5) {
												parsingObject += String.fromCharCode(parseInt("0x" + __input.substr(i+1, 4)));
												i += 4;
											}
											break;
									}
								}
								break;
							default:
								// Continued string
								parsingObject += c;
						}
						break;
					case PARSING_TYPE_VALUE_NUMBER:
						switch(c) {
							case "0":
							case "1":
							case "2":
							case "3":
							case "4":
							case "5":
							case "6":
							case "7":
							case "8":
							case "9":
							case ".":
							case "e":
							case "E":
								// Contined number
								parsingObject += c;
								break;
							default:
								// Ended number
//								trace ("-> ending number ["+parsingObject+"] @ ",__input.length-i);
								mustEnd = true;

								returnObject.object = parseFloat(parsingObject as String);
								returnObject.length = i;

								break;
						}
						break;
					case PARSING_TYPE_VALUE_OBJECT_PRE_ITEM:
						switch(c) {
							case "}":
								// Empty object?
								parsingType = PARSING_TYPE_VALUE_OBJECT_POST_ITEM;
								i--;
								break;
							case '"':
								// Starting a key name
//								trace ("  --> starting a key name @ ",__input.length-i);
								parsingName = "";
								parsingType = PARSING_TYPE_KEY_NAME;
								break;
						}
						break;
					case PARSING_TYPE_VALUE_OBJECT_POST_ITEM:
						switch(c) {
							case ",":
								// Starting a new object
//								trace("  --> starting a new object object @ ", i);
								parsingType = PARSING_TYPE_VALUE_OBJECT_PRE_ITEM;
								break;
							case "}":
								// Ending object
//								trace ("-> ending object @ ",__input.length-i);

								mustEnd = true;

								returnObject.object = parsingObject;
								returnObject.length = i+1;

								break;
							default:
								// ...
						}
						break;
					case PARSING_TYPE_VALUE_ARRAY_PRE_ITEM:
						switch(c) {
							case "]":
								// Empty array?
								//trace("  --> ending empty array @ " + i);
								parsingType = PARSING_TYPE_VALUE_ARRAY_POST_ITEM;
								i--;
								break;
							case " ":
							case "\r":
							case "\n":
							case "\t":
								// Whitespace elements
								break;
							default:
								// Everything that comes after is a new value that must be added to this object
								parsedObject = decodeObject(__input.substr(i));

								i += parsedObject.length-1;
								(parsingObject as Array).push(parsedObject.object);

								parsingType = PARSING_TYPE_VALUE_ARRAY_POST_ITEM;
						}
						break;
					case PARSING_TYPE_VALUE_ARRAY_POST_ITEM:
						switch(c) {
							case ",":
								// Starting a new object
//								trace("  --> starting a new array object @ ", i);
								parsingType = PARSING_TYPE_VALUE_ARRAY_PRE_ITEM;
								break;
							case "]":
								// Ending array
								//trace ("-> ending array @ " + i);
								mustEnd = true;

								returnObject.object = parsingObject;
								returnObject.length = i+1;

								break;
							default:
								// ...
						}
						break;
					case PARSING_TYPE_KEY_NAME:
						switch(c) {
							case '"':
								// Ending a key name
//								trace ("  --> ending a key name ["+parsingName+"] @ ",__input.length-i);
								parsingType = PARSING_TYPE_POST_KEY_NAME;
								break;
							default:
								parsingName += c;
						}
						break;
					case PARSING_TYPE_POST_KEY_NAME:
						switch(c) {
							case ":":
//								trace ("  --> found colon @ ",__input.length-i);

								// Everything that comes after is a new value that must be added to this object
								parsedObject = decodeObject(__input.substr(i));

								i += parsedObject.length-1;
								parsingObject[parsingName] = parsedObject.object;

								parsingType = PARSING_TYPE_VALUE_OBJECT_POST_ITEM;
								parsingName = null;

								break;
							default:
								// ...
						}
						break;
				}


				i++;
			}

			return returnObject;
		}

		protected static function compareStringValue(__value:String, __text:String):Boolean {
			return __value.length <= __text.length && __text.substr(0, __value.length) == __value;
		}

		/*
		protected static function decodeObjectOld(__input:String): Object {
			var i:int;
			var c:String;

			var parsingTypes:Vector.<String> = new Vector.<String>();
			var parsingObjects:Vector.<Object> = new Vector.<Object>();
			var parsingNames:Vector.<String> = new Vector.<String>();

			const TYPE_UNKNOWN:String = "";
			const TYPE_VALUE_OBJECT:String = "object";
			const TYPE_VALUE_ARRAY:String = "array";
			const TYPE_VALUE_STRING:String = "string";
			const TYPE_VALUE_NUMBER:String = "number";
			const TYPE_KEY_NAME:String = "keyName";
			const TYPE_POST_KEY_NAME:String = "postKeyName";

			var finalStringValue:String;
			var finalNumberValue:Number;
			var finalObject:Object;
			var finalArray:Array;

			parsingTypes.push(TYPE_UNKNOWN);
			parsingObjects.push(null);

			// This may be slow?

			i = 0;
			while (i < __input.length) {
				c = __input.charAt(i);

				switch (parsingTypes[parsingTypes.length-1]) {
					case TYPE_UNKNOWN:
						switch (c) {
							case "{":
								// Starting object
								trace ("-> starting object @ ",i);
								parsingTypes[parsingTypes.length-1] = TYPE_VALUE_OBJECT;
								parsingObjects[parsingObjects.length-1] = {};
								break;
							case "[":
								// Starting array
								trace ("-> starting array @ ",i);
								parsingTypes[parsingTypes.length-1] = TYPE_VALUE_ARRAY;
								parsingObjects[parsingObjects.length-1] = [];

								parsingTypes.push(TYPE_UNKNOWN);
								parsingObjects.push(null);

								break;
							case "\"":
								// Starting string
								trace ("-> starting string @ ",i);
								parsingTypes[parsingTypes.length-1] = TYPE_VALUE_STRING;
								parsingObjects[parsingObjects.length-1] = "";
								break;
							case "0":
							case "1":
							case "2":
							case "3":
							case "4":
							case "5":
							case "6":
							case "7":
							case "8":
							case "9":
							case "-":
								// Starting number
								trace ("-> starting number @ ",i);
								parsingTypes[parsingTypes.length-1] = TYPE_VALUE_NUMBER;
								parsingObjects[parsingObjects.length-1] = c;
								break;
							case VALUE_NULL.charAt(0):
								// Starting null
								trace ("-> starting null @ ",i);
								parsingTypes[parsingTypes.length-1] = TYPE_VALUE_NUMBER;
								parsingObjects[parsingObjects.length-1] = c;
								break;
						}
						break;
					case TYPE_VALUE_STRING:
						switch(c) {
							case '"':
								// Ended string
								parsingTypes.pop();

								finalStringValue = parsingObjects.pop();
								trace ("-> ending string ["+finalStringValue+"] @ ",i);
								trace ("==========> new = " + parsingTypes);

								switch (parsingTypes[parsingTypes.length-1]) {
									case TYPE_VALUE_OBJECT:
										trace ("  + adding to object");
										parsingObjects[parsingObjects.length-1][parsingNames.pop()] = finalStringValue;
										break;
									case TYPE_VALUE_ARRAY:
										trace ("  + adding to array");
										(parsingObjects[parsingObjects.length-1] as Array).push(finalStringValue);
										break;
								}

								break;
							default:
								// Continued string
								parsingObjects[parsingObjects.length-1] += c;
						}
						break;
					case TYPE_VALUE_NUMBER:
						switch(c) {
							case "0":
							case "1":
							case "2":
							case "3":
							case "4":
							case "5":
							case "6":
							case "7":
							case "8":
							case "9":
							case ".":
							case "e":
							case "E":
								// Contined number
								parsingObjects[parsingObjects.length-1] += c;
								break;
							default:
								// Ended number
								parsingTypes.pop();

								finalNumberValue = parseFloat((parsingObjects.pop() as String));
								trace ("-> ending number ["+finalNumberValue+"] @ ",i);
								trace ("==========> new = " + parsingTypes);

								switch (parsingTypes[parsingTypes.length-1]) {
									case TYPE_VALUE_OBJECT:
										trace ("  + adding to object");
										parsingObjects[parsingObjects.length-1][parsingNames.pop()] = finalNumberValue;
										break;
									case TYPE_VALUE_ARRAY:
										trace ("  + adding to array");
										(parsingObjects[parsingObjects.length-1] as Array).push(finalNumberValue);
										break;
								}

								break;
						}
						break;
					case TYPE_VALUE_OBJECT:
						switch(c) {
							case '"':
								// Starting a key name
								trace ("  --> starting a key name @ ",i);
								parsingNames.push("");
								parsingTypes.push(TYPE_KEY_NAME);
								parsingObjects.push(null);
								break;
							case "}":
								// Ending object
								parsingTypes.pop();
								finalObject = parsingObjects.pop();

								trace ("-> ending object @ ",i);
								trace ("==========> new = " + parsingTypes);
								trace ("==========> new = " + parsingObjects);

								if (parsingTypes.length == 0) {
									// Ended everything
									return finalObject;
								}

								switch (parsingTypes[parsingTypes.length-1]) {
									case TYPE_VALUE_OBJECT:
										trace ("  + adding to object");
										parsingObjects[parsingObjects.length-1][parsingNames.pop()] = finalObject;
										break;
									case TYPE_VALUE_ARRAY:
										trace ("  + adding to array");
										(parsingObjects[parsingObjects.length-1] as Array).push(finalObject);
										break;
								}

								break;
							default:
								// ...
						}
						break;
					case TYPE_VALUE_ARRAY:
						switch(c) {
							case ",":
								// Starting a new object
								trace("  --> starting a new array object @ ", i);
								parsingTypes.push(TYPE_UNKNOWN);
								parsingObjects.push(null);
								break;
							case "]":
								// Ending array
								parsingTypes.pop();
								finalArray = parsingObjects.pop();

								trace ("-> ending array @ ",i);
								trace ("==========> new = " + parsingTypes);

								switch (parsingTypes[parsingTypes.length-1]) {
									case TYPE_VALUE_OBJECT:
										trace ("  + adding to object");
										parsingObjects[parsingObjects.length-1][parsingNames.pop()] = finalArray;
										break;
									case TYPE_VALUE_ARRAY:
										trace ("  + adding to array");
										(parsingObjects[parsingObjects.length-1] as Array).push(finalArray);
										break;
								}

								break;
							default:
								// ...
						}
						break;
					case TYPE_KEY_NAME:
						switch(c) {
							case '"':
								// Ending a key name
								trace ("  --> ending a key name ["+parsingNames[parsingNames.length-1]+"] @ ",i);
								parsingTypes[parsingTypes.length-1] = TYPE_POST_KEY_NAME;
								break;
							default:
								parsingNames[parsingNames.length-1] += c;
						}
						break;
					case TYPE_POST_KEY_NAME:
						switch(c) {
							case ":":
								trace ("  --> found colon @ ",i);
								parsingTypes[parsingTypes.length-1] = TYPE_UNKNOWN;
								break;
							default:
								// ...
						}
						break;
//					case TYPE_POST_KEY_COLON:
//						switch(c) {
//							case '"':
//								parsingType[parsingType.length-1] = TYPE_VALUE_STRING;
//								break;
//							case '"':
//								parsingType[parsingType.length-1] = TYPE_VALUE_STRING;
//								break;
//							default:
//								// ...
//						}
//						break;
				}


				i++;
			}

			return null;
		}
		*/

		protected static function getIndents(__indentLevel:int):String {
			var txt:String = "";
			while (__indentLevel-- > 0) txt += JSON.INDENT_ONE;
			return txt;
		}

		// ================================================================================================================
		// PUBLIC INTERFACE -----------------------------------------------------------------------------------------------

		public static function decode(__input:String): Object {
			return decodeObject(__input).object;
		}

		public static function encode(__input:Object, __allowCarriageReturn:Boolean = true):String {
			return encodeObject(__input, __allowCarriageReturn);
		}

		public static function encodeString(__string:String):String {
			var t:String = "";
			var i:int;
			var c:String;
			var charCode:int;

			for (i = 0; i < __string.length; i++) {
				c = __string.charAt(i);
				switch (c) {
					case "\"":
						t += "\\\"";
						break;
					case "\\":
						t += "\\\\";
						break;
					case "\\/":
						t += "/";
						break;
					case "\b":
						t += "\\b";
						break;
					case "\f":
						t += "\\f";
						break;
					case "\n":
						t += "\\n";
						break;
					case "\r":
						t += "\\r";
						break;
					case "\t":
						t += "\\t";
						break;
					default:
						charCode = c.charCodeAt(0);
						//if (charCode < 32) {
						if (charCode > 127 || charCode < 32) {
							// Special code
							t += "\\u" + ("0000" + charCode.toString(16)).substr(-4, 4);
						} else {
							// Normal char
							t += c;
						}
				}
			}

			return t;
		}
	}
}

class ParsedJSONValue {

	public var object:Object;
	public var length:int;

	public function ParsedJSONValue():void {
		object = {};
		length = 0;
	}

//	public function getObjectAsString():String {
//		return object as String;
//	}
//
//	public function getObjectAsNumber():Number {
//		return parseFloat(getObjectAsString());
//	}

//	public function getObjectAsArray(): Array {
//		return object as Array;
//	}

}