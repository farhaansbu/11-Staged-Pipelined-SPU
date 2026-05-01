
# XM-Sim Command File
# TOOL:	xmsim(64)	24.09-s001
#

set tcl_prompt1 {puts -nonewline "xcelium> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 1
set assert_reporting_mode 0
set vcd_compact_mode 0
set vhdl_forgen_loopindex_enum_pos 0
set xmreplay_dc_debug 0
set tcl_runcmd_interrupt next_command
set tcl_sigval_prefix {#}
alias . run
alias indago verisium
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves tbench.dut.ibuffer.imem
probe -create -database waves tbench.dut.ibuffer.instruction_1
probe -create -database waves tbench.dut.ibuffer.program_counter
probe -create -database waves tbench.dut.if_dec_reg.instruction_1_q
probe -create -database waves tbench.dut.dec.even_immediate tbench.dut.dec.even_instruction_type tbench.dut.dec.even_nop tbench.dut.dec.even_opcode tbench.dut.dec.even_program_counter tbench.dut.dec.even_ra_addr tbench.dut.dec.even_rb_addr tbench.dut.dec.even_rc_addr tbench.dut.dec.even_reg_write tbench.dut.dec.even_rt_addr tbench.dut.dec.even_unit_id
probe -create -database waves tbench.dut.rf.reg_file
probe -create -database waves tbench.dut.dec_rf_reg.even_instruction_type_q tbench.dut.dec_rf_reg.even_opcode_q tbench.dut.dec_rf_reg.even_immediate_q tbench.dut.dec_rf_reg.even_rt_addr_q
probe -create -database waves tbench.dut.rf_exec_reg.even_opcode_q tbench.dut.rf_exec_reg.even_source_a_q tbench.dut.rf_exec_reg.even_source_b_q tbench.dut.rf_exec_reg.even_write_addr_q tbench.dut.rf_exec_reg.even_unit_id_q tbench.dut.rf_exec_reg.even_reg_write_q
probe -create -database waves tbench.dut.ibuffer.instruction_2 tbench.dut.if_dec_reg.instruction_2_q tbench.dut.dec.odd_instruction_type tbench.dut.dec.odd_opcode tbench.dut.dec.odd_program_counter tbench.dut.dec.odd_ra_addr tbench.dut.dec.odd_rb_addr tbench.dut.dec.odd_reg_write tbench.dut.dec.odd_unit_id
probe -create -database waves tbench.dut.dec.odd_immediate

simvision -input /home/home5/fkhan/ese545project/.simvision/1437221_fkhan_lab01.ece.stonybrook.edu_autosave.tcl.svcf
