package com.zehfernando.data.parsers {
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.space.Space;
	/**
	 * @author zeh fernando
	 */
	public function loadSpaceFromRUBE(__rubeScene:Object, __scale:Number = 1, __lineThickness:Number = 1):Space {
		// Creates a Nape World with data from a JSON Object parsed from R.U.B.E
		// PLEASE READ: http://zehfernando.com/2013/loading-and-running-r-u-b-e-scenes-with-nape-as3/
		// Other references:
		// https://www.iforce2d.net/rube/json-structure
		// http://napephys.com/help/manual.html
		// http://www.box2d.org/manual.html

		// Additional custom properties:
		// nape_isHollow (Boolean) (in fixtures/shapes: if true, instead of creating a line polygon for a chain shape ("loop"), creates a hollow solid polygon and subvidivides it
		// nape_staticFriction (Float) (in fixtures/shapes: set the static friction of the shape material
		// nape_dynamicFriction (Float) (in fixtures/shapes: set the dynamic friction of the shape material
		// nape_rollingFriction (Float) (in fixtures/shapes: set the rolling friction of the shape material
		// nape_surfaceVel (Vec2) (in body): applies a surface velocity to the body's shapes (in meters) to create a conveyor belt effect

		var i:int, j:int, k:int;

		// Instance holders
		var spaceBodies:Vector.<Body> = new Vector.<Body>();

		// Space
		var gravity:Vec2 = getVec2FromProperty(__rubeScene, "gravity", __scale);
		var space:Space = new Space(gravity);

		// IGNORED: "allowSleep" (Boolean). Bodies in Nape always wake up when needed, so you cannot prevent sleep. See: http://deltaluca.me.uk/forum/index.php/t/632/84f0803c87667803d6d528328e6eadb3/

		// TODO: "autoClearForces": true, // Information only - for Step()
		// TODO: "positionIterations": 3,  // Information only - for Step()
		// TODO: "velocityIterations": 8,  // Information only - for Step()
		// TODO: "stepsPerSecond": 60, // Information only - for Step()
		// TODO: "warmStarting" // world.SetWarmStarting(getBooleanFromProperty(__rubeScene, "warmStarting"));
		// TODO: continuousPhysics // world.SetContinuousPhysics(getBooleanFromProperty(__rubeScene, "continuousPhysics"));
		// TODO: "subStepping": false,

		// Bodies
		var bodies:Array = getArrayFromProperty(__rubeScene, "body");
		var body:Body;
		for (i = 0; i < bodies.length; i++) {
			body = loadBodyFromRUBE(bodies[i], space, __scale, __lineThickness);
			spaceBodies.push(body);
		}

		// Joints
		var joints:Array = getArrayFromProperty(__rubeScene, "joint");
		for (i = 0; i < joints.length; i++) {
			loadJointFromRUBE(joints[i], space, spaceBodies, __scale);
		}

		// TODO: collisionbitplanes

		return space;
	}

}
import nape.constraint.AngleJoint;
import nape.constraint.Constraint;
import nape.constraint.DistanceJoint;
import nape.constraint.LineJoint;
import nape.constraint.PivotJoint;
import nape.constraint.WeldJoint;
import nape.geom.GeomPoly;
import nape.geom.GeomPolyList;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.GravMassMode;
import nape.phys.Material;
import nape.shape.Circle;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.space.Space;

