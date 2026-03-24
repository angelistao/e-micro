

# ---------------------------------------------------------------
# --------------- Setting some variables ------------------------
# ---------------------------------------------------------------


set DESIGN multiplier_wrapper
set ROOT_DIR $env(ROOT)
set freq_mhz $env(FREQ_MHZ)
set CORNER $env(OP_CORNER)
set MULTIPLIER $env(MULT)
set DATA_WIDTH $env(WIDTH)

# ---------------------------------------------------------------
# ------------ Setting paths from archivers ---------------------
# ---------------------------------------------------------------


# Set the paths to search the libs and LEF files
set_db init_lib_search_path { \
  /home/tools/design_kits/cadence/GPDK045/gsclib045_svt_v4.4/gsclib045/timing \
  /home/tools/design_kits/cadence/GPDK045/giolib045_v3.3/timing \
  /home/tools/design_kits/cadence/GPDK045/gsclib045_svt_v4.4/gsclib045/lef/ \
  /home/tools/design_kits/cadence/GPDK045/giolib045_v3.3/lef/ \
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
        read_libs {
            slow_vdd1v0_basicCells.lib
        }
    }

    "fast" {
        read_libs {
            fast_vdd1v2_basicCells.lib
        }

        set_db qrc_tech_file ${QRC_PATH}rcworst/qrcTechFile
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


read_physical -lefs {                             \
  gsclib045_tech.lef                              \
  gsclib045_macro.lef                             \
}

set_db qrc_tech_file  ${QRC_PATH}rcworst/qrcTechFile


# Load the HDL filelist
puts  "INFO: Iniciando Leitura do HDL"
puts ""
puts ""

if {$MULTIPLIER == "karatsuba"} {
 puts "ainda não tem"
} elseif {$MULTIPLIER == "standard"} {
 read_hdl -v2001 ${ROOT_DIR}/codes/multiplier.v
} else {
  read_hdl -language vhdl ${ROOT_DIR}/codes/Array_multiplier/bloco_basico_mult_array.vhd
  read_hdl -language vhdl ${ROOT_DIR}/codes/Array_multiplier/mult_array_16x16.vhd
}

read_hdl -v2001 ${ROOT_DIR}/synthesis/inputs/multiplier_wrapper.v

puts ""
puts ""
puts  "INFO: Encerrando Leitura do HDL"
for {set i 0} {$i < 10} {set i [expr $i + 1]} {puts ""}
grep "INFO: Iniciando Leitura do HDL" genus.log -A 40 > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/log_filter.log"




# ---------------------------------------------------------------
# ------ Elabore the design and defines constraints -------------
# ---------------------------------------------------------------

# Elaborate the design
puts  "INFO: Iniciando Elaboração"
puts ""
puts ""

elaborate $DESIGN -parameters ${DATA_WIDTH}
check_design

puts ""
puts ""
puts  "INFO: Encerrando Elaboração"
for {set i 0} {$i < 10} {set i [expr $i + 1]} {puts ""}
grep "INFO: Iniciando Elaboração" genus.log -A 100 >> "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/log_filter.log"
check_design > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_check_design.rpt"



# Read constraints SDC files
puts  "INFO: Iniciando Leitura das Constraints"
puts ""
puts ""

read_sdc "${SDC_SEARCH_PATH}constraints.sdc"
report_timing -lint

puts ""
puts ""
puts  "INFO: Encerrando Leitura das Constraints"
for {set i 0} {$i < 10} {set i [expr $i + 1]} {puts ""}
grep "INFO: Iniciando Elaboração" genus.log -A 90 >> "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/log_filter.log"


report_timing -lint > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_constraints_summary.rpt"


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

write_hdl > "${DELIVERABLES_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}.v"
write_sdf > "${DELIVERABLES_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}.sdf"
report_timing > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_timing.rpt"
report_area -hinst multiplier_inst > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_area.rpt"
report_area -hinst multiplier_inst -detail > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_area_detail.rpt"
report_power -unit uW -inst multiplier_inst > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_power.rpt"
report_gates -hinst multiplier_inst > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_gates.rpt"
report_hierarchy > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_hierarchy.rpt"


exec grep {Slack:=  } "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_timing.rpt" > "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_PPA.rpt"
exec grep {multiplier_inst} "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_area.rpt" >> "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_PPA.rpt"
exec grep {  Subtotal} "${REPORTS_PATH}${MULTIPLIER}/${freq_mhz}/${CORNER}/${DESIGN}_power.rpt" >> "${REPORTS_PATH}${MULTIPLIER}/
${freq_mhz}/${CORNER}/${DESIGN}_PPA.rpt"

report_timing