

# ---------------------------------------------------------------
# --------------- Setting some variables ------------------------
# ---------------------------------------------------------------


set DESIGN multiplier_wrapper
set ROOT_DIR $env(ROOT)
set freq_mhz $env(FREQ_MHZ)
set CORNER $env(OP_CORNER)
set MULTIPLIER $env(MULT)
set LVT 1
set DATA_WIDTH $env(WIDTH)

# ---------------------------------------------------------------
# ------------ Setting paths from archivers ---------------------
# ---------------------------------------------------------------

set_db auto_super_thread true
set_db super_thread_rsh_command ssh 
set_db max_cpus_per_server 24
set_multi_cpu_usage -local_cpu 24




# Set the paths to search the libs and LEF files
  set_db init_lib_search_path { \
    /home/tools/design_kits/cadence/GPDK045/gsclib045_svt_v4.4/gsclib045/timing \
    /home/tools/design_kits/cadence/GPDK045/gsclib045_all_v4.4/gsclib045_lvt/timing \
    /home/tools/design_kits/cadence/GPDK045/giolib045_v3.3/timing \
    /home/tools/design_kits/cadence/GPDK045/gsclib045_all_v4.4/gsclib045_lvt/lef \
    /home/tools/design_kits/cadence/GPDK045/gsclib045_svt_v4.4/gsclib045/lef \
    /home/tools/design_kits/cadence/GPDK045/giolib045_v3.3/lef \
  }



# Set the path to search SDC files
set SDC_SEARCH_PATH        ${ROOT_DIR}/synthesis/inputs/

# Set the path to search HDL filelist
set FILELIST_SEARCH_PATH   ${ROOT_DIR}/codes/filelists/

# Set the path to save the reports and deliverables
set REPORTS_PATH           ${ROOT_DIR}/synthesis/outputs/reports/
set DELIVERABLES_PATH      ${ROOT_DIR}/synthesis/outputs/deliverables/

# Set the path to seatch CapTable file
set QRC_PATH          /home/tools/design_kits/cadence/GPDK045/gpdk045_v_6_0/qrc/


# ---------------------------------------------------------------
# ------------ Setting and load the archivers -------------------
# ---------------------------------------------------------------

# Load the TLEF and LEF files


# Load the standard cells libraries : STD, MB, IO
switch -- $CORNER {

    "slow" {
      if {$LVT} {
        read_libs slow_vdd1v0_basicCells_lvt.lib
      } else {
        read_libs slow_vdd1v0_basicCells.lib
      }  
    }

    "fast" {
        if {$LVT} {
        read_libs fast_vdd1v0_basicCells_lvt.lib
      } else {
        read_libs fast_vdd1v0_basicCells.lib
      }
    }

    "typical" {
        puts "\n\n ERROR: Do not have typical corner libraries defined."
        exit
    }

    default {
        puts "\n\n ERROR: The specified corner '$CORNER' is not valid.\n"
        exit
    }
}

if {$LVT} {
  read_physical -lefs {                             \
    gsclib045_tech.lef                              \
    gsclib045_lvt_macro.lef                             \
  }
} else {
  read_physical -lefs {                             \
  gsclib045_tech.lef                              \
  gsclib045_macro.lef                             \
}
}


set_db qrc_tech_file  ${QRC_PATH}rcworst/qrcTechFile


# Load the HDL filelist
if {$MULTIPLIER == "karatsuba"} {
  read_hdl -language vhdl ${ROOT_DIR}/codes/karatsuba_multiplier/CLA_xBits.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/karatsuba_multiplier/Karatsuba2b_CLA.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/karatsuba_multiplier/karatsuba3b_aux.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/karatsuba_multiplier/karatsuba3b.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/karatsuba_multiplier/karatsuba4b.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/karatsuba_multiplier/karatsuba6b.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/karatsuba_multiplier/karatsuba9b.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/karatsuba_multiplier/karatsuba16b.vhd
} elseif {$MULTIPLIER == "standard"} {
  read_hdl -v2001 ${ROOT_DIR}/codes/multiplier.v
} else {
  read_hdl -language vhdl ${ROOT_DIR}/codes/Array_multiplier/bloco_basico_mult_array.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/Array_multiplier/mult_array_16x16.vhd
}

read_hdl -v2001 ${ROOT_DIR}/synthesis/inputs/multiplier_wrapper.v


# ---------------------------------------------------------------
# ------ Elabore the design and defines constraints -------------
# ---------------------------------------------------------------

# Elaborate the design
elaborate $DESIGN -parameters ${DATA_WIDTH}
check_design > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_check_design.rpt"


# Read constraints SDC files
read_sdc "${SDC_SEARCH_PATH}constraints.sdc"
report_timing -lint > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_constraints_summary.rpt"
#check_timing_intent


# Allow and dimiss the use of some cells
set_db [get_db lib_cells *CKLNQ*] .avoid false
set_db [get_db lib_cells *CKLHQ*] .avoid false



# Set the effort in the synthesis stages
# set_db syn_generic_effort    high
# set_db syn_map_effort        high
# set_db syn_opt_effort        high
# set_db design_power_effort    high
# set_db optimize_constant_0_flops true
# set_db optimize_constant_1_flops true


# ---------------------------------------------------------------
# ----------------------- Synthesizes ---------------------------
# ---------------------------------------------------------------

syn_gen
syn_map 
# syn_opt

# ---------------------------------------------------------------
# ------------------- Save the archivers ------------------------
# ---------------------------------------------------------------
set_db lp_power_unit uW 

write_hdl > "${DELIVERABLES_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}.v"
write_sdf > "${DELIVERABLES_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}.sdf"
write_hdl > "${DELIVERABLES_PATH}last/${DESIGN}.v"
write_sdf > "${DELIVERABLES_PATH}last/${DESIGN}.sdf"
report_timing > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_timing.rpt"
report_area -hinst multiplier_inst > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_area.rpt"
report_area -hinst multiplier_inst -detail > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_area_detail.rpt"
report_area -hinst multiplier_inst -normalize_with_gate NAND2X1 > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_KGE.rpt"
report_power -unit uW -inst multiplier_inst > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_power.rpt"
report_gates -hinst multiplier_inst > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_gates.rpt"
report_hierarchy > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_hierarchy.rpt"
report_design_rules > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_design_rules.rpt"
report_qor > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_qor.rpt"

report_timing

proc report_power_with_vcd {} {
    global REPORTS_PATH MULTIPLIER DATA_WIDTH freq_mhz CORNER DESIGN
    report_power -unit uW -inst multiplier_inst > "${REPORTS_PATH}${MULTIPLIER}/N${DATA_WIDTH}/${freq_mhz}MHz/${CORNER}/${DESIGN}_power_with_vcd.rpt"
}