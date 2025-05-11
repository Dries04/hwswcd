#!/usr/bin/python3

ifname = "C:\\Users\\Dries\\Documents\\Uhasselt\\ma_EA-ICT\HW_SW\\gitrepo\\working_project\\firmware\\simulation_output.dat"
ofname = "C:\\Users\\Dries\\Documents\\Uhasselt\\ma_EA-ICT\\HW_SW\\gitrepo\\working_project\\firmware\\simulation_output.qoi"

ifh = open(ifname, "r")
ofh = open (ofname, "wb")


for line in ifh:
    line = line.rstrip()
    line_int = int(line, 2)
    
    ofh.write(line_int.to_bytes(1,byteorder='big'))

ifh.close()
ofh.close()