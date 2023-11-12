

#ifndef _RTBASE_H_
#define _RTBASE_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "vec3.h"
#include "sphere.h"

enum {MAX_NUM_OBJECTS = 16};

class RTBase {
	public:
		virtual ~RTBase() {};

		virtual void SetWidth(size_t w) = 0;
		virtual size_t GetWidth() = 0;
		virtual void SetHeight(size_t h) = 0;
		virtual size_t GetHeight() = 0;

		virtual void SetCamera(vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov) = 0;
		virtual void MoveCamera(fix16_t x, fix16_t y, fix16_t z) = 0; 
		virtual void RotateCameraX(fix16_t phi) = 0;
		virtual void RotateCameraY(fix16_t phi) = 0;
		virtual void RotateCameraZ(fix16_t phi) = 0;

		virtual void SetScene(uint8_t num_spheres, sphere_t *spheres, vec3_t background) = 0;

		virtual void SetMaxReflections(int r) = 0;
		virtual int GetMaxReflections() = 0;
		virtual void SetNumSamples(int s) = 0;
		virtual int GetNumSamples() = 0;

		virtual void Render(uint32_t* buffer, size_t width_stride=0) = 0;

};

#endif
