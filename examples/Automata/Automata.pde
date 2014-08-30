/*
||
|| @file 	Automata.pde
|| @version	1.0
|| @author	Danne Stayskal
|| @contact	danne@stayskal.com
|| @support     http://danne.stayskal.com/software/fastfader
||
|| @description
|| | This is a graphical demonstration that runs on an LED strip.
|| | In this demonstration, three one-dimensional cellular automata dance across the strip.
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
#include <math.h>

// How many LEDs are in the strip
#define NUM_LEDS 18

// Using the Arduino Uno in dev mode
#define DATA_PIN 2
#define CLOCK_PIN 3

// Create the LED interface, pixel buffer, and fader
CRGB leds[NUM_LEDS];
int pixel_buffer[NUM_LEDS][3];
FastFader pixel_fader;

// Which one-dimensional cellular automata are we running? (0..255, inclusive)
int rules[3] = {90, 90, 90};

// Provision our automata
int automata[NUM_LEDS][3];

// Function prototype
void show_automata(int automata[NUM_LEDS][3]);

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

  // Plant some entropy and watch it grow!  
  for(int i = 0; i < NUM_LEDS; i++){
    for(int c = 0; c < 3; c++){
      automata[i][c] = int(random(64));
    }
  }
}


/* 
==========================================
= loop()
= The main runtime heartbeat, called by Arduino once whenever the previous run of loop() completes.
*/
void loop() {
  int next_generation[NUM_LEDS][3];
  for (int i = 0; i < NUM_LEDS; i++) {
    for (int c = 0; c < 3; c++) {
      next_generation[i][c] = automata[i][c] / 8;
    }
    
    // Orient ourselves
    int i_left = i - 1;
    if (i_left < 0) {
      i_left = NUM_LEDS;
    }
    int i_right = i + 1;
    if (i_right > NUM_LEDS){
      i_right = 0;
    }
    
    // Calculate the next generation
    for (int c = 0; c < 3; c++) {
      if (automata[i_left][c] <= 32 && automata[i][c] <= 32 && automata[i_right][c] <= 32) {
        if (rules[c] & (1 << 0)){
          next_generation[i][c] = 64;
        }
      }
      if (automata[i_left][c] <= 32 && automata[i][c] <= 32 && automata[i_right][c] > 32) {
        if (rules[c] & (1 << 1)){
          next_generation[i][c] = 64;
        }
      }
      if (automata[i_left][c] <= 32 && automata[i][c] > 32 && automata[i_right][c] <= 32) {
        if (rules[c] & (1 << 2)){
          next_generation[i][c] = 64;
        }
      }
      if (automata[i_left][c] <= 32 && automata[i][c] > 32 && automata[i_right][c] > 32) {
        if (rules[c] & (1 << 3)){
          next_generation[i][c] = 64;
        }
      }
      if (automata[i_left][c] > 32 && automata[i][c] <= 32 && automata[i_right][c] <= 32) {
        if (rules[c] & (1 << 4)){
          next_generation[i][c] = 64;
        }
      }
      if (automata[i_left][c] > 32 && automata[i][c] <= 32 && automata[i_right][c] > 32) {
        if (rules[c] & (1 << 5)){
          next_generation[i][c] = 64;
        }
      }
      if (automata[i_left][c] > 32 && automata[i][c] > 32 && automata[i_right][c] <= 32) {
        if (rules[c] & (1 << 6)){
          next_generation[i][c] = 64;
        }
      }
      if (automata[i_left][c] > 32 && automata[i][c] > 32 && automata[i_right][c] > 32) {
        if (rules[c] & (1 << 7)){
          next_generation[i][c] = 64;
        }
      }
    }
  }
  
  // Re-seed (and dim red, since it's really loud in this demo)
  for (int i = 0; i < NUM_LEDS; i++) {
    for (int c = 0; c < 3; c++) {
      automata[i][c] = next_generation[i][c]; 
    }
    automata[i][1] = automata[i][1] / 8;
  }
  
  // Paint this generation
  pixel_fader.set_frame(automata);
  pixel_fader.push(200,50);

  // Bring red back so it doesn't die off
  for (int i = 0; i < NUM_LEDS; i++) {
    automata[i][1] = automata[i][1] * 8;
  }
}