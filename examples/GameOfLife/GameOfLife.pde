/*
||
|| @file  GameOfLife.pde
|| @version 1.0
|| @author  Danne Stayskal
|| @contact danne@stayskal.com
|| @support     http://danne.stayskal.com/software/fastfader
||
|| @description
|| | This is a graphical demonstration that runs on an LED strip.
|| | In this demonstration, a one-dimensional LED strip displays a two-dimensional cellulat automaton.
|| | Specifically, it uses position as one dimension, and color as the second.
|| | The rule set is identical to Conway's Game of Life, though the interpretation is quantized rather than discrete.
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

// Provision our world
int world[NUM_LEDS][9];


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
    for(int j = 0; j < 9; j++){
      world[i][j] = int(random(64));
    }
  }
}


/* 
==========================================
= loop()
= The main runtime heartbeat, called by Arduino once whenever the previous run of loop() completes.
*/
void loop() {
  int next_generation[NUM_LEDS][9];
  for (int i = 0; i < NUM_LEDS; i++) {
    for (int j = 0; j < 9; j++) {
      next_generation[i][j] = world[i][j] / 2;
    
      // Orient ourselves
      int i_up = i + 1;
      if (i_up == NUM_LEDS) {
        i_up = 0;
      }
      int i_down = i - 1;
      if (i_down < 0) {
        i_down = NUM_LEDS - 1;
      }
      int j_right = j + 1;
      if (j_right == 9) {
        j_right = 0;
      }
      int j_left = j - 1;
      if (j_left < 0) {
        j_left = 8;
      }
      
      // Let's meet the neighbors!
      int neighbors = (world[i_up][j_right] + world[i_up][j] + world[i_up][j_left] + 
                       world[i][j_left] + world[i_down][j_left] + world[i_down][j] + 
                       world[i_down][j_right] + world[i][j_right]) / 64;
      
      // Any live cell with fewer than two live neighbours dies, as if caused by under-population.
      if (world[i][j] > 32 && neighbors < 2) {
        next_generation[i][j] = 0;
      }
      // Any live cell with two or three live neighbours lives on to the next generation.
      if (world[i][j] > 32 && (neighbors == 2 || neighbors == 3)) {
        next_generation[i][j] = 64;
      }
      // Any live cell with more than three live neighbours dies, as if by overcrowding.
      if (world[i][j] > 32 && neighbors > 3) {
        next_generation[i][j] = 0;
      } 
      // Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
      if (world[i][j] <= 32 && neighbors == 3) {
        next_generation[i][j] = 64;
      }
      // Finally, let's plant some random new points
      if(int(random(20)+1) == 20) {
        for(int i = 0; i < int(NUM_LEDS/10); i++){
          int pos = int(random(NUM_LEDS));
          for(int j = 0; j < 9; j++){
            if(int(random(2)+1) == 2) {
              world[pos][j] = int(random(64));
            }  
          }
        }
      }
    }
  }
  
  // Pass on the torch
  for (int i = 0; i < NUM_LEDS; i++) {
    for (int j = 0; j < 9; j++) {
      world[i][j] = next_generation[i][j];
    }
  }
  
  // Downsample to an array that we can actually display
  int frame[NUM_LEDS][3];
  for (int i = 0; i < NUM_LEDS; i++) {
    frame[i][0] = int((( world[i][8] / 3) +
                   ( 2 * world[i][0] / 3) + 
                         world[i][1] + 
                   ( 2 * world[i][2] / 3) +
                       ( world[i][3] / 3)) / 2);
    
    frame[i][1] = int((( world[i][2] / 3) +
                   ( 2 * world[i][3] / 3) + 
                         world[i][4] + 
                   ( 2 * world[i][5] / 3) +
                       ( world[i][6] / 3)) / 2);
    
    frame[i][2] = int((( world[i][5] / 3) +
                   ( 2 * world[i][6] / 3) + 
                         world[i][7] + 
                   ( 2 * world[i][8] / 3) +
                       ( world[i][0] / 3)) / 2);
  }
  
  // Paint this generation
  pixel_fader.set_frame(frame);
  pixel_fader.push(200,50);
}