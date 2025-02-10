#!/usr/bin/python3

import sys
# import os

if len(sys.argv) != 2:
    print("USAGE: python3 raw2dat.py <ifname.raw>")
    sys.exit(1)


ifname = sys.argv[1]
ofname = ifname.replace(".raw", ".dat")

ifh = open(ifname, "rb")
ofh = open(ofname, "w")


# # determine ratio
# file_stats = os.stat(ifname)
# number_of_bytes = file_stats.st_size

# if (number_of_bytes % 3 != 0):
#     print("ERROR: %s's size is not a multiple of 3\n" % ifname)
#     sys.exit(1)

# number_of_pixels = number_of_bytes / 3

# height = sqrt(4*number_of_pixels/3)
# width = sqrt(3*number_of_pixels/4)

width = 640
height = 480

ofh.write("%08X\n" % width)
ofh.write("%08X\n" % height)

for i in range(width*height):
    line = "%sFF" % (bytes.hex(ifh.read(3)))
    # print(line)
    ofh.write(line+"\n")

ifh.close()
ofh.close()


