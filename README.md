FastFader
=================

This is an [Arduino](http://arduino.cc/) library that implements a fast cross-fader and pixel buffer for use with LED lighting strips. It pairs with the [FastLED library](http://fastled.io/) to produce smooth, fast animations on WS2810, WS2811, LPD8806, Neopixel and [other types of lighting strips](https://github.com/FastLED/FastLED/wiki/Chipset-reference).

This summary is also available at <http://danne.stayskal.com/software/fastfader/>.

![FastFader Demonstration Image](http://danne.stayskal.com/images/software/fastfader_header.jpg)

Prerequisites
-------------

Since this needs to use the `math.h` library, you will need an [Arduino ATmega168](http://arduino.cc/en/Hacking/PinMapping168) or better CPU. You will also need to have the [FastLED](https://github.com/FastLED/FastLED/) library installed.

Installation
------------

To install this library, checkout this codebase and place the FastFader folder next to the FastLED folder in your Arduino Libraries folder. This will usually be in an Arduino folder wherever your operating system keeps documents. Restart the Arduino IDE, and you're ready to go.

Once this library is installed, you'll need to include it in the header of the `.ino` file for the relevant Arduino sketch. The best place for it will be directly below your `#include` directive for FastLED:

```cpp
#include "FastLED.h"    // https://github.com/FastLED/FastLED
#include "FastFader.h"  // https://github.com/linenoise/fastfader

// How many LEDs are in the strip
#define NUM_LEDS 18

// Using the Arduino Uno in dev mode
#define DATA_PIN 2
#define CLOCK_PIN 3

//...
```

Next, where you initialize your LED strip, you'll also need to initialize a fader, then bind them. This should be in your `void setup();` function:

```cpp
/* 
==========================================
= setup()
= Initializes needed variables and drivers, called by Arduino once during initialization.
*/
void setup() {
  // Initialize the LED interface
  FastLED.addLeds<LPD8806, DATA_PIN, CLOCK_PIN, RGB>(leds, NUM_LEDS);

  // Bind the pixel fader to the LED interface
  pixel_fader.bind(pixel_buffer, leds, NUM_LEDS, FastLED);

}
```

Easy as pie.

Usage
-----

To see example lighting demonstrations, check out the `examples` folder of this codebase.

Once you have a fader object instantiated and bound to your FastLED interface, you have the following additional functions available with which to communicate with your LED strip. All functions other than get_pixel return a reference to the fader object, so calls can be chained if desired, e.g. `fader.clear().set_frame(your_array).push()`.

### clear();

The `fader.clear` function quickly resets the LED strip.

### set_pixel(int pos, int value, int channel);

Also callable as:

* `set_pixel(int pos, int value[3]);` (takes an array of r, g, and b values)
* `set_pixel(int pos, int value);` (pushes a single value to r, g, and b channels)
* `set_pixel(int pos);` (turns on a single pixel to fullbrightness)

The `fader.set_pixel` function sets an individual pixel by position, value, and channel. Value and Channel are optional arguments. If you call `set_pixel` with no channel, it defaults to all three (Red, Green, and Blue). If you call `set_pixel` with no channel and no value, it assumes a value of 255. Value can be passed as a three-dimensional integer array, or as a single integer (to apply to all three channels).

Any data passed to `set_pixel` that's outside of valid ranges will be clipped.

### get_pixel(int pos);

The `fader.get_pixel` function returns a three-dimensional integer array of the present red, green, and blue channel values at a given position.

### set_frame(int (*frame)[3]);

The `fader.set_frame` function loads an entire array of pixels into your light strip at once. Its dimensions should match the length of your strip.

Any data passed to `set_frame` that's outside of valid ranges will be clipped.

### push(int fader_delay, int fader_steps, int decay_type);

Also callable as:

* `push(int fader_delay, int fader_steps);` (assumes LOGARITHMIC_DECAY)
* `push(int fader_delay);` (assumes ten cross-fade steps)
* `push();` (assumes ten cross-fade steps over 100 miliseconds)

The `fader.push` function sends data to the LED strip through a cross-fader and ditherer. The first two parameters control the timing of the cross-fade. `fader_delay` tells it how many miliseconds to take for the fade, and the `fader_steps` parameter tells it how many divisions of color-space to traverse on its way to the new frame.

Further, three types of cross-fading are supported:

* `NO_DECAY` will disable cross-fading. This is very fast and can be used in parts of a demonstration where CPU-intensive work is happening behind the scenes.
* `LINEAR_DECAY` will cause the new frame to fade in directly: for every step the new frame takes forward, the old frame takes one step back. This is slower, but visually nice.
* `LOGARITHMIC_DECAY` will logarithmically weight the fade-in, since human perception of luminosity is logarithmic, not linear. This is the slowest, but also the prettiest (which is why it's the default).

Any of these three parameters can be passed to `fader.push` as the third parameter.

Maintenance
-----------

If you have something to contribute to this codebase, please fork it here on github, make your change in a branch, and send me a pull request. The current things I'm working on are:

* Adding HSV support. This is built into the FastLED library, but I don't pass it through yet.
* Adding alpha channel support for cross-fades between effects.
* Adding lighting effects as alpha-channel blends.

Changelog
---------

* 2014-05-29: Initial Release.

License
-------

```
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; version
2.1 of the License.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
```

Credits
-------

![Dann Stayksal](http://danne.stayskal.com/images/logo.png)

Also, special thanks to John Windberg for the hardware I used to develop this.
