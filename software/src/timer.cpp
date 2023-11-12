
#include "timer.h"

#ifdef OPENCV_VERSION
#include <chrono>
std::chrono::time_point<std::chrono::high_resolution_clock> interval_start;
#else
#include <sys/alt_timestamp.h>
#endif

void timer_start_interval()
{
	#ifdef OPENCV_VERSION
	interval_start = std::chrono::high_resolution_clock::now();
	#else
	alt_timestamp_start ();
	#endif
}

uint64_t timer_get_interval()
{
	#ifdef OPENCV_VERSION
	auto duration = std::chrono::high_resolution_clock::now() - interval_start;
	uint64_t duration_us = std::chrono::duration_cast<std::chrono::microseconds>(duration).count();
	return duration_us;
	#else
	return alt_timestamp();
	#endif
}

float timer_calc_fps(uint64_t interval)
{
	#ifdef OPENCV_VERSION
		return 1/((double)interval/1e6);
	#else
		return 1/((double)interval/1e8);
	#endif
}

void timer_print_interval(uint64_t interval)
{
	#ifdef OPENCV_VERSION
	printf("%ld us (%f s)", interval, (double)interval/1e6);
	#else
	printf("%lld cycles (%f s)" , interval, (double)interval/1e8);
	#endif
}
