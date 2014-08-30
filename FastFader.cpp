/*
||
|| @file FastFader.cpp
|| @version 1.0
|| @author Danne Stayskal
|| @contact danne@stayskal.com
||
|| @description
|| | Provides a fast, cross-fading pixelbuffer to the FastLED library
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

#include "FastFader.h" 


/* 
==========================================
= FastFader::FastFader()
= Class constructor
= 
= Takes:
=  * leds, a reference to an array of FastLED.h CRGB triples
==========================================
*/
FastFader::FastFader(){}


/* 
==========================================
= FastFader::bind
= Bind the pixel buffer and fader to the LED interface
= 
= Takes: nothing
= Returns: this, the current FastFader object
==========================================
*/
FastFader& FastFader::bind(int (*pixel_buffer)[3], CRGB *leds, int num_leds, CFastLED& fast_led){
	LEDs = leds;
	NumLEDs = num_leds;
	FLED = fast_led;
	PixelBuffer = pixel_buffer;

  for (int i = 0; i < NumLEDs; i++) {
    LEDs[i] = CRGB(0,0,0);
    PixelBuffer[i][0] = 0;
    PixelBuffer[i][1] = 0;
    PixelBuffer[i][2] = 0;
  }

	return *this;
}


/* 
==========================================
= FastFader::clear
= Empties the current pixelbuffer
= 
= Takes: nothing
= Returns: this, the current FastFader object
==========================================
*/
FastFader& FastFader::clear(){
  for (int i = 0; i < NumLEDs; i++) {
    for (int channel = 0; channel < 3; channel++) { 
      FastFader::PixelBuffer[i][channel] = 0;
    }
  }  
	return *this;
}


/* 
==========================================
= FastFader::set_pixel
= Sets an individual pixel in the pixel buffer
= 
= Takes:
=  * pos, the integer position being set (0..NumLEDs-1)
=  * value, (optional, default 255) the luminosity value to set (0..255).
=    * If passed an integer, this will apply to all channels.
=    * If passed an array[3], this will be mapped to RGB on this pixel.
=  * channel, (optional, default all channels) which channel to set. 
=    * -1 will set all channels.
=    * 0..2 will set Red, Green, or Blue, respectively
=    * >2 will set all channels.
=
= Returns: this, the current FastFader object
==========================================
*/
FastFader& FastFader::set_pixel(int pos, int value, int channel){
  
  // Clip pos to the range 0..NumLEDs - 1, inclusive
  if (pos < 0) {
    pos = 0;
  }
  if (pos > NumLEDs) {
    pos = NumLEDs;
  }
  
  // Clip value to the range 0..255, inclusive
  if (value > 255) {
    value = 255;
  }
  if (value < 0) { 
    value = 0;
  }
  
  // Set the pixel in the buffer
  if (channel < 0 || channel > 2) {
    for (int c = 0; c < 3; c++) {
      PixelBuffer[pos][c] = value;
    }
  } else {
    PixelBuffer[pos][channel] = value;
  }

	return *this;
}

FastFader& FastFader::set_pixel(int pos, int value[3]){
  for (int c = 0; c < 3; c++) {
		set_pixel(pos, value[c], c);
	}
	return *this;
}

FastFader& FastFader::set_pixel(int pos, int value){
  for (int c = 0; c < 3; c++) {
		set_pixel(pos, value, c);
	}
	return *this;
}

FastFader& FastFader::set_pixel(int pos){
	return set_pixel(pos, 255, -1);
}


/* 
==========================================
= FastFader::get_pixel
= Gets an individual pixel from the pixel buffer
= 
= Takes:
=  * pos, the integer position being set (0..NumLEDs-1)
=
= Returns:
=  * pixel, an arrray reference to an [R,G,B] pixel.
==========================================
*/
int* FastFader::get_pixel(int pos){

  return PixelBuffer[pos];

}


