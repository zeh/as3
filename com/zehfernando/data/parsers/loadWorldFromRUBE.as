package com.zehfernando.data.parsers {
	import Box2D.Collision.Shapes.b2CircleShape;
	import Box2D.Collision.Shapes.b2EdgeShape;
	import Box2D.Collision.Shapes.b2MassData;
	import Box2D.Collision.Shapes.b2PolygonShape;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2BodyDef;
	import Box2D.Dynamics.b2FilterData;
	import Box2D.Dynamics.b2FixtureDef;
	import Box2D.Dynamics.b2World;

	import com.zehfernando.utils.console.log;
	/**
	 * @author zeh fernando
	 */

	public function loadWorldFromRUBE(__rubeScene:Object):b2World {
		// Creates a world with data from a JSON Object parsed from R.U.B.E
		// https://www.iforce2d.net/rube/json-structure

		var i:int, j:int, k:int;

		// World
		var world:b2World = new b2World(getB2Vec2FromProperty(__rubeScene, "gravity"), getBooleanFromProperty(__rubeScene, "allowSleep"));

		// TODO: "autoClearForces": true, // Information only - for Step()
		// TODO: "positionIterations": 3,  // Information only - for Step()
		// TODO: "velocityIterations": 8,  // Information only - for Step()
		// TODO: "stepsPerSecond": 60, // Information only - for Step()
		world.SetWarmStarting(getBooleanFromProperty(__rubeScene, "warmStarting"));
		world.SetContinuousPhysics(getBooleanFromProperty(__rubeScene, "continuousPhysics"));
		// TODO: "subStepping": false,

		// Bodies
		var bodies:Array = getArrayFromProperty(__rubeScene, "body");
		var bodyDef:b2BodyDef;
		var body:b2Body;
		var massData:b2MassData;
		var fixtureDef:b2FixtureDef;
		var fixtures:Array;
		var filterData:b2FilterData;
		var circleShape:b2CircleShape;
		var polygonShape:b2PolygonShape;
		var edgeShape:b2EdgeShape;
		var vertices:Vector.<b2Vec2>;
		for (i = 0; i < bodies.length; i++) {

			// Body definition
			bodyDef = new b2BodyDef();
			// TODO: "name": "dynamicbody4",
			bodyDef.type				= getIntegerFromProperty(bodies[i], "type"); // 0 = static, 1 = kinematic, 2 = dynamic
			bodyDef.angle				= getFloatFromProperty(bodies[i], "angle"); // Radians
			bodyDef.angularDamping		= getFloatFromProperty(bodies[i], "angularDamping");
			bodyDef.angularVelocity		= getFloatFromProperty(bodies[i], "angularVelocity"); // Radians per second
			bodyDef.awake				= getBooleanFromProperty(bodies[i], "awake");
			bodyDef.bullet				= getBooleanFromProperty(bodies[i], "bullet");
			bodyDef.fixedRotation		= getBooleanFromProperty(bodies[i], "fixedRotation");
			bodyDef.linearDamping		= getFloatFromProperty(bodies[i], "linearDamping");
			bodyDef.linearVelocity		= getB2Vec2FromProperty(bodies[i], "linearVelocity");
			bodyDef.position			= getB2Vec2FromProperty(bodies[i], "position");

			// Mass definition
			massData = new b2MassData();
			massData.mass				= getFloatFromProperty(bodies[i], "massData-mass");
			massData.center				= getB2Vec2FromProperty(bodies[i], "massData-center");
			massData.I					= getFloatFromProperty(bodies[i], "massData-I");

			// Create body
			body = world.CreateBody(bodyDef);
			body.SetMassData(massData);

			// Create fixtures
			fixtures = getArrayFromProperty(bodies[i], "fixture");
			for (j = 0; j < fixtures.length; j++) {
				// Fixture definition
				fixtureDef = new b2FixtureDef();
				// TODO: "name": "fixture4",
				fixtureDef.density		= getFloatFromProperty(fixtures[j], "density");
				fixtureDef.friction		= getFloatFromProperty(fixtures[j], "friction");
				fixtureDef.restitution	= getFloatFromProperty(fixtures[j], "restitution");
				fixtureDef.isSensor		= getBooleanFromProperty(fixtures[j], "sensor");

				// Filter definition
				filterData = new b2FilterData();
				filterData.categoryBits	= getIntegerFromProperty(fixtures[j], "categoryBits", 1);
				filterData.maskBits		= getIntegerFromProperty(fixtures[j], "maskBits", 65535);
				filterData.groupIndex	= getIntegerFromProperty(fixtures[j], "groupIndex");
				fixtureDef.filter = filterData;

				// Shape
				if ((fixtures[j] as Object).hasOwnProperty("circle")) {
					// Circle shape object
					circleShape = new b2CircleShape();
					circleShape.SetRadius(getFloatFromProperty(fixtures[j]["circle"], "radius"));
					// TODO: "center": (vector)
					fixtureDef.shape = circleShape;
				} else if ((fixtures[j] as Object).hasOwnProperty("polygon")) {
					// Polygon shape object
					polygonShape = new b2PolygonShape();
					vertices = getB2Vec2VectorFromProperty(fixtures[j]["polygon"], "vertices");
					polygonShape.SetAsVector(vertices, vertices.length);
					fixtureDef.shape = polygonShape;
				} else if ((fixtures[j] as Object).hasOwnProperty("chain")) {
					// Chain shape object, or edge
					vertices = getB2Vec2VectorFromProperty(fixtures[j]["chain"], "vertices");

					// Edge shape is not working = use a polygon shape
					polygonShape = new b2PolygonShape();
					if (vertices.length == 2) {
						// It's an edge
						polygonShape.SetAsEdge(vertices[0], vertices[1]);
						fixtureDef.shape = polygonShape;
					}
					//edgeShape = new b2EdgeChainDef();
					// TODO: everything
					//"vertices": (vector array),
					////If the following properties are not present, the shape is an open-ended 
					////chain shape. If they are present, the shape is a closed loop shape.
					//"hasNextVertex": true, 
					//"hasPrevVertex": true, 
					//"nextVertex": (vector), 
					//"prevVertex": (vector)
				} else {
					trace("No fixture type found!");
				}

				// Create fixture
				body.CreateFixture(fixtureDef);

				// TODO: customProperties
//				[{
//                  "name": "respawn_timeout", 
//                  "float": 2.5
//                },]
			}

			// TODO: customProperties
//				[{
//                  "name": "respawn_timeout", 
//                  "float": 2.5
//                },]

//			bodyDef = new b2BodyDef();
//			bodyDef.type = b2Body.b2_dynamicBody;
//			bodyDef.position.x = 2;
//			bodyDef.position.y = 2;
//			body = world.CreateBody(bodyDef);
//
		}

		// TODO: image
		// TODO: joint
		// TODO: collisionbitplanes

		log ("Loaded");

		return world;
	}

}
import Box2D.Common.Math.b2Vec2;

