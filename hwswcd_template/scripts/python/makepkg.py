#!/usr/bin/env python3
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

from sys import argv, exit

if len(argv) != 3:
    print("ERROR:\n  Usage: python3 makepkg.py <hex-file> <imem size in bytes>")
    exit(1)

hexfile = argv[1]
pkgfile = hexfile[0:-4]+"_package.vhd"
nwords = int(int(argv[2])/4)

ofh = open(pkgfile, "w")

ofh.write("")

ofh.write("--------------------------------------------------------------------------------\n")
ofh.write("-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security\n")
ofh.write("--------------------------------------------------------------------------------\n")
ofh.write("-- Package Name:    PKG_sim\n")
ofh.write("-- Project Name:    HWSWCD\n")
ofh.write("-- Description:     Package that contains the init of the IMEM     \n")
ofh.write("--\n")
ofh.write("-- Revision     Date       Author     Comments\n")
ofh.write("-- v0.1         20241128   VlJo       Initial version\n")
ofh.write("--\n")
ofh.write("--------------------------------------------------------------------------------\n")
ofh.write("library IEEE;\n")
ofh.write("use IEEE.STD_LOGIC_1164.ALL;\n\n")
ofh.write("library work;\n")
ofh.write("use work.PKG_hwswcd.ALL;\n\n")
ofh.write("package firmware_package is\n")
# ofh.write("    type T_imem is array(0 to 255) of STD_LOGIC_VECTOR(31 downto 0); \n")
ofh.write("    constant C_imem_init : T_imem := (\n")

nolines = 0

buffer = ""
ifh = open(hexfile, "r")
for line in ifh:
    ofh.write("        x\"" +  line.rstrip() + "\",\n")
    nolines = nolines + 1

nopaddinglines = nwords - nolines



while nopaddinglines > 1:
    ofh.write("        x\"00000013\",\n")
    nopaddinglines = nopaddinglines - 1
ofh.write("        x\"00000013\");\n")

ofh.write("end package;\n")
ofh.close()

# print("Number of instructions written: %d" % nolines)
# print("Number of nop-instructions added: %d" % int(nwords - nolines))
print("Total number of instructions written: %d (inst/nop: %d/%d (%.2f%%))" % (nwords, nolines, int(nwords - nolines), nolines/nwords*100))
print("Total number of bytes written: %d" % int(nwords*4))