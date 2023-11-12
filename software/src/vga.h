#include <stdint.h>

#ifndef VGA_H
#define VGA_H

#ifdef __cplusplus
extern "C"
{
#endif

#define DISPLAY_HEIGHT 480
#define DISPLAY_WIDTH 640

// Initializes the pixelbuffer IP
int vga_init (uint32_t *framebuffer0, uint32_t *ramebuffer1);
// switches current back buffer to active buffer, returns index of new back buffer
int vga_swap_framebuffers(void);

void vga_show_framebuffer (uint8_t fb_num);

#ifdef __cplusplus
}
#endif

#endif
