#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

from sys import argv
from os import path
import re

if len(argv) != 3:
    print("ERROR:\n  Usage: python3 makecoe.py <hex-file> <imem size in bytes>")
    exit(1)

hexfile = argv[1]
if not path.isfile(hexfile):
    print("ERROR:\n    hex-file not found")
    print("Usage:\n  python3 makecoe.py <hex-file> <imem size in bytes>")
    exit(1)

with open(hexfile, "r") as f:
    bindata = f.read()  

bindata = re.sub('[\n]', '', bindata)

if len(bindata) % 4:
    print("WARNING:\n    bin-file is not 4-byte aligned")
    print("    padding (" + str(len(bindata)) + " bytes -> ", end="")
    while(len(bindata) % 4):
        bindata = bindata + b'\x00'
    print(str(len(bindata)) + " bytes)")


nwords = int(int(argv[2])/4)

if len(bindata) > 4*nwords:
    print("ERROR:\n    memory size is insufficient")
    print (len(bindata))
    print (4*nwords)
    exit(1)

print("Preparing %d 32-bit words" % nwords)

ofname_imem = hexfile[0:-4]+".coe"
ofh_imem = open(ofname_imem, "w")

ofh_imem.write("memory_initialization_radix = 16;\nmemory_initialization_vector = \n")

for i in range(nwords):
    if i < len(bindata) // 4:
        line = bindata[8*i : 8*i+8]
        # print(w)
        # # print("%02x%02x%02x%02x" % (w[3], w[2], w[1], w[0]), end="")
        # line = "%02x%02x%02x%02x" % (w[3], w[2], w[1], w[0])
    else:
        # print("00000000", end="")
        line = "00000000"
    ofh_imem.write(line);
    if i == nwords-1:
        ofh_imem.write(";\n")
    else:
        ofh_imem.write(",\n")

print("  ... done writing")