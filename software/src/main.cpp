#include <stdint.h>
#include <stdio.h>
#include <stdint.h>
#include <malloc.h>

#include "vec3.h"
#include "sphere.h"
#include "vga.h"
#include "base64.h"
#include "timer.h"
#include "testscenes.h"
#include "swrenderer.h"
#include "hwrenderer.h"


#ifndef DEFAULT_RENDERER
#define DEFAULT_RENDERER HWRenderer
#endif


#ifdef OPENCV_VERSION
#include <opencv2/opencv.hpp>
#include <cmath>
#include <complex>
#include <future>
#include <functional>
#include <chrono>
#include <thread>
#else
#include <system.h>
#include <sys/alt_timestamp.h>
#include <altera_avalon_timer_regs.h>
#include <sys/alt_cache.h>
#endif

int use_getc = 0;

char get_user_input();
void benchmark_mode(uint32_t* frame_buffers[2]);
void interactive_mode(uint32_t* frame_buffers[2]);
void interactive_mode_help();

#ifdef OPENCV_VERSION
void copyToMat(uint32_t* buffer, cv::Mat &img);
#endif


#ifdef OPENCV_VERSION
int main(int argc, char *argv[])
#else
int main()
#endif
{
	#ifdef OPENCV_VERSION
	if (argc == 2 && strncmp(argv[1], "-c", 3) == 0) {
		use_getc = 1;
		printf("Using getc() for input!\n");
	}
	#endif

	uint32_t* frame_buffers_raw = new uint32_t[DISPLAY_WIDTH*DISPLAY_HEIGHT*2];
	uint32_t* frame_buffers[2] = {&frame_buffers_raw[0], &frame_buffers_raw[DISPLAY_HEIGHT * DISPLAY_WIDTH]};

	for (int i=0; i < DISPLAY_WIDTH*DISPLAY_HEIGHT*2; i++){
		frame_buffers_raw[i] = 0;
	}

	#ifndef OPENCV_VERSION
	if (vga_init(frame_buffers[0], frame_buffers[1]) != 0) {
		printf("Error: Unable to initialize VGA");
	} 
	#endif

	while(1) {
		#ifdef OPENCV_VERSION
		cv::imshow("input", {0.0});
		#endif

		printf("HW/SW Codesign - Raytracing \n");
		printf(" 'i': interactive mode\n 'b': benchmark mode\n 'x': quit\n");
		fflush(stdout);
		
		char user_input = get_user_input();

		#ifdef OPENCV_VERSION
		cv::destroyWindow("input");
		#endif

		switch(user_input){
			case 'b': benchmark_mode(frame_buffers); break;
			case 'i': interactive_mode(frame_buffers); break;
			case 'x': 
				#ifdef OPENCV_VERSION
				return 0;
				#else
				printf("%c",0x04); // force nios2-terminal to exit
				break;
				#endif
			default: printf("invalid selection\n"); break;
		}
	}
	return 0;
}

void run_benchmark(uint32_t* frame_buffers[2], RTBase* renderer, test_scene_t* scene, int num_samples, int max_num_reflects)
{
	#ifdef OPENCV_VERSION
	cv::Mat img(DISPLAY_HEIGHT, DISPLAY_WIDTH, CV_8UC3);
	#else
	vga_show_framebuffer(0);
	#endif

	int enable_db = 1;
	int selected_buffer = 0;
	const int frame_counter_width = 5; //32 frames
	const int frame_counter_max = 1<<frame_counter_width;

	renderer->SetNumSamples(num_samples);
	renderer->SetMaxReflections(max_num_reflects);
	renderer->SetScene(scene->num_spheres, scene->spheres, scene->background);

	//render a few frames frames
	uint64_t benchmark_time = 0;
	uint64_t frame_time = 0;
	for (int i=0; i<frame_counter_max; i++){
		selected_buffer ^= enable_db;

		scene->camera_animation(renderer, i);

		timer_start_interval();
		renderer->Render(frame_buffers[selected_buffer], 0);
		frame_time = timer_get_interval();
		benchmark_time += frame_time;

		timer_print_interval(frame_time);
		printf("\n");
		// timer_print_interval(benchmark_time);
		// printf("\n");
		// fflush(stdout);

		#ifdef OPENCV_VERSION
		copyToMat(frame_buffers[selected_buffer], img); //copy buffer to mat
		cv::imshow("benchmark", img);
		if (get_user_input()=='x') {
			break;
		}
		#else
		//flush the data cache, such that all pixels are actually written to RAM
		alt_dcache_flush_all();
		vga_show_framebuffer(selected_buffer);
		#endif
	}
	//timer_print_interval(benchmark_time);

	int64_t average_frame_time = benchmark_time >> frame_counter_width;

	printf("Average frame time: ");
	timer_print_interval(average_frame_time);
	printf("\n");
	printf("FPS: %f \n", timer_calc_fps(average_frame_time));

	printf("\n");

}

