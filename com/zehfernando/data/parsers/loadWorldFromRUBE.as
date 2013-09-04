package com.zehfernando.data.parsers {
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.b2World;
	/**
	 * @author zeh fernando
	 */

	public function loadWorldFromRUBE(__rubeScene:Object):b2World {
		// Creates a world with data from a JSON Object parsed from R.U.B.E
		// https://www.iforce2d.net/rube/json-structure
		// http://www.iforce2d.net/rube/loaders/javascript/loadrube.js

		var i:int, j:int, k:int;

		// Instance holders
		var worldBodies:Vector.<b2Body> = new Vector.<b2Body>();

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
		var body:b2Body;
		for (i = 0; i < bodies.length; i++) {
			body = loadBodyFromRUBE(bodies[i], world);
			worldBodies.push(body);
		}

		// Joints
		var joints:Array = getArrayFromProperty(__rubeScene, "joint");
		for (i = 0; i < joints.length; i++) {
			loadJointFromRUBE(joints[i], world, worldBodies);
		}

		// TODO: collisionbitplanes

		return world;
	}

}
import Box2D.Collision.Shapes.b2Shape;
import Box2D.Collision.Shapes.b2CircleShape;
import Box2D.Collision.Shapes.b2EdgeShape;
import Box2D.Collision.Shapes.b2MassData;
import Box2D.Collision.Shapes.b2PolygonShape;
import Box2D.Common.Math.b2Vec2;
import Box2D.Dynamics.Joints.b2DistanceJointDef;
import Box2D.Dynamics.Joints.b2FrictionJointDef;
import Box2D.Dynamics.Joints.b2Joint;
import Box2D.Dynamics.Joints.b2JointDef;
import Box2D.Dynamics.Joints.b2PrismaticJointDef;
import Box2D.Dynamics.Joints.b2RevoluteJointDef;
import Box2D.Dynamics.Joints.b2WeldJointDef;
import Box2D.Dynamics.b2Body;
import Box2D.Dynamics.b2BodyDef;
import Box2D.Dynamics.b2FilterData;
import Box2D.Dynamics.b2Fixture;
import Box2D.Dynamics.b2FixtureDef;
import Box2D.Dynamics.b2World;
function loadBodyFromRUBE(__rubeBody:Object, __world:b2World):b2Body {

	// Body definition
	var bodyDef:b2BodyDef = new b2BodyDef();
	bodyDef.type			= getIntegerFromProperty(__rubeBody, "type"); // 0 = static, 1 = kinematic, 2 = dynamic
	bodyDef.angle			= getFloatFromProperty(__rubeBody, "angle"); // Radians
	bodyDef.angularDamping	= getFloatFromProperty(__rubeBody, "angularDamping");
	bodyDef.angularVelocity	= getFloatFromProperty(__rubeBody, "angularVelocity"); // Radians per second
	bodyDef.awake			= getBooleanFromProperty(__rubeBody, "awake");
	bodyDef.bullet			= getBooleanFromProperty(__rubeBody, "bullet");
	bodyDef.fixedRotation	= getBooleanFromProperty(__rubeBody, "fixedRotation");
	bodyDef.linearDamping	= getFloatFromProperty(__rubeBody, "linearDamping");
	bodyDef.linearVelocity	= getB2Vec2FromProperty(__rubeBody, "linearVelocity");
	bodyDef.position		= getB2Vec2FromProperty(__rubeBody, "position");

	// Create body
	var body:b2Body = __world.CreateBody(bodyDef);

	// Mass definition
	var massData:b2MassData = new b2MassData();
	massData.mass			= getFloatFromProperty(__rubeBody, "massData-mass");
	massData.center			= getB2Vec2FromProperty(__rubeBody, "massData-center");
	massData.I				= getFloatFromProperty(__rubeBody, "massData-I");
	body.SetMassData(massData);

	// Custom properties
	body.SetUserData(loadUserDataFromRUBE(__rubeBody));
	body.GetUserData()["name"] = getStringFromProperty(__rubeBody, "name");

	// Create fixtures
	var fixtures:Array = getArrayFromProperty(__rubeBody, "fixture");
	for (var i:int = 0; i < fixtures.length; i++) {
		loadFixtureFromRUBE(fixtures[i], body);
	}

	return body;
}

