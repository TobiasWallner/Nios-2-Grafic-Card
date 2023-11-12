
#include "swrenderer.h"

#define copy_vec3_from_pointer(dest,src) do { dest.x[0] = src->x[0]; dest.x[1] = src->x[1]; dest.x[2] = src->x[2]; } while(0);

void SWRenderer::SetScene(uint8_t num_spheres, sphere_t *spheres, vec3_t background)
{
	if (num_spheres > MAX_NUM_OBJECTS) {
		num_spheres = MAX_NUM_OBJECTS;
	}

	for (uint8_t i = 0; i < num_spheres; ++i) {
		_scene.spheres[i] = spheres[i];
	}
	
	_scene.num_spheres      = num_spheres;
	_scene.background       = background;
}

void SWRenderer::SetCamera(vec3_t *lookfrom, vec3_t *lookat, fix16_t vfov)
{
	_lookat = *lookat;
	_lookfrom = *lookfrom;
	_vfov = vfov;

	PreprocessCameraSettings();
}

void SWRenderer::PreprocessCameraSettings()
{
	const fix16_t aspect = fix16_div (fix16_from_int (_width), fix16_from_int (_height));
	const fix16_t rpd = fix16_div (fix16_pi, fix16_from_int (180));

	fix16_t theta = fix16_mul (_vfov, rpd);
	fix16_t half_height = fix16_tan (theta >> 1); /* theta/2 */
	fix16_t half_width = fix16_mul (aspect, half_height);

	_camera.origin = _lookfrom;

	vec3_t u, v, w;
	vec3Sub (&w, &_lookfrom, &_lookat);
	vec3UnitVector (&w, &w);

	/* u = unit_vector (cross (vup, w)) */
	vec3_t vup = { {0, fix16_from_int (1), 0} };
	vec3Cross (&u, &vup, &w);
	vec3UnitVector (&u, &u);

	vec3Cross (&v, &w, &u); /* v = cross (w, u) */

	/* horizontal = 2 * half_width * u, vertical similar */
	vec3MulS (&_camera.horizontal, half_width<<1, &u);
	vec3MulS (&_camera.vertical, half_height<<1, &v);
	/* llc = lookfrom - half_width*u - half_height*v - w */
	vec3MulS (&u, half_width, &u);
	vec3MulS (&v, half_height, &v);
	vec3Sub (&_camera.lower_left_corner, &_lookfrom, &u);
	vec3Sub (&_camera.lower_left_corner, &_camera.lower_left_corner, &v);
	vec3Sub (&_camera.lower_left_corner, &_camera.lower_left_corner, &w);
}

void SWRenderer::MoveCamera(fix16_t x, fix16_t y, fix16_t z)
{
	vec3_t temp {.x = {x, y, z}};
	vec3Add(&_lookfrom, &_lookfrom, &temp);
	vec3Add(&_lookat, &_lookat, &temp);
	PreprocessCameraSettings();
}

void SWRenderer::RotateCameraX(fix16_t phi)
{
	mat3_t rot_x;
	mat3_identity(&rot_x);
	rot_x.m[1][1] = fix16_cos (phi);
	rot_x.m[1][2] = -fix16_sin (phi);
	rot_x.m[2][1] = fix16_sin (phi);
	rot_x.m[2][2] = fix16_cos (phi);
	ApplyRotationMatrix(rot_x);
}

void SWRenderer::RotateCameraY(fix16_t phi)
{
	mat3_t rot_y;
	mat3_identity(&rot_y);
	rot_y.m[0][0] = fix16_cos (phi);
	rot_y.m[0][2] = fix16_sin (phi);
	rot_y.m[2][0] = -fix16_sin (phi);
	rot_y.m[2][2] = fix16_cos (phi);
	ApplyRotationMatrix(rot_y);
}

void SWRenderer::RotateCameraZ(fix16_t phi)
{
	mat3_t rot_z;
	mat3_identity(&rot_z);
	rot_z.m[0][0] = fix16_cos (phi);
	rot_z.m[0][1] = -fix16_sin (phi);
	rot_z.m[1][0] = fix16_sin (phi);
	rot_z.m[1][1] = fix16_cos (phi);
	ApplyRotationMatrix(rot_z);
}

void SWRenderer::ApplyRotationMatrix(mat3_t mat)
{
	vec3_t dir;
	vec3Sub(&dir, &_lookat, &_lookfrom);
	mat3_mul_vec3(&_lookat, &mat, &dir);
	vec3Add(&_lookat, &_lookat, &_lookfrom);
	PreprocessCameraSettings();
}


static const fix16_t time_min = 0x199A; /* 0.1 in 16.16 */


/* result = lower_let_corner + s*horizontal + s*vertical - origin */
static inline void
getRayDir (vec3_t *res, fix16_t s, fix16_t t, camera_t camera)
{
	vec3_t tmp;
	vec3MulS (&tmp, s, &camera.horizontal);
	vec3MulS (res, t, &camera.vertical);
	vec3Add (res, res, &tmp);
	vec3Add (res, res, &camera.lower_left_corner);
	vec3Sub (res, res, &camera.origin);
}