function loadBodyFromRUBE(__rubeBody:Object, __space:Space, __scale:Number, __lineThickness:Number):Body {
	// Main body
	var body:Body = new Body();

	switch (getIntegerFromProperty(__rubeBody, "type")) {
		case 0:
			body.type		= BodyType.STATIC;
			break;
		case 1:
			body.type		= BodyType.KINEMATIC;
			break;
		case 2:
			body.type		= BodyType.DYNAMIC;
			break;
	}

	body.allowRotation		= !getBooleanFromProperty(__rubeBody, "fixedRotation");
	body.position			= getVec2FromProperty(__rubeBody, "position", __scale);
	body.rotation			= getFloatFromProperty(__rubeBody, "angle") * getAngleScale(); // Radians
	body.isBullet			= getBooleanFromProperty(__rubeBody, "bullet");
	body.angularVel			= getFloatFromProperty(__rubeBody, "angularVelocity") * getAngleScale(); // Clockwise Radians per second
	body.velocity			= getVec2FromProperty(__rubeBody, "linearVelocity", __scale);

	var gravityScale:Number = getFloatFromProperty(__rubeBody, "gravityScale", 1);
	if (gravityScale != 1) {
		body.gravMassMode	= GravMassMode.SCALED;
		body.gravMassScale	= gravityScale;
	}

	// IGNORED: "awake" (Boolean). You cannot set a body as not awake - a body is always awakened when needed.

	// TODO: bodyDef.angularDamping	= getFloatFromProperty(__rubeBody, "angularDamping");
	// TODO: bodyDef.linearDamping	= getFloatFromProperty(__rubeBody, "linearDamping");
	// Not added? See http://deltaluca.me.uk/forum/index.php/mv/msg/228/1334

	//body.mass				= Math.max(getFloatFromProperty(__rubeBody, "massData-mass"), 0.001);
	// TODO: massData.center			= getB2Vec2FromProperty(__rubeBody, "massData-center");
	// TODO: massData.I				= getFloatFromProperty(__rubeBody, "massData-I");

	// Custom properties
	loadUserDataFromRUBE(body.userData, __rubeBody, __scale);
	body.userData["name"] = getStringFromProperty(__rubeBody, "name");

	// Create fixtures
	var fixtures:Array = getArrayFromProperty(__rubeBody, "fixture");
	var hasShape:Boolean = false;
	for (var i:int = 0; i < fixtures.length; i++) {
		if (loadFixtureFromRUBE(fixtures[i], body, __scale, __lineThickness)) hasShape = true;
	}

	// Finally, adds to the world
	if (hasShape) __space.bodies.add(body);

	return body;
}

function getCustomProperties(__rubeData:Object, __scale:Number):* {
	var obj:Object = {};
	loadUserDataFromRUBE(obj, __rubeData, __scale);
	return obj;
}

function loadUserDataFromRUBE(__userData:*, __rubeData:Object, __scale:Number):void {
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
					__userData[name] = getFloatFromProperty(obj, "float");
				} else if (obj.hasOwnProperty("int")) {
					// Integer
					__userData[name] = getIntegerFromProperty(obj, "int");
				} else if (obj.hasOwnProperty("string")) {
					// String
					__userData[name] = getStringFromProperty(obj, "string");
				} else if (obj.hasOwnProperty("bool")) {
					// Boolean
					__userData[name] = getBooleanFromProperty(obj, "bool");
				} else if (obj.hasOwnProperty("vec2")) {
					// Vector
					__userData[name] = getVec2FromProperty(obj, "vec2", __scale);
				}
			}
		}
	}
}

