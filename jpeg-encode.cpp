#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

#include <jpeglib.h>

namespace jpeg_encode {
struct image {
	~image();
	uint32_t width;
	uint32_t height;
	uint32_t stride;
	uint8_t *data;
	size_t size;
};

image::~image()
{
	delete [] data;
}

bool
planar2rgb(struct image *in, struct image *out)
{
	size_t y, x, plane_size;

	out->width = in->width;
	out->height = in->height;
	out->stride = in->width * 3;
	out->data = new uint8_t[out->height * out->stride];

	plane_size = in->height * in->stride;

	printf("in.w:%d in.h:%d in.s:%d out.w:%d out.h:%d out.s:%d ps:%lu\n",
	       in->width, in->height, in->stride,
	       out->width, out->height, out->stride,
	       (unsigned long)plane_size);

	for (y = 0; y < in->height; ++y) {
		uint8_t *sr = in->data + y * in->stride;
		uint8_t *sg = sr + plane_size;
		uint8_t *sb = sg + plane_size;
		uint8_t *dp = out->data + y * out->stride;
		for (x = 0; x < in->width; ++x) {
			*dp = *sr;
			if (*dp != 0 && *dp != 255)
				printf("value error x:%ld y:%ld v:%d\n",
				       x, y, *dp);
			*dp++ = *sr++;
			*dp++ = *sg++;
			*dp++ = *sb++;
			if (x == 0 && y % 60 == 0)
				printf("%02x.%02x.%02x\n",
				       *(dp - 3), *(dp - 2), *(dp -1));
		}
	}

	return true;
}

bool
rgb2jpeg(struct image *in, struct image *out, int quality) {
	jpeg_compress_struct cinfo = jpeg_compress_struct();
	jpeg_error_mgr jerr;
	JSAMPROW raw_ptr[1];
	int row_stride;

	out->width = in->width;
	out->height = in->height;
	out->stride = 0;
	out->data = nullptr;
	out->size = 0;

	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_compress(&cinfo);
	jpeg_mem_dest(&cinfo, &out->data, &out->size);

	cinfo.image_width = in->width;
	cinfo.image_height = in->height;
	cinfo.input_components = 3;
	cinfo.in_color_space = JCS_RGB;

	jpeg_set_defaults(&cinfo);
	jpeg_set_quality(&cinfo, quality, TRUE);
	jpeg_start_compress(&cinfo, TRUE);
	while (cinfo.next_scanline < cinfo.image_height) {
		raw_ptr[0] = &in->data[cinfo.next_scanline * in->stride];
		jpeg_write_scanlines(&cinfo, raw_ptr, 1);
	}

	jpeg_finish_compress(&cinfo);
	jpeg_destroy_compress(&cinfo);

	return true;
}
} /* namespace jpeg_encode */

#ifdef TEST

#include <fcntl.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define PLANAR_WIDTH 640
#define PLANAR_HEIGHT 480
#define PLANAR_STRIDE 768

void
planar_pattern(uint8_t *buf)
{
	size_t x, y;
	size_t width = PLANAR_WIDTH;
	size_t height = PLANAR_HEIGHT;
	size_t stride = PLANAR_STRIDE;
	size_t ps = stride * height;

	for (y = 0; y < PLANAR_HEIGHT; ++y)
		for (x = 0; x < PLANAR_STRIDE; ++x)
			if (x < PLANAR_WIDTH) {
				switch (y / 60 % 8) {
				case 0:
					buf[x + y * stride] = 0;
					buf[x + y * stride + ps] = 0;
					buf[x + y * stride + 2*ps] = 0;
					break;
				case 1:
					buf[x + y * stride] = 255;
					buf[x + y * stride + ps] = 0;
					buf[x + y * stride + 2*ps] = 0;
					break;
				case 2:
					buf[x + y * stride] = 0;
					buf[x + y * stride + ps] = 255;
					buf[x + y * stride + 2*ps] = 0;
					break;
				case 3:
					buf[x + y * stride] = 255;
					buf[x + y * stride + ps] = 255;
					buf[x + y * stride + 2*ps] = 0;
					break;
				case 4:
					buf[x + y * stride] = 0;
					buf[x + y * stride + ps] = 0;
					buf[x + y * stride + 2*ps] = 255;
					break;
				case 5:
					buf[x + y * stride] = 255;
					buf[x + y * stride + ps] = 0;
					buf[x + y * stride + 2*ps] = 255;
					break;
				case 6:
					buf[x + y * stride] = 0;
					buf[x + y * stride + ps] = 255;
					buf[x + y * stride + 2*ps] = 255;
					break;
				case 7:
					buf[x + y * stride] = 255;
					buf[x + y * stride + ps] = 255;
					buf[x + y * stride + 2*ps] = 255;
					break;
				}
			} else {
#define RND ((random() >> 12) & ((1 << CHAR_BIT) - 1))
				buf[x + y * stride] = RND;
				buf[x + y * stride + ps] = RND;
				buf[x + y * stride + 2*ps] = RND;
			}
}

