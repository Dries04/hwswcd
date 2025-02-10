#!/usr/bin/env python3

from sys import argv

fname = argv[1]

content = ""

with open(fname, "r") as fh:

    for line in fh:
        line = line.rstrip()
        line_int = int(line,2)
        content = content + chr(line_int)

print(content)

fname = "qoi_simulation.qoi"

with open(fname, "wb") as fh:
    # fh.write(content.encode('utf-8'))

    for i in range(0,len(content),2):
        x = int(content[i], 16)*16 + int(content[i+1], 16)
        fh.write(x.to_bytes())