function loadFixtureFromRUBE(__rubeFixture:Object, __body:Body, __scale:Number, __lineThickness:Number):Boolean {
	// Loads shapes

	var customProperties:* = getCustomProperties(__rubeFixture, __scale);

	// Shape material
	var material:Material = new Material();
	// For friction, both Nape and Box2d use friction as being the square root of the product: friction = sqrt(shape1.friction shape2.friction);
	material.staticFriction			= getFloatFromProperty(__rubeFixture, "friction");
	material.dynamicFriction		= getFloatFromProperty(__rubeFixture, "friction");
	// Restitution is not really possible to translate into elasticity. I keep the values as-is, but they have to be entered with elasticity in mind.
	// box2d_restitution = max(shape1.restitution, shape2.restitution)
	//   nape_elasticity = max(1, (shape1.elasticity + shape2.elasticity)/2)
	material.elasticity 			= getFloatFromProperty(__rubeFixture, "restitution");

	// Density in box2d is arbitrary; in Nape it's g/pixel/pixel. Should be equivalent
	material.density				= getFloatFromProperty(__rubeFixture, "density");

	var staticFriction:Number = getFloatFromProperty(customProperties, "nape_staticFriction", NaN);
	var dynamicFriction:Number = getFloatFromProperty(customProperties, "nape_dynamicFriction", NaN);
	var rollingFriction:Number = getFloatFromProperty(customProperties, "nape_rollingFriction", NaN);

	if (!isNaN(staticFriction)) material.staticFriction = staticFriction;
	if (!isNaN(dynamicFriction)) material.dynamicFriction = dynamicFriction;
	if (!isNaN(rollingFriction)) material.rollingFriction = rollingFriction;

//	// Filter definition
//	TODO: var filterData:b2FilterData = new b2FilterData();
//	TODO: filterData.categoryBits	= getIntegerFromProperty(__rubeFixture, "categoryBits", 1);
//	TODO: filterData.maskBits		= getIntegerFromProperty(__rubeFixture, "maskBits", 65535);
//	TODO: filterData.groupIndex	= getIntegerFromProperty(__rubeFixture, "groupIndex");
//	TODO: fixtureDef.filter		= filterData;

	var shape:Shape;
	var addedShapeToBody:Boolean = false;
	var circleShape:Circle;
	var polygonShape:Polygon;
	var vertices:Vector.<Vec2>;

	var isSensor:Boolean = getBooleanFromProperty(__rubeFixture, "sensor");

	// Shape
	if ((__rubeFixture as Object).hasOwnProperty("circle")) {
		// Circle shape object: use a Circle
		circleShape = new Circle(getFloatFromProperty(__rubeFixture["circle"], "radius") * __scale, getVec2FromProperty(__rubeFixture["circle"], "center", __scale));
		shape = circleShape;
	} else if ((__rubeFixture as Object).hasOwnProperty("polygon")) {
		// Polygon shape object: use a Polygon
		vertices = getVec2VectorFromProperty(__rubeFixture["polygon"], "vertices", __scale);
		polygonShape = new Polygon(vertices);
		shape = polygonShape;
	} else if ((__rubeFixture as Object).hasOwnProperty("chain")) {
		// Chain shape object, or edge: use box polygons and circles
		vertices = getVec2VectorFromProperty(__rubeFixture["chain"], "vertices", __scale);
		var isLoop:Boolean = getBooleanFromProperty(__rubeFixture["chain"], "hasNextVertex") || getBooleanFromProperty(__rubeFixture["chain"], "hasPrevVertex");
		var isHollow:Boolean = getBooleanFromProperty(customProperties, "nape_isHollow");
		if (vertices.length == 2) {
			// Just one edge, create line
			createPolygonEdges(vertices, __body, __scale, __lineThickness, false, material, isSensor);
			shape = __body.shapes.at(0);
			addedShapeToBody = true;
		} else if (!isLoop || isHollow) {
			// An opened or hollow polygon, create line enclosure
			createPolygonEdges(vertices, __body, __scale, __lineThickness, isLoop, material, isSensor);
			shape = __body.shapes.at(0);
			addedShapeToBody = true;
		} else {
			// A solid polygon, just create a complex polygon and subdivide it
			var geom:GeomPoly = GeomPoly.get(vertices);
			var gpl:GeomPolyList = geom.convexDecomposition();
			gpl.foreach(function(poly:GeomPoly):void {
				shape = new Polygon(poly);
				shape.material = material;
				shape.sensorEnabled = isSensor;
				__body.shapes.add(shape);
			} );
			shape = __body.shapes.at(0);
			addedShapeToBody = true;
		}
	} else {
		fail("Could not create fixture from definition.");
	}

	// Create shape
	if (shape != null) {
		if (!addedShapeToBody) __body.shapes.add(shape);
		shape.material = material;
		shape.sensorEnabled = isSensor;

		// Custom properties
		loadUserDataFromRUBE(shape.userData, __rubeFixture, __scale);
		shape.userData["name"] = getStringFromProperty(__rubeFixture, "name");

		return true;
	}

	fail("Body had no valid shapes: " + getStringFromProperty(__rubeFixture, "name"));
	return false;
}

