#include "base64.h"


// based on https://stackoverflow.com/questions/342409/how-do-i-base64-encode-decode-in-c
static char encoding_table[] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
	'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
	'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
	'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3',
	'4', '5', '6', '7', '8', '9', '+', '/'
};
static int mod_table[] = {0, 2, 1};

void base64_dump_stream(const unsigned char *data, size_t input_length, int final)
{
	static int remainder = 0;
	static unsigned char octet_buf[] = {0, 0, 0};

	size_t input_idx = 0;
	int i;

	do {
		for (i = remainder; i < 3 && input_idx < input_length; i++) {
			octet_buf[i] = data[input_idx++];
		}
		remainder = i % 3;

		if (remainder != 0 && final != 0) {
			for (i = remainder; i < 3; i++) {
				octet_buf[i] = 0;
			}
		}

		if ((remainder == 0 && input_length > 0) || final != 0) {
			uint32_t triple = (octet_buf[0] << 0x10) + (octet_buf[1] << 0x08) + octet_buf[2];
			for (i = 3; i >= 0; i--) {
				putchar(encoding_table[(triple >> i * 6) & 0x3F]);
			}
		}
	} while (input_idx < input_length);

	if (final != 0) {
		for (int i = 0; i < mod_table[remainder]; i++) {
			putchar('=');
		}
		remainder = 0;
	}
}

void base64_dump(const unsigned char *data, size_t input_length)
{
	for (size_t i = 0, j = 0; i < input_length;) {
		uint32_t octet_a = i < input_length ? (unsigned char)data[i++] : 0;
		uint32_t octet_b = i < input_length ? (unsigned char)data[i++] : 0;
		uint32_t octet_c = i < input_length ? (unsigned char)data[i++] : 0;
		uint32_t triple = (octet_a << 0x10) + (octet_b << 0x08) + octet_c;
		putchar(encoding_table[(triple >> 3 * 6) & 0x3F]);
		putchar(encoding_table[(triple >> 2 * 6) & 0x3F]);
		putchar(encoding_table[(triple >> 1 * 6) & 0x3F]);
		putchar(encoding_table[(triple >> 0 * 6) & 0x3F]);
		j+=4;
	}
	for (int i = 0; i < mod_table[input_length % 3]; i++) {
		putchar('=');
	}
}

void base64_dump_image (uint32_t* image, int width, int height, int width_stride)
{
	printf("<<<<BEGIN IMAGE %d %d>>>>\n", width, height);
	for(int i=0; i<height; i++) {
		base64_dump_stream((unsigned char *)&image[i*(width+width_stride)], width*4, i==height-1);
	}
	printf("\n<<<<END IMAGE>>>>\n");
	fflush(stdout);
}
