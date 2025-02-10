################################################################################
# Emerging technologies, Systems & Security
#
#   date: Nov 26 2025
#   author: VlJo
################################################################################
# Project to test
#
# launch with: source /home/jvliegen/vc/github/KULeuven-Diepenbeek/course_hwswcodesign_internal/main/scripts/tcl/proj_synth.tcl
################################################################################

set pname "riscv_main_synth"
set path "/home/jvliegen/Documents/courses/KULeuven/sem8_HWSWCD/vivado/"
set srcpath "/home/jvliegen/vc/github/KULeuven-Diepenbeek/course_hwswcodesign_internal/main"

set part "xc7z020clg400-1"
set board "tul.com.tw:pynq-z2:part0:1.0"


# delete older versions
cd $path
exec rm -Rf $pname

# create project
create_project $pname $path/$pname -part $part
set_property board_part $board [current_project]
set_property target_language VHDL [current_project]
#set_property ip_repo_paths $ippath [current_project]
#update_ip_catalog

# suppress messages that say "don't do inidividual add_files/import_files
set_msg_config -suppress -id {Vivado 12-3645} 

# suppress messages like: WARNING: [Vivado 12-3523] Attempt to change 'Component_Name' from 'icap_buffer' to 'icap_buffer' is not allowed and is ignored.
set_msg_config -suppress -id {Vivado 12-3523} 


# IP cores
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name imem
set_property -dict [list CONFIG.Component_Name {imem} CONFIG.Memory_Type {Single_Port_ROM} CONFIG.Write_Width_A {32} CONFIG.Write_Depth_A {2048} CONFIG.Read_Width_A {32} CONFIG.Enable_A {Always_Enabled} CONFIG.Write_Width_B {32} CONFIG.Read_Width_B {32} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Load_Init_File {true} CONFIG.Coe_File {/home/jvliegen/vc/github/KULeuven-Diepenbeek/course_hwswcodesign_internal/main/firmware/synth_test/firmware_imem.coe} CONFIG.Port_A_Write_Rate {0}] [get_ips imem]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name dmem
set_property -dict [list CONFIG.Component_Name {dmem} CONFIG.Write_Width_A {32} CONFIG.Write_Depth_A {2048} CONFIG.Read_Width_A {32} CONFIG.Enable_A {Always_Enabled} CONFIG.Write_Width_B {32} CONFIG.Read_Width_B {32} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Load_Init_File {true} CONFIG.Coe_File {/home/jvliegen/vc/github/KULeuven-Diepenbeek/course_hwswcodesign_internal/main/firmware/synth_test/firmware_dmem.coe}] [get_ips dmem]

# TOP LEVEL COMPONENTS
################################################################################
add_files -norecurse $srcpath/hdl/PKG_hwswcd.vhd
add_files -norecurse $srcpath/hdl/reg_file.vhd
add_files -norecurse $srcpath/hdl/alu.vhd
add_files -norecurse $srcpath/hdl/control.vhd
add_files -norecurse $srcpath/hdl/immediate_gen.vhd
add_files -norecurse $srcpath/hdl/riscv_csr.vhd

add_files -norecurse $srcpath/hdl/riscv.vhd
add_files -norecurse $srcpath/hdl/riscv_apb_wrapper.vhd

# add_files -norecurse $srcpath/hdl/two_k_BRAM.vhd
add_files -norecurse $srcpath/hdl/APB_two_k_BRAM_synth.vhd

add_files -norecurse $srcpath/hdl/APB_gpio.vhd

add_files -norecurse $srcpath/hdl/riscv_microcontroller_synth.vhd




# # TESTBENCHES
# ################################################################################
# add_files -fileset sim_1 -norecurse $srcpath/hdl/tb/dmem_model.vhd
# add_files -fileset sim_1 -norecurse $srcpath/hdl/tb/imem_model.vhd
# add_files -fileset sim_1 -norecurse $srcpath/hdl/tb/basicIO_model.vhd
# add_files -fileset sim_1 -norecurse $srcpath/hdl/tb/riscv_microcontroller_tb.vhd


# CONSTRAINTS
################################################################################
add_files -fileset constrs_1 -norecurse $srcpath/xdc/riscv_microconrtoller_synth.xdc

