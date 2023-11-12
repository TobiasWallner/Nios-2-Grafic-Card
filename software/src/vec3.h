#ifndef VEC3_H
#define VEC3_H

#include "libfixmath/fix16.h"

#ifdef __cplusplus
extern "C"
{
#endif

typedef struct { fix16_t x[3]; } vec3_t;
typedef struct { fix16_t m[3][3]; } mat3_t;


/* arithmetic options on vector type */
static inline void
vec3Add (vec3_t *res, const vec3_t *l, const vec3_t *r)
{
	res->x[0] = l->x[0] + r->x[0];
	res->x[1] = l->x[1] + r->x[1];
	res->x[2] = l->x[2] + r->x[2];
}

static inline void
vec3Sub (vec3_t *res, const vec3_t *l, const vec3_t *r)
{
	res->x[0] = l->x[0] - r->x[0];
	res->x[1] = l->x[1] - r->x[1];
	res->x[2] = l->x[2] - r->x[2];
}

/* multiplication with scalar */
static inline void
vec3MulS (vec3_t *res, const fix16_t s, const vec3_t *v)
{
	res->x[0] = fix16_mul (s, v->x[0]);
	res->x[1] = fix16_mul (s, v->x[1]);
	res->x[2] = fix16_mul (s, v->x[2]);
}

/* componentwise multiplication */
static inline void
vec3Mul (vec3_t *res, const vec3_t *l, const vec3_t *r)
{
	res->x[0] = fix16_mul (l->x[0], r->x[0]);
	res->x[1] = fix16_mul (l->x[1], r->x[1]);
	res->x[2] = fix16_mul (l->x[2], r->x[2]);
}

/* componentwise division */
static inline void
vec3DivS (vec3_t *res, const vec3_t *v, const fix16_t s)
{
	res->x[0] = fix16_div (v->x[0], s);
	res->x[1] = fix16_div (v->x[1], s);
	res->x[2] = fix16_div (v->x[2], s);
}

/* componentwise square root */
static inline void
vec3Sqrt (vec3_t *res, const vec3_t *v)
{
	res->x[0] = fix16_sqrt (v->x[0]);
	res->x[1] = fix16_sqrt (v->x[1]);
	res->x[2] = fix16_sqrt (v->x[2]);
}

/* dot product */
static inline fix16_t
vec3Dot (const vec3_t *l, const vec3_t *r)
{
	fix16_t v = fix16_mul (l->x[0], r->x[0]);
	v += fix16_mul (l->x[1], r->x[1]);
	v += fix16_mul (l->x[2], r->x[2]);
	return v;
}

/* cross product */
static inline void
vec3Cross (vec3_t *res, const vec3_t *l, const vec3_t *r)
{
	vec3_t tmp;
	tmp.x[0] = fix16_mul (l->x[1], r->x[2]) - fix16_mul (l->x[2], r->x[1]);
	tmp.x[1] = fix16_mul (l->x[2], r->x[0]) - fix16_mul (l->x[0], r->x[2]);
	tmp.x[2] = fix16_mul (l->x[0], r->x[1]) - fix16_mul (l->x[1], r->x[0]);
	*res = tmp;
}

static inline void
vec3UnitVector (vec3_t *res, const vec3_t *v)
{
	fix16_t lenr = fix16_div (fix16_one, fix16_sqrt (vec3Dot (v, v)));
	res->x[0] = fix16_mul (v->x[0], lenr);
	res->x[1] = fix16_mul (v->x[1], lenr);
	res->x[2] = fix16_mul (v->x[2], lenr);
}

static inline fix16_t
vec3Length (vec3_t *v)
{
	return fix16_div (fix16_one, fix16_sqrt (vec3Dot (v, v)));
}

static inline void
mat3_mul_vec3(vec3_t* res, const mat3_t *mat, const vec3_t *v)
{
	res->x[0] = fix16_mul (mat->m[0][0], v->x[0]) + fix16_mul (mat->m[0][1], v->x[1]) + fix16_mul (mat->m[0][2], v->x[2]); 
	res->x[1] = fix16_mul (mat->m[1][0], v->x[0]) + fix16_mul (mat->m[1][1], v->x[1]) + fix16_mul (mat->m[1][2], v->x[2]); 
	res->x[2] = fix16_mul (mat->m[2][0], v->x[0]) + fix16_mul (mat->m[2][1], v->x[1]) + fix16_mul (mat->m[2][2], v->x[2]); 
}

static inline void
mat3_identity(mat3_t *mat)
{
	for(int i=0; i<3; i++) {
		for(int j=0; j<3; j++) {
			if (i==j) {
				mat->m[i][j] = 0x10000;
			} else {
				mat->m[i][j] = 0;
			}
		}
	}
}

#ifdef __cplusplus
}
#endif

#endif
