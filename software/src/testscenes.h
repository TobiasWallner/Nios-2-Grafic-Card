
/**
 * @brief Provides a test scene.
 */

#include "sphere.h"
#include "vec3.h"
#include "rtbase.h"

#include "libfixmath/fix16.h"


#ifndef TESTSCENE_H
#define TESTSCENE_H

#ifdef __cplusplus
extern "C"
{
#endif

typedef void (*camera_animation_fp)(RTBase*, int);

typedef struct
{
	uint8_t num_spheres;
	sphere_t* spheres;
	vec3_t background;
	camera_animation_fp camera_animation;
} test_scene_t;

#define NUM_SPHERES_SNOWMAN 9
sphere_t snowman_spheres[NUM_SPHERES_SNOWMAN] = {
		{//lower body
			.center = { {fix16_from_float (0.0), fix16_from_float (0.0), fix16_from_float (0.0)} },
			.radius = fix16_from_float (5.0),
			.color  = { {fix16_from_float (0.9), fix16_from_float (0.9), fix16_from_float (0.9)} },
			.mat    = REFLECTING
		},
		{//upper body
			.center = { {fix16_from_float (0.0), fix16_from_float (5.0), fix16_from_float (0.0)} },
			.radius = fix16_from_float (3.0),
			.color  = { {fix16_from_float (0.9), fix16_from_float (0.9), fix16_from_float (0.9)} },
			.mat    = REFLECTING
		},
		{//head
			.center = { {fix16_from_float (0.0), fix16_from_float (8.5), fix16_from_float (0.0)} },
			.radius = fix16_from_float (1.5),
			.color  = { {fix16_from_float (0.8), fix16_from_float (0.8), fix16_from_float (0.8)} },
			.mat    = REFLECTING
		},
		{//left arm
			.center = { {fix16_from_float (0.0), fix16_from_float (6.0), fix16_from_float (3.6)} },
			.radius = fix16_from_float (0.8),
			.color  = { {fix16_from_float (0.8), fix16_from_float (0.8), fix16_from_float (0.8)} },
			.mat    = REFLECTING
		},
		{//right arm
			.center = { {fix16_from_float (0.0), fix16_from_float (6.0), fix16_from_float (-3.6)} },
			.radius = fix16_from_float (0.8),
			.color  = { {fix16_from_float (0.8), fix16_from_float (0.8), fix16_from_float (0.8)} },
			.mat    = REFLECTING
		},
		{//base sphere
			.center = { {fix16_from_float (0.0), fix16_from_float (-102.5), fix16_from_float (0.0)} },
			.radius = fix16_from_float (100.0),
			.color  = { {fix16_from_float (0.7), fix16_from_float (0.7), fix16_from_float (0.7)} },
			.mat    = REFLECTING
		},
		{//red ball 
			.center = { {fix16_from_float (1.5), fix16_from_float (3.0), fix16_from_float (6.5)} },
			.radius = fix16_from_float (0.75),
			.color  = { {fix16_from_float (1.0), fix16_from_float (0.1), fix16_from_float (0.1)} },
			.mat    = REFLECTING
		},
		{//green ball
			.center = { {fix16_from_float (-2.0), fix16_from_float (7.0), fix16_from_float (-6.0)} },
			.radius = fix16_from_float (0.75),
			.color  = { {fix16_from_float (0.1), fix16_from_float (1.0), fix16_from_float (0.1)} },
			.mat    = REFLECTING
		},
		{//blue ball 
			.center = { {fix16_from_float (-0.5), fix16_from_float (10.0), fix16_from_float (4.0)} },
			.radius = fix16_from_float (0.75),
			.color  = { {fix16_from_float (0.1), fix16_from_float (0.1), fix16_from_float (1.0)} },
			.mat    = REFLECTING
		}
};

void snowman_camera_animation (RTBase* renderer, int frame_counter)
{
	static fix16_t phi = 0;
	if (frame_counter == 0) {
		 phi = 0;
	}

	const fix16_t height = fix16_from_float(25);
	const fix16_t radius = fix16_from_float(70);
	const fix16_t phi_step = fix16_pi >> 4; // 2 pi / 32 == 32 steps 

	vec3_t lookat = {.x = {0, 0, 0}};
	vec3_t lookfrom;

	fix16_t vfov = fix16_from_float(20.0); // 20 degrees 
	lookfrom.x[0] = fix16_mul (radius, fix16_cos (phi));
	lookfrom.x[1] = height + fix16_mul (fix16_from_float(10), fix16_sin (phi));; // fixed height 
	lookfrom.x[2] = fix16_mul (radius, fix16_sin (phi));

	phi += phi_step;
	while (phi > fix16_pi << 1) {
		phi -= fix16_pi << 1;
	}

	renderer->SetCamera(&lookfrom, &lookat, vfov);
}

test_scene_t snowman = {
	.num_spheres = NUM_SPHERES_SNOWMAN,
	.spheres = snowman_spheres,
	.background = { {fix16_from_float (0.4), fix16_from_float (0.4), fix16_from_float (0.7)} },
	.camera_animation = &snowman_camera_animation
};

#define NUM_SPHERES_BASIC 5
sphere_t basic_spheres[NUM_SPHERES_BASIC] = {
		{
			.center = { {fix16_from_float (0.8), fix16_from_float (0.0), fix16_from_float (0.0)} },
			.radius = fix16_from_float (0.5),
			.color  = { {fix16_from_float (1.0), fix16_from_float (0.3), fix16_from_float (0.3)} },
			.mat    = REFLECTING
		},
		{
			.center = { {fix16_from_float (0.0), fix16_from_float (0.0), fix16_from_float (0.8)} },
			.radius = fix16_from_float (0.5),
			.color  = { {fix16_from_float (0.3), fix16_from_float (1.0), fix16_from_float (0.3)} },
			.mat    = REFLECTING
		},
		{
			.center = { {fix16_from_float (0.0), fix16_from_float (0.0), fix16_from_float (-0.8)} },
			.radius = fix16_from_float (0.5),
			.color  = { {fix16_from_float (0.3), fix16_from_float (0.3), fix16_from_float (1.0)} },
			.mat    = REFLECTING
		},
		{
			.center = { {fix16_from_float (0.0), fix16_from_float (60.0), fix16_from_float (0.0)} },
			.radius = fix16_from_float (50.0),
			.color  = { {fix16_from_float (1.0), fix16_from_float (1.0), fix16_from_float (1.0)} },
			.mat    = EMITTING
		},
		{
			.center = { {fix16_from_float (0.0), fix16_from_float (-100), fix16_from_float (0.0)} },
			.radius = fix16_from_float (100.0),
			.color  = { {fix16_from_float (0.4), fix16_from_float (0.4), fix16_from_float (0.4)} },
			.mat    = REFLECTING
		}
};

void basic_camera_animation (RTBase* renderer, int frame_counter)
{
	static fix16_t phi = 0;
	if (frame_counter == 0) {
		 phi = 0;
	}

	const fix16_t height = fix16_from_float(9);
	const fix16_t radius = fix16_from_float(10);
	const fix16_t phi_step = fix16_pi >> 4; // 2 pi / 32 == 32 steps 

	vec3_t lookat = {.x = {0, 0, 0}};
	vec3_t lookfrom;

	fix16_t vfov = fix16_from_float(20.0); // 20 degrees 
	lookfrom.x[0] = fix16_mul (radius, fix16_cos (phi));
	lookfrom.x[1] = height; // fixed height 
	lookfrom.x[2] = fix16_mul (radius, fix16_sin (phi));

	phi += phi_step;
	while (phi > fix16_pi << 1) {
		phi -= fix16_pi << 1;
	}

	renderer->SetCamera(&lookfrom, &lookat, vfov);
}

test_scene_t basic = {
	.num_spheres = NUM_SPHERES_BASIC,
	.spheres = basic_spheres,
	.background = { {fix16_from_float (0.0), fix16_from_float (0.0), fix16_from_float (0.0)} },
	.camera_animation = &basic_camera_animation

};

#define TEST_SCENES_COUNT 2
test_scene_t* test_scenes[TEST_SCENES_COUNT] = {&basic, &snowman};


#ifdef __cplusplus
}
#endif

#endif