void benchmark_mode(uint32_t* frame_buffers[2])
{
	printf("Benchmark mode\n");

	#ifdef OPENCV_VERSION
	printf("Press any key to step through the benchmark. Press 'x' to quit.\n");
	#endif
	
	DEFAULT_RENDERER renderer;
	renderer.SetWidth(DISPLAY_WIDTH);
	renderer.SetHeight(DISPLAY_HEIGHT);

	printf("Running basic benchmark\n");
	run_benchmark(frame_buffers, &renderer, &basic, 1, 5);
	
	printf("Running snowman benchmark\n");
	run_benchmark(frame_buffers, &renderer, &snowman, 8, 4);

	#ifdef OPENCV_VERSION
		cv::destroyWindow("benchmark");
	#endif
}

void interactive_mode_help()
{
	printf("Commands:\n");
	printf("  Move camera\n");
	printf("    [w]: x+   [s]: x-\n");
	printf("    [e]: y+   [q]: y-\n");
	printf("    [a]: z+   [d]: z-\n");
	printf("  Rotate camera\n");
	printf("    [j]: y+   [l]: y-\n");
	printf("    [k]: z+   [i]: z-\n");
	printf("  Reset camera\n");
	printf("    [0]: view 0   [1]: view 1\n");
	printf("  [+]: Increase samples      [-]: Decrease samples\n");
	printf("  [g]: Increase reflections  [f]: Decrease reflections\n");
	printf("  [n]: Next test scene \n");
	printf("  [r]: Enable/disable low resolution mode\n");
	printf("  [t]: Enable/disable automatic rendering of frames\n");
	printf("  [p]: Dump current frame as base64\n");
	printf("  [x]: Exit\n");
}

