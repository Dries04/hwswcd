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

if len(argv) != 3:
    print("ERROR:\n  Usage: python3 makehex.py <bin-file> <imem size in bytes>")
    exit(1)

binfile = argv[1]
if not path.isfile(binfile):
    print("ERROR:\n    bin-file not found")
    print("Usage:\n  python3 makehex.py <bin-file> <imem size in bytes>")
    exit(1)

with open(binfile, "rb") as f:
    bindata = f.read()    

if len(bindata) % 4:
    # print("WARNING:\n    bin-file is not 4-byte aligned")
    # print("    padding (" + str(len(bindata)) + " bytes -> ", end="")
    while(len(bindata) % 4):
        bindata = bindata + b'\x00'
    # print(str(len(bindata)) + " bytes)")
    # exit(1)


nwords = int(int(argv[2])/4)

if len(bindata) >= 4*nwords:
    print("ERROR:\n    memory size is insufficient")
    exit(1)

print("Preparing %d 32-bit words" % nwords)


ofname_imem = binfile[0:-4]+"_imem.hex"
ofh_imem = open(ofname_imem, "w")

ofname_dmem = binfile[0:-4]+"_dmem.hex"
ofh_dmem = open(ofname_dmem, "w")

for i in range(nwords):
    if i < len(bindata) // 4:
        w = bindata[4*i : 4*i+4]
        if i >= int(nwords/2):
            ofh_dmem.write("%02x%02x%02x%02x\n" % (w[3], w[2], w[1], w[0]))
        else:
            ofh_imem.write("%02x%02x%02x%02x\n" % (w[3], w[2], w[1], w[0]))
    else:
        if i >= int(nwords/2):
            ofh_dmem.write("00000000\n")
        else:
            ofh_imem.write("00000000\n")

ofh_imem.close()
ofh_dmem.close()

