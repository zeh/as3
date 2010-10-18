# ZTween

ZTween is a simple tweening engine written in AS3 for Flash Player version 10 and up. A "tweening engine" is something that takes a property and makes it go from an initial value to a target value in a given amount of time and with specific pre-programmed types of transition (linear, exponential, sine, etc). This can be used for animations and other kinds of timed behaviors in a Flash interface.

ZTween is built to be fast, small, have a minimal memory footprint, and be simple. The latter means that, as part of its design, ZTween does not employ any "special" tweening properties - it will only tween existing properties of objects, or variable values. It cannot create "proxy" functions like `scale` for `scaleX` and `scaleY`, auto-invisible set for `alpha`, auto-updater properties for `BitmapFilter` instances, etc.

## Using ZTween

ZTween uses a syntax that is similar to modern AS3 engines. You basically `add` a new tween by using the line:

	ZTween.add(target, properties, parameters);

 * `target` is the target object you want to change a property - any kind of object.
 * `properties` is an object containing the properties you want to tween (as the key), and their new values (as their value).
 * `parameters` is another object, this time containing some options about how the tween should be ran.

Here are some examples:

	// Move sprite `myBox` to X position 10, in 1 second
	ZTween.add(myBox, {x:10}, {time:1});

	// Fade sprite `myCircle` out (to alpha 0) in 2 seconds, while also scaling it to 200% of its original size
	ZTween.add(myCircle, {alpha:0, scaleX:2, scaleY:2}, {time:2});
	
	// Set the `position` of an arbritary `slider` instance to 0.5 in 2 seconds, with a 1.5 second delay
	ZTween.add(slider, {position:0.5}, {time:2, delay:1.5});

	// Moves sprite `myImage` to position X=10, Y=20, in 10 seconds, using an On/Out Cubic transition equation:
	ZTween.add(myImage, {x:10, y:20}, {time:10, transition:Equations.cubicInOut});

And so on and so forth. Notice that **any object** can be used as the target, and **any of its properties** can be used as part of a tweened property (as long as it's numeric).
	
### Available parameters

These parameter names can be used as part of the parameters for a new tween:

 * `time`: time for the tween to be executed, in seconds *or* number of frames (see `useFrames`). Default is 0 (which does an immediate tween).
 * `delay`: delay to wait before the tween is executed, in seconds *or* number of frames (see `useFrames`). Default is 0.
 * `transition`: any function that takes one parameter `t` (0-1) and returns a new transformed `t` value to create different transition behaviors. This is used for tween update acceleration and deceleration. Common equations for this parameter are provided on the `Equations` class. Default is `Equations.none`, which produces a linear tween. See **Transitions**.
 * `onStart`: a function to be called when the tween starts. Works like a callback/event. See **Using events**.
 * `onStartParams`: parameters for the `onStart` function, as an `Array` of items. See **Using events**.
 * `onUpdate`: a function to be called when the tween update occurs. Works like a callback/event. See **Using events**.
 * `onUpdateParams`: parameters for the `onUpdate` function, as an `Array` of items. See **Using events**.
 * `onComplete`: a function to be called when the tween ends. Works like a callback/event. See **Using events**.
 * `onCompleteParams`: parameters for the `onComplete` function, as an `Array` of items. See **Using events**.
 
 * `useFrames`: a `Boolean` value that indicates whether the number used in `time` and `delay` represents frames. If set to `true`, this tween will have frame-based timing. If not, its duration time (and property update value) is based on real time (seconds). This dictates how time is controlled, not *when* updates are made; updates are always made on frame cycles. It is advised to always have this set as false, save on exceptional cases. Default is false.
 * TODO: Note: the above is not working on parameters; it only works when setting it on the tween property
 * paused
 
### Transitions

 * Todo...

### Using events

 * Todo...