void
rgb_pattern(uint8_t *buf)
{
	size_t x, y;

	for (y = 0; y < 480; ++y)
		for (x = 0; x < 640; ++x)
			switch (y / 60 % 8)
			{
			case 0:
				buf[3 * x + 0 + y * 640 * 3] = 0;
				buf[3 * x + 1 + y * 640 * 3] = 0;
				buf[3 * x + 2 + y * 640 * 3] = 0;
				break;
			case 1:
				buf[3 * x + 0 + y * 640 * 3] = 255;
				buf[3 * x + 1 + y * 640 * 3] = 0;
				buf[3 * x + 2 + y * 640 * 3] = 0;
				break;
			case 2:
				buf[3 * x + 0 + y * 640 * 3] = 0;
				buf[3 * x + 1 + y * 640 * 3] = 255;
				buf[3 * x + 2 + y * 640 * 3] = 0;
				break;
			case 3:
				buf[3 * x + 0 + y * 640 * 3] = 255;
				buf[3 * x + 1 + y * 640 * 3] = 255;
				buf[3 * x + 2 + y * 640 * 3] = 0;
				break;
			case 4:
				buf[3 * x + 0 + y * 640 * 3] = 0;
				buf[3 * x + 1 + y * 640 * 3] = 0;
				buf[3 * x + 2 + y * 640 * 3] = 255;
				break;
			case 5:
				buf[3 * x + 0 + y * 640 * 3] = 255;
				buf[3 * x + 1 + y * 640 * 3] = 0;
				buf[3 * x + 2 + y * 640 * 3] = 255;
				break;
			case 6:
				buf[3 * x + 0 + y * 640 * 3] = 0;
				buf[3 * x + 1 + y * 640 * 3] = 255;
				buf[3 * x + 2 + y * 640 * 3] = 255;
				break;
			case 7:
				buf[3 * x + 0 + y * 640 * 3] = 255;
				buf[3 * x + 1 + y * 640 * 3] = 255;
				buf[3 * x + 2 + y * 640 * 3] = 255;
				break;
			}
}

int
main(int ac, char **av)
{
	int fd;
	jpeg_encode::image raw, rgb, jpeg;

	raw.width = PLANAR_WIDTH;
	raw.height = PLANAR_HEIGHT;
	raw.stride = PLANAR_STRIDE;
	raw.size = PLANAR_HEIGHT * PLANAR_STRIDE * 3;

	uint8_t *buf = new uint8_t[raw.size];
	planar_pattern(buf);

	fd = open("test.raw", O_WRONLY | O_CREAT | O_TRUNC, 0640);
	write(fd, buf, raw.size);
	close(fd);

	raw.data = buf;
	jpeg_encode::planar2rgb(&raw, &rgb);

	fd = open("test.rgb", O_WRONLY | O_CREAT | O_TRUNC, 0640);
	write(fd, rgb.data, rgb.stride * rgb.height);
	close(fd);

	jpeg_encode::rgb2jpeg(&rgb, &jpeg, 90);
	printf("width:%d height:%d stride:%d size:%ld\n",
	       jpeg.width, jpeg.height, jpeg.stride, jpeg.size);
	
	fd = open("test.jpeg", O_WRONLY | O_CREAT | O_TRUNC, 0640);
	write(fd, jpeg.data, jpeg.size);
	close(fd);

	return 0;
}
#endif
