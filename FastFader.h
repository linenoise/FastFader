/*
||
|| @file FastFader.h
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

#ifndef FASTFADER_H
#define FASTFADER_H

#include "../FastLED/FastLED.h"
#include <math.h>

#define NO_DECAY (-1)
#define LINEAR_DECAY (0)
#define LOGARITHMIC_DECAY (1)

class FastFader {
	public:
		FastFader();

		FastFader& bind(int (*pixel_buffer)[3], CRGB *leds, int num_leds, CFastLED& fast_led);

		FastFader& clear();

		FastFader& set_pixel(int pos, int value, int channel);
		FastFader& set_pixel(int pos, int value[3]);
		FastFader& set_pixel(int pos, int value);
		FastFader& set_pixel(int pos);

		int* get_pixel(int pos);

		FastFader& set_frame(int (*frame)[3]);

		FastFader& push(int fader_delay, int fader_steps, int decay_type);
		FastFader& push(int fader_delay, int fader_steps);
		FastFader& push(int fader_delay);
		FastFader& push();

	private:
		int      NumLEDs;
		int      (*PixelBuffer)[3];
		CRGB     *LEDs;
		CFastLED FLED;
};

#endif