static inline sphere_t*
getClosestSphere (fix16_t *t_min, const vec3_t *origin, const vec3_t *dir, rt_scene_t scene)
{
	sphere_t *nearest_obj = NULL;
	*t_min = fix16_maximum;

	fix16_t a = vec3Dot (dir, dir); // x^2 + y^2 + z^2
	for (uint8_t i = 0; i < scene.num_spheres; ++i) {
		vec3_t oc;
		vec3Sub (&oc, origin, &scene.spheres[i].center);
		fix16_t b = vec3Dot (&oc, dir);
		fix16_t c = vec3Dot (&oc, &oc) -
			fix16_mul (scene.spheres[i].radius, scene.spheres[i].radius);
		fix16_t discr = fix16_mul (b, b) - fix16_mul (a, c);
		if (discr > 0) {
			discr = fix16_sqrt (discr);
			fix16_t t = fix16_div (-b - discr, a);
			/* check first solution */
			if (t > time_min && t < *t_min) {
				*t_min = t;
				nearest_obj = &scene.spheres[i];
				continue;
			}
			/* check second solution */
			t = fix16_div (-b + discr, a);
			if (t > time_min && t < *t_min) {
				*t_min = t;
				nearest_obj = &scene.spheres[i];
				continue;
			}
		}
	}
	return nearest_obj;
}

/**
 * @brief Reflect ray v
 *
 * @param r Resulting ray r = v - 2 * dot(v,n) * n
 * @param v Incoming ray
 * @param n Surface normal
 */
static inline void
reflect (vec3_t *r, vec3_t *v, vec3_t *n)
{
	vec3_t tmp;
	fix16_t t = fix16_mul (fix16_one << 1, vec3Dot (v, n));
	vec3MulS (&tmp, t, n);
	vec3Sub (r, v, &tmp);
}

static uint16_t lfsr;
static inline uint16_t lfsr_next()
{
	uint16_t bit = ((lfsr >> 0) ^ (lfsr >> 2) ^ (lfsr >> 3) ^ (lfsr >> 5)) & 1u;
	lfsr = (lfsr >> 1) | (bit << 15);
	return lfsr;
}

void SWRenderer::Render(uint32_t* buffer, size_t width_stride) 
{
	const fix16_t f_height_r = fix16_div (fix16_one, fix16_from_int (_height));
	const fix16_t f_width_r = fix16_div (fix16_one, fix16_from_int (_width));
	const fix16_t num_samples_r = fix16_div (fix16_one, fix16_from_int (_num_samples));

	for (int16_t j = _height - 1; j >= 0; --j) {

		for (uint16_t i = 0; i < _width; ++i) {
			vec3_t col = { {0, 0, 0} };
			// Always use the same random values for each pixel, to make sure results are reproducible! 
			// You will have to consider this in your implementation!
			lfsr = 0xabed; 

			/* average over samples */
			for (uint16_t s = 0; s < _num_samples; ++s) {
				vec3_t col_tmp = { {fix16_one, fix16_one, fix16_one} };
				/* set ray origin */
				vec3_t ray_origin = _camera.origin;

				/* set ray direction */
				// lfsr_next returns a 16 bit random number, interpreted as a fix16_t value
				// this corresponds to a value between 0 and 1
				// make sure that your renderer produces the SAME random 
				
				/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				 *  
				 * stopped here building the dependency and dataflow
				 * graph
				 * 
				 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
				 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/
				
				fix16_t u = fix16_mul (fix16_from_int (i) + lfsr_next(), f_width_r);
				fix16_t v = fix16_mul (fix16_from_int (j) + lfsr_next(), f_height_r);
				vec3_t ray_dir;
				getRayDir (&ray_dir, u, v, _camera);

				/* reflection loop, break if emitting object or no object is hit */
				sphere_t *nearest_obj = NULL;
				uint16_t k = this->_max_reflects;
				for (; k > 0; --k) {
					fix16_t tmin;
					nearest_obj = getClosestSphere (&tmin, &ray_origin, &ray_dir, _scene);
					if (nearest_obj != NULL) {
						vec3Mul (&col_tmp, &col_tmp, &nearest_obj->color);
						if (nearest_obj->mat == EMITTING) {
							break;
						}
						/* if not emitting reflect */
						/* ray_origin = ray_origin + t * ray_dir */
						vec3_t tmp;
						vec3MulS (&tmp, tmin, &ray_dir);
						vec3Add (&ray_origin, &tmp, &ray_origin);
						/* n = (ray_origin - center) / radius  */
						vec3_t n; /* surface normal */
						vec3Sub (&n, &ray_origin, &nearest_obj->center);
						fix16_t rr = fix16_div (fix16_one, nearest_obj->radius);
						vec3MulS (&n, rr, &n);
						reflect (&ray_dir, &ray_dir, &n);
					} else {
						/* ray miss */
						vec3Mul (&col_tmp, &col_tmp, &_scene.background);
						break;
					}
				}

				/* max num reflects reached */
				if (k == 0) {
					col_tmp.x[0] = 0;
					col_tmp.x[1] = 0;
					col_tmp.x[2] = 0;
				}

				vec3Add (&col, &col, &col_tmp);
			}

			/* set pixel */
			vec3MulS (&col, num_samples_r, &col); /* col /= num_samples */
			vec3Sqrt (&col, &col); /* gamma correction */
			/* pack rgb values into one 32 bit value */
			fix16_t bit_mask = 255 << 16;
			col.x[2] = fix16_mul (col.x[2], bit_mask) & bit_mask;
			bit_mask = 255 << 8;
			col.x[1] = fix16_mul (col.x[1], bit_mask) & bit_mask;
			bit_mask = 255;
			col.x[0] = fix16_mul (col.x[0], bit_mask) & bit_mask;
			uint32_t rgb = col.x[0] | col.x[1] | col.x[2];

			buffer[((_height-1-j)*(_width+width_stride) + i)] = rgb;
		}
	}
}
