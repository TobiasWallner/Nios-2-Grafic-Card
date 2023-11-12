#ifndef _SWRENDERER_H_
#define _SWRENDERER_H_

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "rtbase.h"

typedef struct
{
	vec3_t origin;
	vec3_t lower_left_corner;
	vec3_t horizontal;
	vec3_t vertical;
} camera_t;

typedef struct
{
	uint8_t  num_spheres;
	sphere_t spheres[MAX_NUM_OBJECTS];
	vec3_t   background;
} rt_scene_t;

class SWRenderer : public RTBase {
	public:
		SWRenderer() {};
		void SetHeight(size_t h) override { _height = h; }
		size_t GetHeight() override { return _height; }
		void SetWidth(size_t w) override { _width = w; }
		size_t GetWidth() override { return _width; }


		void SetCamera(vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov) override;
		void MoveCamera(fix16_t x, fix16_t y, fix16_t z) override; 
		void RotateCameraX(fix16_t phi) override;
		void RotateCameraY(fix16_t phi) override;
		void RotateCameraZ(fix16_t phi) override;

		void SetScene(uint8_t num_spheres, sphere_t *spheres, vec3_t background) override;

		void SetMaxReflections(int r) override {_max_reflects = r; }
		int GetMaxReflections() override { return _max_reflects; };
		void SetNumSamples(int s) override { _num_samples = s; }
		int GetNumSamples() override { return _num_samples; };

		void Render(uint32_t* buffer, size_t width_stride=0) override;

	private:
		size_t _width, _height;
		int _num_samples, _max_reflects;
		camera_t _camera;
		rt_scene_t _scene;
		vec3_t _lookfrom, _lookat;
		fix16_t _vfov;
		void PreprocessCameraSettings();
		void ApplyRotationMatrix(mat3_t mat);
};

#endif
