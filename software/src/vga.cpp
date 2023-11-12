#include "vga.h"
#include "system.h"
#include <io.h>
#include <altera_up_avalon_video_pixel_buffer_dma.h>

static uint32_t* frame_buffers[2];

static uint32_t *cur_base;
static alt_up_pixel_buffer_dma_dev *pbd_dev;

int 
vga_init (uint32_t *framebuffer0, uint32_t *framebuffer1)
{
	// Get device pointer to pixelbuffer
	pbd_dev = alt_up_pixel_buffer_dma_open_dev("/dev/pixelbuffer");
	if(pbd_dev == NULL) {
		return -1;
	}

	// Configure pixelbuffer's memory addresses to passed framebuffers
	alt_up_pixel_buffer_dma_change_back_buffer_address(pbd_dev, (unsigned) framebuffer0);
	alt_up_pixel_buffer_dma_swap_buffers(pbd_dev);
	while(alt_up_pixel_buffer_dma_check_swap_buffers_status(pbd_dev) == 1);	// Wait until back / active buffer swapped
	alt_up_pixel_buffer_dma_change_back_buffer_address(pbd_dev, (unsigned) framebuffer1);

	cur_base = framebuffer1;
	frame_buffers[0] = framebuffer0;
	frame_buffers[1] = framebuffer1;

	return 0;
}

int
vga_swap_framebuffers (void)
{
	// Wait for former frame to be done
	while(alt_up_pixel_buffer_dma_check_swap_buffers_status(pbd_dev) == 1);
	alt_up_pixel_buffer_dma_swap_buffers(pbd_dev);
	int cur_fb = cur_base == frame_buffers[0] ? 1 : 0;
	cur_base = frame_buffers[cur_fb];
	return cur_fb;
}

void 
vga_show_framebuffer (uint8_t fb_num)
{
	if (pbd_dev->back_buffer_start_address == (uint32_t)frame_buffers[fb_num & 0x1]) {
		vga_swap_framebuffers();
	}
}

