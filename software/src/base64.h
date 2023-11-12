#ifndef BASE64_H
#define BASE64_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

/**
 * @brief Repeatedly call to continuously encode and dump the given data.
 *
 * @param data          Data to encode
 * @param input_length  Length of data (in bytes)
 * @param final         Set to nonzero to end the stream (adding padding chars)
 */
void base64_dump_stream(const unsigned char *data, size_t input_length, int final);


/**
 * @brief Call to encode and dump the given data.
 *
 * @param data          Data to encode
 * @param input_length  Length of data (in bytes)
 */
void base64_dump(const unsigned char *data, size_t input_length);



/**
 * @brief Function to endcode and dump an image. Header information specifying width and height is added.
 *
 * @param image   Pointer to the image buffer. The image must use 32 bit per RGB pixel.
 * @param width   The width of the image in pixels.
 * @param height  The height of the image in pixels.
 * @param width_stride  The horizontal stride in pixels.
 * 
 */
void base64_dump_image (uint32_t* image, int width, int height, int width_stride);


#ifdef __cplusplus
}
#endif


#endif