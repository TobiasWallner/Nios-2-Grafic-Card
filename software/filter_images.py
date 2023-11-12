#!/bin/env python3
import sys
import re
from base64 import b64decode 
from datetime import datetime

try:
	import png
except:
	print("module 'png' not found!")
	print("run the following command to install it (as user, not as root!)")
	print(" pip3 install --user pypng")
	exit(1)

def main():

	use_idx_as_filename = False
	if len(sys.argv) > 1 and sys.argv[1] == "-n":
		use_idx_as_filename = True

	print("==============================")
	print("== IMAGE DUMP FILTER ACTIVE ==")
	print("==============================")

	image_buffer_base64 = ""
	image_width = 0
	image_height = 0
	dump_in_progress = False
	images_dumped = 0

	re_begin = re.compile("^<<<<\s*BEGIN\s+IMAGE\s+(\d+)\s+(\d+)\s*>>>>$")
	re_end = re.compile("^<<<<\s*END\s+IMAGE\s*>>>>$")
	
	try:
		for line in sys.stdin:
			if (dump_in_progress):
				match = re.match(re_end, line.strip())
				if (match):
					dump_in_progress = False
					if use_idx_as_filename:
						filename = f"{images_dumped}.png"
					else:
						filename = datetime.now().strftime("%d.%m.%Y-%H%M%S") + ".png"
					print(f"Dumping image ({image_width}x{image_height}) to {filename}\r")
					SaveImage(image_buffer_base64, image_width, image_height, filename)
					images_dumped += 1
				else:
					image_buffer_base64 += line.strip()
			else:
				match = re.match(re_begin, line.strip())
				if (match):
					dump_in_progress = True
					image_buffer_base64 = ""
					image_width = int(match.groups()[0])
					image_height = int(match.groups()[1])
					print("Image start marker found\r")
				else:
					print(line, end="", flush=True)
	except KeyboardInterrupt:
		pass

def SaveImage(base64_data, width, height, filename):
	byte_data = b64decode(base64_data)
	p = []

	for i in range(0,height):
		line = [0]*width*3
		for j in range(0,width):
			line[3*j+0] = byte_data[i*width*4+j*4+0]
			line[3*j+1] = byte_data[i*width*4+j*4+1]
			line[3*j+2] = byte_data[i*width*4+j*4+2] 
		p.append(line)

	with open(filename, "wb") as outfile:
		w = png.Writer(width, height, greyscale=False)
		w.write(outfile, p)


if __name__ == "__main__":
	main()