function createPolygonEdges(__vertices:Vector.<Vec2>, __body:Body, __scale:Number, __lineThickness:Number, __isLoop:Boolean, __material:Material, __isSensor:Boolean):void {
	// Creates a number of polygons that simulates edges or a chain shape (since Nape doesn't support just lines)
	// Only returns the first shape (for userData's sake)

	var circleShape:Circle;
	var polygonShape:Polygon;
	var v1:Vec2, v2:Vec2, vDiff:Vec2;
	var vThickness:Vec2;
	for (var i:int = 0; i < __vertices.length; i++) {
		// Create corner circle
		circleShape = new Circle(__lineThickness / 2, __vertices[i]);
		circleShape.material = __material;
		circleShape.sensorEnabled = __isSensor;
		__body.shapes.add(circleShape);

		// Create line box
		if (i < __vertices.length - 1 || __isLoop) {
			v1 = __vertices[i];
			v2 = __vertices[(i+1) % __vertices.length];
			vDiff = new Vec2(v2.x-v1.x, v2.y-v1.y);
			vThickness = Vec2.fromPolar(__lineThickness * 0.5, vDiff.angle + Math.PI * 0.5);
			if (vDiff.length > 0) {
				polygonShape = new Polygon([new Vec2(v1.x + vThickness.x, v1.y + vThickness.y), new Vec2(v2.x + vThickness.x, v2.y + vThickness.y), new Vec2(v2.x - vThickness.x, v2.y - vThickness.y), new Vec2(v1.x - vThickness.x, v1.y - vThickness.y)]);
				polygonShape.material = __material;
				polygonShape.sensorEnabled = __isSensor;
				//polygonShape = new Polygon(Polygon.rect(v1.x, v1.y - __lineThickness * 0.5, vDiff.length, __lineThickness));
				__body.shapes.add(polygonShape);
			}
		}
	}
}

function fail(__message:String):void {
	trace("!!! loadSpaceFromRUBE ERROR: " + __message);
}

