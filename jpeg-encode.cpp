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
	out->stride = in->width;
	out->data = new uint8_t[out->width * out->stride * 3];

	plane_size = in->height * in->stride;

	for (y = 0; y < in->height; ++y) {
		uint8_t *sr = in->data + y * in->stride;
		uint8_t *sg = sr + plane_size;
		uint8_t *sb = sg + plane_size;
		uint8_t *dp = out->data + y * out->width * 3;
		for (x = 0; x < in->width; ++x) {
			*dp++ = *sr++;
			*dp++ = *sg++;
			*dp++ = *sb++;
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
	out->stride = in->width;
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
		raw_ptr[0] = &in->data[cinfo.next_scanline * 3 * in->stride];
		jpeg_write_scanlines(&cinfo, raw_ptr, 1);
	}

	jpeg_finish_compress(&cinfo);
	jpeg_destroy_compress(&cinfo);

	return true;
}
} /* namespace jpeg_encode */

#ifdef TEST

#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

void
planar_pattern(uint8_t *buf)
{
	size_t x, y;
	size_t ps = 640 * 480;

	for (y = 0; y < 480; ++y)
		for (x = 0; x < 640; ++x)
			switch (y / 60 % 8)
			{
			case 0:
				buf[x + y * 640] = 0;
				buf[x + y * 640 + ps] = 0;
				buf[x + y * 640 + 2*ps] = 0;
				break;
			case 1:
				buf[x + y * 640] = 255;
				buf[x + y * 640 + ps] = 0;
				buf[x + y * 640 + 2*ps] = 0;
				break;
			case 2:
				buf[x + y * 640] = 0;
				buf[x + y * 640 + ps] = 255;
				buf[x + y * 640 + 2*ps] = 0;
				break;
			case 3:
				buf[x + y * 640] = 255;
				buf[x + y * 640 + ps] = 255;
				buf[x + y * 640 + 2*ps] = 0;
				break;
			case 4:
				buf[x + y * 640] = 0;
				buf[x + y * 640 + ps] = 0;
				buf[x + y * 640 + 2*ps] = 255;
				break;
			case 5:
				buf[x + y * 640] = 255;
				buf[x + y * 640 + ps] = 0;
				buf[x + y * 640 + 2*ps] = 255;
				break;
			case 6:
				buf[x + y * 640] = 0;
				buf[x + y * 640 + ps] = 255;
				buf[x + y * 640 + 2*ps] = 255;
				break;
			case 7:
				buf[x + y * 640] = 255;
				buf[x + y * 640 + ps] = 255;
				buf[x + y * 640 + 2*ps] = 255;
				break;
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
	uint8_t *buf = new uint8_t[640*480*3];
	planar_pattern(buf);
	jpeg_encode::image raw, rgb, jpeg;

	raw.width = 640;
	raw.height = 480;
	raw.stride = 640;
	raw.size = 640*480*3;
	raw.data = buf;
	jpeg_encode::planar2rgb(&raw, &rgb);
	jpeg_encode::rgb2jpeg(&rgb, &jpeg, 90);
	printf("width:%d height:%d stride:%d size:%ld\n",
	       jpeg.width, jpeg.height, jpeg.stride, jpeg.size);
	
	int fd;
	fd = open("test.jpeg", O_WRONLY | O_CREAT | O_TRUNC, 0640);
	write(fd, jpeg.data, jpeg.size);
	close(fd);

	return 0;
}
#endif
