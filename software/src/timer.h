
#ifndef TIMER_H
#define TIMER_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stdio.h>
#include "libfixmath/fix16.h"

void timer_start_interval();

uint64_t timer_get_interval();

float timer_calc_fps(uint64_t interval);

void timer_print_interval(uint64_t interval);

#ifdef __cplusplus
}
#endif

#endif