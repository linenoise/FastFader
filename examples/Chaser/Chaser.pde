/*
||
|| @file 	Chaser.pde
|| @version	1.0
|| @author	Danne Stayskal
|| @contact	danne@stayskal.com
|| @support     http://danne.stayskal.com/software/fastfader
||
|| @description
|| | This is a graphical demonstration that runs on an LED strip.
|| | In this demonstration, a single pixel moves back and forth across the strip.
|| #
||
|| @changelog
|| | 1.0 2014-05-29 - Danne Stayskal : Initial Release
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
#include "FastFader.h"  // https://github.com/linenoise/fastfader

// How many LEDs are in the strip
#define NUM_LEDS 18

// Using the Arduino Uno in dev mode
#define DATA_PIN 2
#define CLOCK_PIN 3

// Create the LED interface, pixel buffer, and fader
CRGB leds[NUM_LEDS];
int pixel_buffer[NUM_LEDS][3];
FastFader pixel_fader;


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
  
  // First slide the led in one direction
  for(int i = 0; i < NUM_LEDS; i++) {

    // Fade the shadow
    for (int j = 0; j < NUM_LEDS; j++) {
      int *pixel = pixel_fader.get_pixel(j);
      for (int c = 0; c < 3; c++) {
        pixel_fader.set_pixel(j, pixel[c] / 1.7, c);
      }
    }

    // Draw the bit
    pixel_fader.set_pixel(i,255,0); 
    pixel_fader.push(10);
  }

  // Now go in the other direction.  
  for(int i = NUM_LEDS-1; i >= 0; i--) {

    // Fade the shadow
    for (int j = 0; j < NUM_LEDS; j++) {
      int *pixel = pixel_fader.get_pixel(j);
      for (int c = 0; c < 3; c++) {
        pixel_fader.set_pixel(j, pixel[c] / 1.7, c);
      }
    }

    // Draw the bit
    pixel_fader.set_pixel(i,255,0); 
    pixel_fader.push(10);
  }
}