void interactive_mode(uint32_t* frame_buffers[2])
{
	printf("Interactive mode\n");

	size_t width_stride = 0;

	fix16_t delta_phi = fix16_pi >> 5;
	fix16_t delta = 0x8000;  

	vec3_t lookfrom = {.x = {fix16_from_float(10.0f), fix16_from_float(9.0f), 0}};
	vec3_t lookat = {.x = {0, 0, 0}};
	fix16_t vfov = fix16_from_float(20.0f); /* 20 degrees */

	int scene_index = 0;

	#ifdef OPENCV_VERSION
		cv::Mat img(DISPLAY_HEIGHT, DISPLAY_WIDTH, CV_8UC3);
		copyToMat(frame_buffers[0], img); //copy buffer to mat
		cv::imshow("interactive", img);
	#else
		vga_show_framebuffer(0);
	#endif

	DEFAULT_RENDERER renderer;
	renderer.SetWidth(DISPLAY_WIDTH);
	renderer.SetHeight(DISPLAY_HEIGHT);
	renderer.SetNumSamples(1);
	renderer.SetMaxReflections(5);
	renderer.SetCamera(&lookfrom, &lookat, vfov);
	renderer.SetScene(test_scenes[scene_index]->num_spheres, test_scenes[scene_index]->spheres, test_scenes[scene_index]->background);

	interactive_mode_help();

	bool stop = false;
	while (1)
	{
		bool render_next_frame = false;
		bool auto_render = true;
		do {
			char key = get_user_input(); //blocking
			render_next_frame = auto_render;
			switch (key) {
				case 'x': stop = true; break;
				
				case 'w': renderer.MoveCamera(delta, 0, 0); break;
				case 's': renderer.MoveCamera(-delta, 0, 0); break;
				case 'a': renderer.MoveCamera(0, 0, delta); break;
				case 'd': renderer.MoveCamera(0, 0, -delta); break;
				case 'e': renderer.MoveCamera(0, delta, 0); break;
				case 'q': renderer.MoveCamera(0, -delta, 0); break;

				case 'j': renderer.RotateCameraY(delta_phi); break;
				case 'l': renderer.RotateCameraY(-delta_phi); break;

				case 'i': renderer.RotateCameraZ(-delta_phi); break;
				case 'k': renderer.RotateCameraZ(delta_phi); break;

				case '-': renderer.SetNumSamples(renderer.GetNumSamples() - 1); break;
				case '+': renderer.SetNumSamples(renderer.GetNumSamples() + 1); break;

				case 'f': renderer.SetMaxReflections(renderer.GetMaxReflections() - 1); break;
				case 'g': renderer.SetMaxReflections(renderer.GetMaxReflections() + 1); break;

				case 'n':
				 	scene_index++;
					if (scene_index >= TEST_SCENES_COUNT ) {
						scene_index = 0;
					}
					renderer.SetScene(test_scenes[scene_index]->num_spheres, test_scenes[scene_index]->spheres, test_scenes[scene_index]->background);
					break;
				case 'r':
					printf("Switched resolution to ");
					if (width_stride) {
						printf("640x480\n");
						renderer.SetWidth(640);
						renderer.SetHeight(480);
						width_stride = 0;
					} else {
						printf("64x48\n");
						renderer.SetWidth(64);
						renderer.SetHeight(48);
						width_stride = 640 - 64;
					}
					break;
				case 't':
					auto_render = !auto_render ;
					if (!auto_render) {
						printf("Automatic rendering disabled. You can now make multiple changes to the scene/camera without the frame being redrawn.\n");
					} else {
						printf("Automatic rendering enabled.\n");
					}
					render_next_frame = false;
					break;
				case '0':
					lookfrom = {.x = {fix16_from_float(10.0f), fix16_from_float(9.0f), 0}};
					lookat = {.x = {0, 0, 0}};
					renderer.SetCamera(&lookfrom, &lookat, vfov);
					renderer.SetNumSamples(1);
					renderer.SetMaxReflections(5);
					break;
				case '1':
					lookfrom = {.x = {fix16_from_float(70.0f), fix16_from_float(25.0f), 0}};
					lookat = {.x = {0, 0, 0}};
					renderer.SetCamera(&lookfrom, &lookat, vfov);
					renderer.SetNumSamples(1);
					renderer.SetMaxReflections(5);
					break;
				case 'p':
				 	base64_dump_image(frame_buffers[0], renderer.GetWidth(), renderer.GetHeight(), width_stride);
				 	render_next_frame = false;
				 	break;
				case 'h': 
					interactive_mode_help(); 
					render_next_frame = false;
					break;
				case '\r': render_next_frame = true; break;
				case '\n': render_next_frame = true; break;
				case 'c': render_next_frame = true; break;
				default: 
					render_next_frame = false;
					printf("unknown command! press 'h' for help\n");
			}
			fflush(stdout);
		} while (!render_next_frame && !stop);

		if (stop) {
			break;
		}

		printf("frame info: width=%d, height=%d, num_samples=%d, max_reflections=%d \n",
			(int)renderer.GetWidth(),
			(int)renderer.GetHeight(),
			renderer.GetNumSamples(),
			renderer.GetMaxReflections());

		timer_start_interval();
		renderer.Render(frame_buffers[0], width_stride);
		timer_print_interval(timer_get_interval());
		printf("\n");

		#ifdef OPENCV_VERSION
		copyToMat(frame_buffers[0], img); //copy buffer to mat
		cv::imshow("interactive", img);
		#else
		//flush the data cache, such that all pixels are actually written to RAM
		alt_dcache_flush_all();
		#endif
	}

	#ifdef OPENCV_VERSION
	cv::destroyWindow("interactive");
	#endif
}

char get_user_input()
{
	char key;
	#ifdef OPENCV_VERSION
		if(use_getc) {
			fflush(stdout);
			key = getchar();
		} else {
			key = cv::waitKey(0);
		} 
	#else
	key = getchar();
	#endif
	return key;
}


#ifdef OPENCV_VERSION
void copyToMat(uint32_t* buffer, cv::Mat &img)
{
	uint32_t *img_ptr = buffer;
	for (int i = 0; i < img.rows; ++i) {
		for (int j = 0; j < img.cols; ++j) {
			cv::Vec3b col;
			col[2] = *img_ptr & 0xff;
			col[1] = (*img_ptr >> 8) & 0xff;
			col[0] = (*img_ptr >> 16) & 0xff;;
			img.at<cv::Vec3b>(i,j) = col;
			(void)*img_ptr++;
		}
	}
}
#endif
