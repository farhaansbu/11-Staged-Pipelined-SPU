
# XM-Sim Command File
# TOOL:	xmsim(64)	24.09-s001
#
#
# You can restore this configuration with:
#
#      xrun -f files.f -top tbench -access +rwc -input restore.tcl
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
probe -create -database waves tbench.clk tbench.even_immediate tbench.even_instruction_type tbench.even_opcode tbench.even_ra_addr tbench.even_rb_addr tbench.even_rc_addr tbench.even_rt_addr tbench.even_unit_id tbench.dut.dec_rf_reg.even_immediate_q tbench.dut.dec_rf_reg.even_instruction_type_q tbench.dut.dec_rf_reg.even_opcode_q tbench.dut.dec_rf_reg.even_ra_addr_q tbench.dut.dec_rf_reg.even_rb_addr_q tbench.dut.dec_rf_reg.even_rc_addr_q tbench.dut.dec_rf_reg.even_rt_addr_q tbench.dut.dec_rf_reg.even_unit_id_q
probe -create -database waves tbench.dut.rf_exec_reg.even_opcode_q tbench.dut.rf_exec_reg.even_source_a_q tbench.dut.rf_exec_reg.even_source_b_q tbench.dut.rf_exec_reg.even_source_c_q tbench.dut.rf_exec_reg.even_unit_id_q tbench.dut.rf_exec_reg.even_write_addr_q
probe -create -database waves tbench.dut.rf.reg_file
probe -create -database waves tbench.dut.source_op_unit.even_forwarded_data_a tbench.dut.source_op_unit.even_forwarded_data_b tbench.dut.source_op_unit.even_forwarding_signal_a tbench.dut.source_op_unit.even_forwarding_signal_b
probe -create -database waves tbench.dut.fw_unit.even_forwarding_signal_a tbench.dut.fw_unit.even_forwarding_signal_b
probe -create -database waves tbench.dut.fw_unit.even_pipe_forwarded_results tbench.dut.fw_unit.even_read_addr_a tbench.dut.fw_unit.even_read_addr_b

simvision -input restore.tcl.svcf