function loadUserDataFromRUBE(__rubeData:Object):Object {
	var object:Object = {};
	if (Boolean(__rubeData) && __rubeData.hasOwnProperty("customProperties")) {
		var objects:Array = __rubeData["customProperties"] as Array;
		if (objects != null) {
			var name:String;
			var obj:Object;
			for (var i:int = 0; i < objects.length; i++) {
				obj = objects[i];
				name = obj["name"];
				if (obj.hasOwnProperty("float")) {
					// Float
					object[name] = getFloatFromProperty(obj, "float");
				} else if (obj.hasOwnProperty("int")) {
					// Integer
					object[name] = getIntegerFromProperty(obj, "int");
				} else if (obj.hasOwnProperty("string")) {
					// String
					object[name] = getStringFromProperty(obj, "string");
				} else if (obj.hasOwnProperty("bool")) {
					// Boolean
					object[name] = getBooleanFromProperty(obj, "bool");
				} else if (obj.hasOwnProperty("vec2")) {
					// Vector
					object[name] = getB2Vec2FromProperty(obj, "vec2");
				}
			}
		}
	}
	return object;
}

function loadFixtureFromRUBE(__rubeFixture:Object, __body:b2Body):void {
	// Fixture definition
	var fixtureDef:b2FixtureDef = new b2FixtureDef();
	fixtureDef.density		= getFloatFromProperty(__rubeFixture, "density");
	fixtureDef.friction		= getFloatFromProperty(__rubeFixture, "friction");
	fixtureDef.restitution	= getFloatFromProperty(__rubeFixture, "restitution");
	fixtureDef.isSensor		= getBooleanFromProperty(__rubeFixture, "sensor");

	// Filter definition
	var filterData:b2FilterData = new b2FilterData();
	filterData.categoryBits	= getIntegerFromProperty(__rubeFixture, "categoryBits", 1);
	filterData.maskBits		= getIntegerFromProperty(__rubeFixture, "maskBits", 65535);
	filterData.groupIndex	= getIntegerFromProperty(__rubeFixture, "groupIndex");
	fixtureDef.filter		= filterData;

	var circleShape:b2CircleShape;
	var polygonShape:b2PolygonShape;
	var edgeShape:b2EdgeShape;
	var vertices:Vector.<b2Vec2>;

	// Shape
	if ((__rubeFixture as Object).hasOwnProperty("circle")) {
		// Circle shape object
		circleShape = new b2CircleShape();
		circleShape.SetRadius(getFloatFromProperty(__rubeFixture["circle"], "radius"));
		circleShape.SetLocalPosition(getB2Vec2FromProperty(__rubeFixture["circle"], "center"));
		fixtureDef.shape = circleShape;
	} else if ((__rubeFixture as Object).hasOwnProperty("polygon")) {
		// Polygon shape object
		polygonShape = new b2PolygonShape();
		vertices = getB2Vec2VectorFromProperty(__rubeFixture["polygon"], "vertices");
		polygonShape.SetAsVector(vertices, vertices.length);
		fixtureDef.shape = polygonShape;
	} else if ((__rubeFixture as Object).hasOwnProperty("chain")) {
		// Chain shape object, or edge
		vertices = getB2Vec2VectorFromProperty(__rubeFixture["chain"], "vertices");

		// Edge shape is not working = use a polygon shape
		polygonShape = new b2PolygonShape();
		if (vertices.length == 2) {
			// It's an edge
			polygonShape.SetAsEdge(vertices[0], vertices[1]);
			fixtureDef.shape = polygonShape;
		/*
		} else {
			var verticesArray:Array = getB2Vec2ArrayFromProperty(__rubeFixture["chain"], "vertices");
			var edgeChainDef:b2EdgeChainDef = new b2EdgeChainDef();
			edgeChainDef.vertices = verticesArray;
			edgeChainDef.vertexCount = verticesArray.length;
			edgeChainDef.isALoop = false;
			//fixtureDef.shape = __body.crea;
			return;
		*/
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
		trace("loadWorldFromRUBE: could not create fixture from definition.");
	}

	// Create fixture
	var fixture:b2Fixture = __body.CreateFixture(fixtureDef);

	// Custom properties
	fixture.SetUserData(loadUserDataFromRUBE(__rubeFixture));
	fixture.GetUserData()["name"] = getStringFromProperty(__rubeFixture, "name");
}

function loadJointFromRUBE(__rubeJoint:Object, __world:b2World, __worldBodies:Vector.<b2Body>):void {
	// Joint definition

	var joint:b2Joint;
	var jointDef:b2JointDef;

	switch (getStringFromProperty(__rubeJoint, "type")) {
		case "revolute":
			// Revolute joint definition
			var revoluteJointDef:b2RevoluteJointDef = new b2RevoluteJointDef();
			revoluteJointDef.localAnchorA		= getB2Vec2FromProperty(__rubeJoint, "anchorA");
			revoluteJointDef.localAnchorB		= getB2Vec2FromProperty(__rubeJoint, "anchorB");

			revoluteJointDef.enableLimit		= getBooleanFromProperty(__rubeJoint, "enableLimit");
			revoluteJointDef.enableMotor		= getBooleanFromProperty(__rubeJoint, "enableMotor");
			// TODO: "jointSpeed": 0,
			revoluteJointDef.lowerAngle			= getFloatFromProperty(__rubeJoint, "lowerLimit");		// Different name?
			revoluteJointDef.maxMotorTorque		= getFloatFromProperty(__rubeJoint, "maxMotorTorque");
			revoluteJointDef.motorSpeed			= getFloatFromProperty(__rubeJoint, "motorSpeed");
			revoluteJointDef.upperAngle			= getFloatFromProperty(__rubeJoint, "upperLimit");		// Different name?
			revoluteJointDef.referenceAngle		= getFloatFromProperty(__rubeJoint, "refAngle");		// Different name?

			jointDef = revoluteJointDef;
			break;
		case "distance":
			// Distance joint definition
			var distanceJointDef:b2DistanceJointDef = new b2DistanceJointDef();
			distanceJointDef.localAnchorA		= getB2Vec2FromProperty(__rubeJoint, "anchorA");
			distanceJointDef.localAnchorB		= getB2Vec2FromProperty(__rubeJoint, "anchorB");

			distanceJointDef.dampingRatio		= getFloatFromProperty(__rubeJoint, "dampingRatio");
			distanceJointDef.frequencyHz		= getFloatFromProperty(__rubeJoint, "frequency");		// Different name?
			distanceJointDef.length				= getFloatFromProperty(__rubeJoint, "length");

			jointDef = distanceJointDef;
			break;
		case "prismatic":
			// Prismatic joint definition
			var prismaticJointDef:b2PrismaticJointDef = new b2PrismaticJointDef();
			prismaticJointDef.localAnchorA		= getB2Vec2FromProperty(__rubeJoint, "anchorA");
			prismaticJointDef.localAnchorB		= getB2Vec2FromProperty(__rubeJoint, "anchorB");

			prismaticJointDef.enableLimit		= getBooleanFromProperty(__rubeJoint, "enableLimit");
			prismaticJointDef.enableMotor		= getBooleanFromProperty(__rubeJoint, "enableMotor");
			prismaticJointDef.localAxisA		= getB2Vec2FromProperty(__rubeJoint, "localAxisA");
			prismaticJointDef.lowerTranslation	= getFloatFromProperty(__rubeJoint, "lowerLimit");		// Different name?
			prismaticJointDef.maxMotorForce		= getFloatFromProperty(__rubeJoint, "maxMotorForce");
			prismaticJointDef.motorSpeed		= getFloatFromProperty(__rubeJoint, "motorSpeed");
			prismaticJointDef.upperTranslation	= getFloatFromProperty(__rubeJoint, "upperLimit");		// Different name?

			jointDef = distanceJointDef;
			break;
		case "wheel":
			// Wheel joint definition
			// TODO: everything! Not supported by this version of box2d!
//			"type": "wheel",
//			"name": "joint4",
//			"anchorA": (vector),
//			"anchorB": (vector),
//			"bodyA": 4, //zero-based index of body in bodies array
//			"bodyB": 1, //zero-based index of body in bodies array
//			"collideConnected": true,
//			"enableMotor": true,
//			"localAxisA": (vector),
//			"maxMotorTorque": 0,
//			"motorSpeed": 0,
//			"springDampingRatio": 0.7,
//			"springFrequency": 4,
			break;
		case "rope":
			// Rope joint definition
			// TODO: everything! Not supported by this version of box2d!
//			"type": "rope",
//			"name": "joint5",
//			"anchorA": (vector),
//			"anchorB": (vector),
//			"bodyA": 4, //zero-based index of body in bodies array
//			"bodyB": 1, //zero-based index of body in bodies array
//			"collideConnected": true,
//			"maxLength": 4.73,
			break;
		case "motor":
			// Gear joint definition
			// TODO: this is wrong? update the class?
//			var gearJointDef:b2GearJointDef = new b2GearJointDef();
//			"anchorA": (vector), //this is the 'linear offset' of the joint
//			"anchorB": (vector), //ignored
//			"maxForce": 10,
//			"maxTorque": 7.5,
//			"correctionFactor": 0.2,
//			jointDef = gearJointDef;
			break;
		case "weld":
			// Weld joint definition
			var weldJointDef:b2WeldJointDef = new b2WeldJointDef();
			weldJointDef.localAnchorA		= getB2Vec2FromProperty(__rubeJoint, "anchorA");
			weldJointDef.localAnchorB		= getB2Vec2FromProperty(__rubeJoint, "anchorB");

			weldJointDef.referenceAngle		= getFloatFromProperty(__rubeJoint, "refAngle");		// Different name?
			// TODO: "dampingRatio": 0,
			// TODO: "frequency": 0,

			jointDef = weldJointDef;
			break;
		case "friction":
			// Friction joint definition
			var frictionJointDef:b2FrictionJointDef = new b2FrictionJointDef();
			frictionJointDef.localAnchorA		= getB2Vec2FromProperty(__rubeJoint, "anchorA");
			frictionJointDef.localAnchorB		= getB2Vec2FromProperty(__rubeJoint, "anchorB");

			frictionJointDef.maxForce			= getFloatFromProperty(__rubeJoint, "maxForce");
			frictionJointDef.maxTorque			= getFloatFromProperty(__rubeJoint, "maxTorque");

			jointDef = frictionJointDef;
			break;
	}

	if (jointDef != null) {
		// Common definition properties
		jointDef.bodyA				= __worldBodies[getIntegerFromProperty(__rubeJoint, "bodyA")];
		jointDef.bodyB				= __worldBodies[getIntegerFromProperty(__rubeJoint, "bodyB")];
		jointDef.collideConnected	= getBooleanFromProperty(__rubeJoint, "collideConnected");

		// Create joint
		joint = __world.CreateJoint(jointDef);

		// Custom properties
		joint.SetUserData(loadUserDataFromRUBE(__rubeJoint));
		joint.GetUserData()["name"] = getStringFromProperty(__rubeJoint, "name");
	} else {
		trace("loadWorldFromRUBE: could not create joint from definition.");
	}
}

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
	if (__object[__propertyName] === 0) return new b2Vec2(0, 0); // Not necessarily the same value as the default
	return new b2Vec2(getFloatFromProperty(__object[__propertyName], "x"), getFloatFromProperty(__object[__propertyName], "y"));
}

function getB2Vec2ArrayFromProperty(__object:Object, __propertyName:String):Array {
	// This is needed because "vertices" is an object with an array of x and an array of y
	var vectors:Array = [];
	if (Boolean(__object) && __object.hasOwnProperty(__propertyName)) {
		var xArray:Array = __object[__propertyName]["x"] as Array;
		var yArray:Array = __object[__propertyName]["y"] as Array;
		if (Boolean(xArray) && Boolean(yArray)) {
			var i:int;
			for (i = 0; i < xArray.length && i < yArray.length; i++) {
				vectors.push(new b2Vec2(xArray[i], yArray[i]));
			}
		}
	}
	return vectors;
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
				vectors.push(new b2Vec2(xArray[i], yArray[i]));
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
		trace("loadWorldFromRUBE: Hex number! Parse properly!=====> " + __object[__propertyName]);
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

function getStringFromProperty(__object:Object, __propertyName:String, __default:String = ""):String {
	if (!Boolean(__object)) return __default;
	if (!__object.hasOwnProperty(__propertyName)) return __default;
	return __object[__propertyName];
}