function loadJointFromRUBE(__rubeJoint:Object, __space:Space, __spaceBodies:Vector.<Body>, __scale:Number):void {
	// Joint definition

	var joint:Constraint;

	var body1:Body = __spaceBodies[getIntegerFromProperty(__rubeJoint, "bodyA")];
	var body2:Body = __spaceBodies[getIntegerFromProperty(__rubeJoint, "bodyB")];
	var anchor1:Vec2 = getVec2FromProperty(__rubeJoint, "anchorA", __scale);
	var anchor2:Vec2 = getVec2FromProperty(__rubeJoint, "anchorB", __scale);

	var pivotJoint:PivotJoint;
	var distanceJoint:DistanceJoint;

	var frequency:Number;

	switch (getStringFromProperty(__rubeJoint, "type")) {
		case "revolute":
			// Revolute joint definition: use a PivotJoint
			if (body1 != null && body2 != null) {
				pivotJoint = new PivotJoint(body1, body2, anchor1, anchor2);
				pivotJoint.ignore = !getBooleanFromProperty(__rubeJoint, "collideConnected");
				joint = pivotJoint;
			}

//			TODO: revoluteJointDef.enableLimit		= getBooleanFromProperty(__rubeJoint, "enableLimit");
//			TODO: revoluteJointDef.enableMotor		= getBooleanFromProperty(__rubeJoint, "enableMotor");
//			// TODO: "jointSpeed": 0,
//			TODO: revoluteJointDef.lowerAngle			= getFloatFromProperty(__rubeJoint, "lowerLimit");		// Different name?
//			TODO: revoluteJointDef.maxMotorTorque		= getFloatFromProperty(__rubeJoint, "maxMotorTorque");
//			TODO: revoluteJointDef.motorSpeed			= getFloatFromProperty(__rubeJoint, "motorSpeed");
//			TODO: revoluteJointDef.upperAngle			= getFloatFromProperty(__rubeJoint, "upperLimit");		// Different name?
//			TODO: revoluteJointDef.referenceAngle		= getFloatFromProperty(__rubeJoint, "refAngle");		// Different name?
			break;
		case "distance":
			// Distance joint definition: use a DistanceJoint
			if (body1 != null && body2 != null) {
				frequency = getFloatFromProperty(__rubeJoint, "frequency"); // TODO: test if this is correct
				var length:Number = getFloatFromProperty(__rubeJoint, "length") * __scale;
				distanceJoint = new DistanceJoint(body1, body2, anchor1, anchor2, length, length);
				distanceJoint.ignore		= !getBooleanFromProperty(__rubeJoint, "collideConnected");
				if (frequency > 0) {
					distanceJoint.frequency	= frequency;
					distanceJoint.stiff		= false;
				} else {
					distanceJoint.stiff		= true;
				}
				distanceJoint.damping		= getFloatFromProperty(__rubeJoint, "dampingRatio");// TODO: test if this is correct
				joint = distanceJoint;
			}
			break;
		case "prismatic":
			// Prismatic joint definition: use a LineJoint and an AngleJoint
			// TODO: test if this is correct
			if (body1 != null && body2 != null) {
				var lineJoint:LineJoint = new LineJoint(body1, body2, anchor1, anchor2, getVec2FromProperty(__rubeJoint, "localAxisA", __scale), getFloatFromProperty(__rubeJoint, "lowerLimit")  * __scale, getFloatFromProperty(__rubeJoint, "upperLimit") * __scale);
				lineJoint.ignore = !getBooleanFromProperty(__rubeJoint, "collideConnected");
				joint = lineJoint;

				// Construct secondary angle joint to maintain the angle
				var angleJoint:AngleJoint = new AngleJoint(body2, body1, 0, 0, 1);
				angleJoint.ignore = !getBooleanFromProperty(__rubeJoint, "collideConnected");
				__space.constraints.add(angleJoint);
			}
//			TODO: prismaticJointDef.enableLimit		= getBooleanFromProperty(__rubeJoint, "enableLimit");
//			TODO: prismaticJointDef.enableMotor		= getBooleanFromProperty(__rubeJoint, "enableMotor");
//			TODO: prismaticJointDef.maxMotorForce		= getFloatFromProperty(__rubeJoint, "maxMotorForce");
//			TODO: prismaticJointDef.motorSpeed		= getFloatFromProperty(__rubeJoint, "motorSpeed");
			break;
		case "wheel":
			// Wheel joint definition: use a PivotJoint
			// TODO: use a linejoint instead?
			if (body1 != null && body2 != null) {
				pivotJoint = new PivotJoint(body1, body2, anchor1, anchor2);
				pivotJoint.ignore = !getBooleanFromProperty(__rubeJoint, "collideConnected");
				joint = pivotJoint;
			}
//			TODO: "enableMotor": true,
//			TODO: "localAxisA": (vector),
//			TODO: "maxMotorTorque": 0,
//			TODO: "motorSpeed": 0,
//			TODO: "springDampingRatio": 0.7,
//			TODO: "springFrequency": 4,
			break;
		case "rope":
			// Rope joint definition: use a DistanceJoint
			if (body1 != null && body2 != null) {
				distanceJoint = new DistanceJoint(body1, body2, anchor1, anchor2, 0, getFloatFromProperty(__rubeJoint, "maxLength") * __scale);
				distanceJoint.ignore = !getBooleanFromProperty(__rubeJoint, "collideConnected");
				joint = distanceJoint;
			}
			break;
		case "motor":
			// Gear joint definition
			// TODO: this is wrong? update the class?
//			var gearJointDef:b2GearJointDef = new b2GearJointDef();
//			TODO: "anchorA": (vector), //this is the 'linear offset' of the joint
//			TODO: "anchorB": (vector), //ignored
//			TODO: "maxForce": 10,
//			TODO: "maxTorque": 7.5,
//			TODO: "correctionFactor": 0.2,
			break;
		case "weld":
			// Weld joint definition: use a WeldJoint
			if (body1 != null && body2 != null) {
				frequency = getFloatFromProperty(__rubeJoint, "frequency"); // TODO: test if this is correct
				var weldJoint:WeldJoint = new WeldJoint(body1, body2, anchor1, anchor2, getFloatFromProperty(__rubeJoint, "refAngle") * getAngleScale()); // TODO: rotation/position is incorrect
				weldJoint.ignore		= !getBooleanFromProperty(__rubeJoint, "collideConnected");
				body2.rotation = 0;
				if (frequency > 0) {
					weldJoint.frequency	= frequency;
					weldJoint.stiff		= false;
				} else {
					weldJoint.stiff		= true;
				}
				joint = weldJoint;
			}
			break;
		case "friction":
			// Friction joint definition
//			TODO: var frictionJointDef:b2FrictionJointDef = new b2FrictionJointDef();
//			TODO: frictionJointDef.localAnchorA		= getB2Vec2FromProperty(__rubeJoint, "anchorA");
//			TODO: frictionJointDef.localAnchorB		= getB2Vec2FromProperty(__rubeJoint, "anchorB");
//
//			TODO: frictionJointDef.maxForce			= getFloatFromProperty(__rubeJoint, "maxForce");
//			TODO: frictionJointDef.maxTorque			= getFloatFromProperty(__rubeJoint, "maxTorque");
	}

	if (joint != null) {
		// Create joint
		__space.constraints.add(joint);

		// Custom properties
		loadUserDataFromRUBE(joint.userData, __rubeJoint, __scale);
		joint.userData["name"] = getStringFromProperty(__rubeJoint, "name");
	} else {
		fail("Could not create joint from definition: " + getStringFromProperty(__rubeJoint, "name"));
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

function getVec2FromProperty(__object:Object, __propertyName:String, __scale:Number):Vec2 {
	var defaultValue:Vec2 = new Vec2(0, 0);
	if (!Boolean(__object)) return defaultValue.copy();
	if (!__object.hasOwnProperty(__propertyName)) return defaultValue.copy();
	if (__object[__propertyName] === 0) return new Vec2(0, 0); // Not necessarily the same value as the default
	return new Vec2(getFloatFromProperty(__object[__propertyName], "x") * __scale, getFloatFromProperty(__object[__propertyName], "y") * __scale * getYScale());
}

function getYScale():Number {
	return -1;
}

function getAngleScale():Number {
	return -1;
}

function getVec2ArrayFromProperty(__object:Object, __propertyName:String, __scale:Number):Array {
	// This is needed because "vertices" is an object with an array of x and an array of y
	var vectors:Array = [];
	if (Boolean(__object) && __object.hasOwnProperty(__propertyName)) {
		var xArray:Array = __object[__propertyName]["x"] as Array;
		var yArray:Array = __object[__propertyName]["y"] as Array;
		if (Boolean(xArray) && Boolean(yArray)) {
			var i:int;
			for (i = 0; i < xArray.length && i < yArray.length; i++) {
				vectors.push(new Vec2(xArray[i] * __scale, yArray[i] * __scale * getYScale()));
			}
		}
	}
	return vectors;
}

function getVec2VectorFromProperty(__object:Object, __propertyName:String, __scale:Number):Vector.<Vec2> {
	// This is needed because "vertices" is an object with an array of x and an array of y
	var vectors:Vector.<Vec2> = new Vector.<Vec2>();
	if (Boolean(__object) && __object.hasOwnProperty(__propertyName)) {
		var xArray:Array = __object[__propertyName]["x"] as Array;
		var yArray:Array = __object[__propertyName]["y"] as Array;
		if (Boolean(xArray) && Boolean(yArray)) {
			var i:int;
			for (i = 0; i < xArray.length && i < yArray.length; i++) {
				vectors.push(new Vec2(xArray[i] * __scale, yArray[i] * __scale * getYScale()));
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
		fail("Hex number! Must parse properly!=====> " + __object[__propertyName]);
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