/* 
==========================================
= FastFader::set_frame
= Sets an entire frame of data into the pixel buffer
= 
= Takes:
=  * frame, a reference to a two-dimensional frame array:
=    * Dimension 0: position (0..NumLEDs)
=    * Dimension 1: array of values ([int red, int green, int blue)])
=
= Returns: this, the current FastFader object
==========================================
*/
FastFader& FastFader::set_frame(int (*frame)[3]){
  for (int i = 0; i < NumLEDs; i++) {
  	for (int channel = 0; channel < 3; channel++) {
  		set_pixel(i, frame[i][channel], channel);
  	}
  }
	return *this;
}



/*
==========================================
= FastFader::push
= Pushes the present pixelbuffer to the LED array
= 
= Takes:
= * fader_delay (optional, default 100), an integer value of how many miliseconds to take when fading in this frame
= * fader_steps (optional, default 10), an integer value of how many steps to take when fading
= * decay_type (optional), determining which weighting decay function to map over the fade:
=   * NO_DECAY is the fastest, and will not actually fade the pixels in. It's good for slow boards.
=   * LINEAR_DECAY will decay the cross-fade linearly
=   * LOGARITHMIC_DECAY (default) will decay the cross-fade logarithmically. It's more expensive, but prettier.
=
= Returns: this, the current FastFader object
==========================================
*/
FastFader& FastFader::push(int fader_delay, int fader_steps, int decay_type){
  
  // Clone the present LED interface into a fader array
  int fader_cache[NumLEDs][3];
  for (int i = 0; i < NumLEDs; i++) {
    for (int channel = 0; channel < 3; channel++) {
      fader_cache[i][channel] = LEDs[i][channel];
    }
  }
  
  // Fade from the previous frame to the next one
  int step_delay = int(fader_delay / fader_steps);
  double log_base = log(fader_steps);
  for (int current_step = 1; current_step <= fader_steps; current_step++) {

    double previous_weight;
    double current_weight;
    double fader_weight;

    if (decay_type < -1 || decay_type > 1) {
    	decay_type = LOGARITHMIC_DECAY;
    }

  	if (decay_type == NO_DECAY) {
      previous_weight = 0;
      current_weight = 1;
      fader_weight = 1;
    }

    if (decay_type == LINEAR_DECAY) {
      // Calculate linear frame weighs for this step
 
      previous_weight = 100 * (fader_steps - current_step);
      current_weight = 100 * (current_step - 1);
      fader_weight = 100 * (fader_steps - 1);
    }

    if (decay_type == LOGARITHMIC_DECAY) {
      // Logarithmically weight the fade-in, since human perception of luminosity
      // is logarithmic, not linear. This is log_n(current_step) where n = fader_steps
 
      current_weight = 100 - (100 * (log(fader_steps - current_step + 1) / log_base));
      previous_weight = 100 - (100 * (log(current_step) / log_base));
      fader_weight = current_weight + previous_weight;
    }
    
    // Send this fader step to the LED interface  
    for (int i = 0; i < NumLEDs; i++) {
      LEDs[i] = CRGB(
        int(((PixelBuffer[i][0] * current_weight) + (fader_cache[i][0] * previous_weight)) / fader_weight),
        int(((PixelBuffer[i][1] * current_weight) + (fader_cache[i][1] * previous_weight)) / fader_weight),
        int(((PixelBuffer[i][2] * current_weight) + (fader_cache[i][2] * previous_weight)) / fader_weight)
      );
    }
    FLED.show();

    // Pause for a fraction of a moment
    delay(step_delay);
  }

	return *this;
}

FastFader& FastFader::push(int fader_delay, int fader_steps) {
	return push(fader_delay, fader_steps, LOGARITHMIC_DECAY);
}

FastFader& FastFader::push(int fader_delay) {
	return push(fader_delay, 10, LOGARITHMIC_DECAY);
}

FastFader& FastFader::push() {
	return push(100, 10, LOGARITHMIC_DECAY);
}