import com.zehfernando.utils.console.log;

function getArrayFromProperty(__object:Object, __propertyName:String):Array {
	var defaultValue:Array = [];
	if (!Boolean(__object)) return defaultValue;
	if (!__object.hasOwnProperty(__propertyName)) return defaultValue;
	if (!__object[__propertyName] is Array) return defaultValue;
	return __object[__propertyName];
}

function getBooleanFromProperty(__object:Object, __propertyName:String, __default:Boolean = false):Boolean {
	// Default is always false, because of R.U.B.E.'s JSON structure, even for properties that are true by default
	if (!Boolean(__object)) return __default;
	if (!__object.hasOwnProperty(__propertyName)) return __default;
	return __object[__propertyName] === true;
}

function getB2Vec2FromProperty(__object:Object, __propertyName:String):b2Vec2 {
	var defaultValue:b2Vec2 = new b2Vec2(0, 0);
	if (!Boolean(__object)) return defaultValue.Copy();
	if (!__object.hasOwnProperty(__propertyName)) return defaultValue.Copy();
	if (__object[__propertyName] === 0) return new b2Vec2(0, 0); // Not necessarily the same value
	return new b2Vec2(getFloatFromProperty(__object[__propertyName], "x") * getXScale(), getFloatFromProperty(__object[__propertyName], "y") * getYScale());
	// TODO: invert everything?
}

function getB2Vec2VectorFromProperty(__object:Object, __propertyName:String):Vector.<b2Vec2> {
	// This is needed because "vertices" is an object with an array of x and an array of y
	var vectors:Vector.<b2Vec2> = new Vector.<b2Vec2>();
	if (Boolean(__object) && __object.hasOwnProperty(__propertyName)) {
		var xArray:Array = __object[__propertyName]["x"] as Array;
		var yArray:Array = __object[__propertyName]["y"] as Array;
		if (Boolean(xArray) && Boolean(yArray)) {
			var i:int;
			for (i = 0; i < xArray.length && i < yArray.length; i++) {
				vectors.push(new b2Vec2(xArray[i] * getXScale(), yArray[i] * getYScale()));
			}
		}
	}
	return vectors;
}

function getFloatFromProperty(__object:Object, __propertyName:String, __default:Number = 0):Number {
	if (!Boolean(__object)) return __default;
	if (!__object.hasOwnProperty(__propertyName)) return __default;
	if (isNaN(__object[__propertyName])) return __default;
	if (__object[__propertyName] is String) {
		// TODO: Properties that are expected to be numerical but are strings should be interpreted as the hexadecimal
		// representation of a 32-bit floating point number. This is done to preserve accuracy and decrease file size
		// (average case). See the floatToHex/hexToFloat functions in the b2dJson source code for an implementation of
		// converting these in C++. (You can disable the saving of floating point numbers as hexadecimal under the File
		// tab of the Options dialog.)
		log("Hex number! Parse properly!=====> " + __object[__propertyName]);
		return parseInt(__object[__propertyName], 16);
	}
	return __object[__propertyName];
}

function getIntegerFromProperty(__object:Object, __propertyName:String, __default:int = 0):int {
	if (!Boolean(__object)) return __default;
	if (!__object.hasOwnProperty(__propertyName)) return __default;
	if (isNaN(__object[__propertyName])) return __default;
	return __object[__propertyName];
}

function getYScale():Number {
	return 1;
}

function getXScale():Number {
	return 1;
}


