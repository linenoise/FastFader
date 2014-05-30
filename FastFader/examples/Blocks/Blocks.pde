/*
||
|| @file  blocks.pde
|| @version 1.0
|| @author  Dann Stayskal
|| @contact dann@stayskal.com
|| @support     http://dann.stayskal.com/software/fastfader
||
|| @description
|| | This is a graphical demonstration that runs on an LED strip.
|| | In this demonstration, red, green, and blue colored blocks move across the LED strip at varying speeds.
|| #
||
|| @changelog
|| | 1.0 2014-05-29 - Dann Stayskal : Initial Release
|| #
||
|| @license
|| | This library is free software; you can redistribute it and/or
|| | modify it under the terms of the GNU Lesser General Public
|| | License as published by the Free Software Foundation; version
|| | 2.1 of the License.
|| |
|| | This library is distributed in the hope that it will be useful,
|| | but WITHOUT ANY WARRANTY; without even the implied warranty of
|| | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
|| | Lesser General Public License for more details.
|| |
|| | You should have received a copy of the GNU Lesser General Public
|| | License along with this library; if not, write to the Free Software
|| | Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
|| #
==========================================
*/

#include "FastLED.h"    // https://github.com/FastLED/FastLED
#include "FastFader.h"  // https://github.com/danndalf/fastfader

// How many LEDs are in the strip
#define NUM_LEDS 18

// Using the Arduino Uno in dev mode
#define DATA_PIN 2
#define CLOCK_PIN 3

// Create the LED interface, pixel buffer, and fader
CRGB leds[NUM_LEDS];
int pixel_buffer[NUM_LEDS][3];
FastFader pixel_fader;

// Starting positions for each block: red, green, and blue.
int block_start[3] = {0, 0, 0};

// Speed of each block in pixels per heartbeat
int block_speed[3] = {1, 2, 3};

// Length of each color block (ideally, not longer than NUM_LEDS)
int block_length[3] = {
  int(NUM_LEDS / 3), // Red
  int(NUM_LEDS / 6), // Green
  int(NUM_LEDS / 2)  // Blue 
};


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


/* 
==========================================
= loop()
= The main runtime heartbeat, called by Arduino once whenever the previous run of loop() completes.
*/
void loop() {

  // Clear the pixel buffer
  pixel_fader.clear();
  
  // Iterate through each of the three color channels
  int block_end[3];
  for (int channel = 0; channel < 3; channel++) {

    // Position the block
    block_start[channel] = block_start[channel] + block_speed[channel];
    if (block_start[channel] > NUM_LEDS - 1) {
      block_start[channel] = block_start[channel] - NUM_LEDS;
    }
    block_end[channel] = block_start[channel] + block_length[channel];

    // Place the block in the pixelbuffer
    for (int pos = block_start[channel]; pos < block_end[channel]; pos++) {
      int pos_wrapped = pos;
      if (pos_wrapped > NUM_LEDS - 1) {
        pos_wrapped = pos_wrapped - NUM_LEDS;
      }
      pixel_fader.set_pixel(pos_wrapped, 100, channel);
    }
  }

  // Push this frame to the LEDs
  pixel_fader.push(300);

}