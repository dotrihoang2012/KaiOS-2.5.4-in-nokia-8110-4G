#!/system/bin/sh
# Copyright (c) 2012-2015, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of The Linux Foundation nor
#       the names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior written
#       permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NON-INFRINGEMENT ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
# OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

target=`getprop ro.board.platform`
case "$target" in
    "msm7201a_ffa" | "msm7201a_surf" | "msm7627_ffa" | "msm7627_6x" | "msm7627a"  | "msm7627_surf" | \
    "qsd8250_surf" | "qsd8250_ffa" | "msm7630_surf" | "msm7630_1x" | "msm7630_fusion" | "qsd8650a_st1x")
        echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
        echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
        ;;
esac

case "$target" in
    "msm7201a_ffa" | "msm7201a_surf")
        echo 500000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
        ;;
esac

case "$target" in
    "msm7630_surf" | "msm7630_1x" | "msm7630_fusion")
        echo 75000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
        echo 1 > /sys/module/pm2/parameters/idle_sleep_mode
        ;;
esac

case "$target" in
     "msm7201a_ffa" | "msm7201a_surf" | "msm7627_ffa" | "msm7627_6x" | "msm7627_surf" | "msm7630_surf" | "msm7630_1x" | "msm7630_fusion" | "msm7627a" )
        echo 245760 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
        ;;
esac

case "$target" in
    "msm8660")
     echo 1 > /sys/module/rpm_resources/enable_low_power/L2_cache
     echo 1 > /sys/module/rpm_resources/enable_low_power/pxo
     echo 2 > /sys/module/rpm_resources/enable_low_power/vdd_dig
     echo 2 > /sys/module/rpm_resources/enable_low_power/vdd_mem
     echo 1 > /sys/module/rpm_resources/enable_low_power/rpm_cpu
     echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
     echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
     echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
     echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
     echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
     echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/idle_enabled
     echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
     echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
     echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
     echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
     echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
     echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
     echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
     echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
     echo 384000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
     echo 384000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
     chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
     chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
     chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
     chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
     chown -h root.system /sys/devices/system/cpu/mfreq
     chmod -h 220 /sys/devices/system/cpu/mfreq
     chown -h root.system /sys/devices/system/cpu/cpu1/online
     chmod -h 664 /sys/devices/system/cpu/cpu1/online
        ;;
esac

case "$target" in
    "msm8960")
         echo 1 > /sys/module/rpm_resources/enable_low_power/L2_cache
         echo 1 > /sys/module/rpm_resources/enable_low_power/pxo
         echo 1 > /sys/module/rpm_resources/enable_low_power/vdd_dig
         echo 1 > /sys/module/rpm_resources/enable_low_power/vdd_mem
         echo 1 > /sys/module/msm_pm/modes/cpu0/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
         echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
         echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
         echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
         echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
         echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
         echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
         echo 918000 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
         echo 1026000 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
         echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
         chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
         chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
         chown -h system /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
         echo 384000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 384000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 384000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 384000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
         # set DCVS parameters for CPU
         echo 40000 > /sys/module/msm_dcvs/cores/cpu0/slack_time_max_us
         echo 40000 > /sys/module/msm_dcvs/cores/cpu0/slack_time_min_us
         echo 100000 > /sys/module/msm_dcvs/cores/cpu0/em_win_size_min_us
         echo 500000 > /sys/module/msm_dcvs/cores/cpu0/em_win_size_max_us
         echo 0 > /sys/module/msm_dcvs/cores/cpu0/slack_mode_dynamic
         echo 1000000 > /sys/module/msm_dcvs/cores/cpu0/disable_pc_threshold
         echo 25000 > /sys/module/msm_dcvs/cores/cpu1/slack_time_max_us
         echo 25000 > /sys/module/msm_dcvs/cores/cpu1/slack_time_min_us
         echo 100000 > /sys/module/msm_dcvs/cores/cpu1/em_win_size_min_us
         echo 500000 > /sys/module/msm_dcvs/cores/cpu1/em_win_size_max_us
         echo 0 > /sys/module/msm_dcvs/cores/cpu1/slack_mode_dynamic
         echo 1000000 > /sys/module/msm_dcvs/cores/cpu1/disable_pc_threshold
         echo 25000 > /sys/module/msm_dcvs/cores/cpu2/slack_time_max_us
         echo 25000 > /sys/module/msm_dcvs/cores/cpu2/slack_time_min_us
         echo 100000 > /sys/module/msm_dcvs/cores/cpu2/em_win_size_min_us
         echo 500000 > /sys/module/msm_dcvs/cores/cpu2/em_win_size_max_us
         echo 0 > /sys/module/msm_dcvs/cores/cpu2/slack_mode_dynamic
         echo 1000000 > /sys/module/msm_dcvs/cores/cpu2/disable_pc_threshold
         echo 25000 > /sys/module/msm_dcvs/cores/cpu3/slack_time_max_us
         echo 25000 > /sys/module/msm_dcvs/cores/cpu3/slack_time_min_us
         echo 100000 > /sys/module/msm_dcvs/cores/cpu3/em_win_size_min_us
         echo 500000 > /sys/module/msm_dcvs/cores/cpu3/em_win_size_max_us
         echo 0 > /sys/module/msm_dcvs/cores/cpu3/slack_mode_dynamic
         echo 1000000 > /sys/module/msm_dcvs/cores/cpu3/disable_pc_threshold
         # set DCVS parameters for GPU
         echo 20000 > /sys/module/msm_dcvs/cores/gpu0/slack_time_max_us
         echo 20000 > /sys/module/msm_dcvs/cores/gpu0/slack_time_min_us
         echo 100000 > /sys/module/msm_dcvs/cores/gpu0/em_win_size_min_us
         echo 500000 > /sys/module/msm_dcvs/cores/gpu0/em_win_size_max_us
         echo 0 > /sys/module/msm_dcvs/cores/gpu0/slack_mode_dynamic
         echo 500000 > /sys/module/msm_dcvs/cores/gpu0/disable_pc_threshold
        ;;
esac

case "$target" in
    "msm8226")
         echo 1 > /sys/module/lpm_resources/enable_low_power/l2
         echo 1 > /sys/module/lpm_resources/enable_low_power/pxo
         echo 1 > /sys/module/lpm_resources/enable_low_power/vdd_dig
         echo 1 > /sys/module/lpm_resources/enable_low_power/vdd_mem
         echo 1 > /sys/module/msm_pm/modes/cpu0/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
         echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
         echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
         echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
         echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
         echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
         echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
         echo 787200 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
         echo 998400 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
         echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
         echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
        ;;
esac

case "$target" in
    "msm8610")
         echo 1 > /sys/module/lpm_resources/enable_low_power/l2
         echo 1 > /sys/module/lpm_resources/enable_low_power/pxo
         echo 1 > /sys/module/lpm_resources/enable_low_power/vdd_dig
         echo 1 > /sys/module/lpm_resources/enable_low_power/vdd_mem
         echo 1 > /sys/module/msm_pm/modes/cpu0/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
         echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
         echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
         echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
         echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
         echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
         echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
         echo 787200 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
         echo 998400 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
         echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
         echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
        ;;
esac

case "$target" in
    "msm8974")
         echo 1 > /sys/module/lpm_resources/enable_low_power/l2
         echo 1 > /sys/module/lpm_resources/enable_low_power/pxo
         echo 1 > /sys/module/lpm_resources/enable_low_power/vdd_dig
         echo 1 > /sys/module/lpm_resources/enable_low_power/vdd_mem
         echo 1 > /sys/module/msm_pm/modes/cpu0/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
         echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
         echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
         echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
         echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
         echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
         echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
         echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
         echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
         echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
         echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
        ;;
esac

case "$target" in
    "msm8916")
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo "19000 1113600:39000" > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
         echo 85 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
         echo 20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
         echo 1113600 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
         echo 0 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy
         echo "1 800000:85 998400:90 1094400:80" > /sys/devices/system/cpu/cpufreq/interactive/target_loads
         echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
         echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor
         echo 800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 800000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 800000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 800000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
        ;;
esac

case "$target" in
    "msm8909")
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo "19000 998400:39000" > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
         echo 85 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
         echo 20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
         echo 998400 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
         echo 0 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy
         echo "1 800000:85 998400:90" > /sys/devices/system/cpu/cpufreq/interactive/target_loads
         echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
         echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor
         echo 800000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 800000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 800000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 800000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
        ;;
esac

case "$target" in
    "msm8994")
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "interactive" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo "19000 1440000:39000 1728000:19000" > /sys/devices/system/cpu/cpufreq/interactive/above_hispeed_delay
         echo 90 > /sys/devices/system/cpu/cpufreq/interactive/go_hispeed_load
         echo 20000 > /sys/devices/system/cpu/cpufreq/interactive/timer_rate
         echo 1440000 > /sys/devices/system/cpu/cpufreq/interactive/hispeed_freq
         echo 1 > /sys/devices/system/cpu/cpufreq/interactive/io_is_busy
         echo "85 1500000:90 1800000:70" > /sys/devices/system/cpu/cpufreq/interactive/target_loads
         echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/min_sample_time
         echo 40000 > /sys/devices/system/cpu/cpufreq/interactive/sampling_down_factor
         echo 384000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 384000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 384000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 384000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
        ;;
esac

case "$target" in
    "apq8084")
         echo 1 > /sys/module/lpm_resources/enable_low_power/l2
         echo 1 > /sys/module/lpm_resources/enable_low_power/pxo
         echo 1 > /sys/module/lpm_resources/enable_low_power/vdd_dig
         echo 1 > /sys/module/lpm_resources/enable_low_power/vdd_mem
         echo 1 > /sys/module/msm_pm/modes/cpu0/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/retention/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
         echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
         echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
         echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
         echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
         echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
         echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
         echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
         echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
         echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
         echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
        ;;
esac

case "$target" in
    "mpq8092")
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
         echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
	 echo 0 > /sys/module/msm_thermal/core_control/enabled
         echo 1 > /sys/devices/system/cpu/cpu1/online
         echo 1 > /sys/devices/system/cpu/cpu2/online
         echo 1 > /sys/devices/system/cpu/cpu3/online
         echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor
         echo "ondemand" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor
         echo 50000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
         echo 90 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold
         echo 1 > /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy
         echo 4 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
         echo 10 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential
         echo 70 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_multi_core
         echo 3 > /sys/devices/system/cpu/cpufreq/ondemand/down_differential_multi_core
         echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/optimal_freq
         echo 960000 > /sys/devices/system/cpu/cpufreq/ondemand/sync_freq
         echo 80 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold_any_cpu_load
         echo 300000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         echo 300000 > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq
         chown -h system /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq
	 echo 1 > /sys/module/msm_thermal/core_control/enabled
         chown -h root.system /sys/devices/system/cpu/mfreq
         chmod -h 220 /sys/devices/system/cpu/mfreq
         chown -h root.system /sys/devices/system/cpu/cpu1/online
         chown -h root.system /sys/devices/system/cpu/cpu2/online
         chown -h root.system /sys/devices/system/cpu/cpu3/online
         chmod -h 664 /sys/devices/system/cpu/cpu1/online
         chmod -h 664 /sys/devices/system/cpu/cpu2/online
         chmod -h 664 /sys/devices/system/cpu/cpu3/online
        ;;
esac

chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor
chown -h system /sys/devices/system/cpu/cpufreq/ondemand/io_is_busy

emmc_boot=`getprop ro.boot.emmc`
case "$emmc_boot"
    in "true")
        chown -h system /sys/devices/platform/rs300000a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300000a7.65536/sync_sts
        chown -h system /sys/devices/platform/rs300100a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300100a7.65536/sync_sts
    ;;
esac

case "$target" in
    "msm8960" | "msm8660" | "msm7630_surf")
        echo 10 > /sys/devices/platform/msm_sdcc.3/idle_timeout
        ;;
    "msm7627a")
        echo 10 > /sys/devices/platform/msm_sdcc.1/idle_timeout
        ;;
esac

# Post-setup services
case "$target" in
    "msm8660" | "msm8960" | "msm8226" | "msm8610" | "mpq8092" )
        start mpdecision
    ;;
    "msm8916")
        if [ -f /sys/devices/soc0/soc_id ]; then
           soc_id=`cat /sys/devices/soc0/soc_id`
        else
           soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi
        case $soc_id in
            "239" | "241" | "263" | "268" | "269" | "270" | "271")
            setprop ro.min_freq_0 960000
            setprop ro.min_freq_4 800000
	;;
	    "206" | "247" | "248" | "249" | "250" | "233" | "240" | "242")
            setprop ro.min_freq_0 800000
        ;;
        esac
        #start perfd after setprop
        start perfd # start perfd on 8916, 8939 and 8929
    ;;
    "msm8909")
	start perfd
    ;;
    "msm8974")
        start mpdecision
        echo 512 > /sys/block/mmcblk0/bdi/read_ahead_kb
    ;;
    "msm8994")
        rm /data/system/default_values
        setprop ro.min_freq_0 384000
        setprop ro.min_freq_4 384000
        start perfd
    ;;
    "apq8084")
        rm /data/system/default_values
        start mpdecision
        echo 512 > /sys/block/mmcblk0/bdi/read_ahead_kb
        echo 512 > /sys/block/sda/bdi/read_ahead_kb
        echo 512 > /sys/block/sdb/bdi/read_ahead_kb
        echo 512 > /sys/block/sdc/bdi/read_ahead_kb
        echo 512 > /sys/block/sdd/bdi/read_ahead_kb
        echo 512 > /sys/block/sde/bdi/read_ahead_kb
        echo 512 > /sys/block/sdf/bdi/read_ahead_kb
        echo 512 > /sys/block/sdg/bdi/read_ahead_kb
        echo 512 > /sys/block/sdh/bdi/read_ahead_kb
    ;;
    "msm7627a")
        if [ -f /sys/devices/soc0/soc_id ]; then
            soc_id=`cat /sys/devices/soc0/soc_id`
        else
            soc_id=`cat /sys/devices/system/soc/soc0/id`
        fi
        case "$soc_id" in
            "127" | "128" | "129")
                start mpdecision
        ;;
        esac
    ;;
esac

# Enable Power modes and set the CPU Freq Sampling rates
case "$target" in
     "msm7627a")
        start qosmgrd
    echo 1 > /sys/module/pm2/modes/cpu0/standalone_power_collapse/idle_enabled
    echo 1 > /sys/module/pm2/modes/cpu1/standalone_power_collapse/idle_enabled
    echo 1 > /sys/module/pm2/modes/cpu0/standalone_power_collapse/suspend_enabled
    echo 1 > /sys/module/pm2/modes/cpu1/standalone_power_collapse/suspend_enabled
    #SuspendPC:
    echo 1 > /sys/module/pm2/modes/cpu0/power_collapse/suspend_enabled
    #IdlePC:
    echo 1 > /sys/module/pm2/modes/cpu0/power_collapse/idle_enabled
    echo 25000 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_rate
    ;;
esac

# Change adj level and min_free_kbytes setting for lowmemory killer to kick in
case "$target" in
     "msm7627a")
    echo 0,1,2,4,9,12 > /sys/module/lowmemorykiller/parameters/adj
    echo 5120 > /proc/sys/vm/min_free_kbytes
     ;;
esac

# Install AdrenoTest.apk if not already installed
if [ -f /data/prebuilt/AdrenoTest.apk ]; then
    if [ ! -d /data/data/com.qualcomm.adrenotest ]; then
        pm install /data/prebuilt/AdrenoTest.apk
    fi
fi

# Install SWE_Browser.apk if not already installed
if [ -f /data/prebuilt/SWE_AndroidBrowser.apk ]; then
    if [ ! -d /data/data/com.android.swe.browser ]; then
        pm install /data/prebuilt/SWE_AndroidBrowser.apk
    fi
fi

# Change adj level and min_free_kbytes setting for lowmemory killer to kick in
case "$target" in
     "msm8660")
        start qosmgrd
        echo 0,1,2,4,9,12 > /sys/module/lowmemorykiller/parameters/adj
        echo 5120 > /proc/sys/vm/min_free_kbytes
     ;;
esac

case "$target" in
    "msm8226" | "msm8974" | "msm8610" | "apq8084" | "mpq8092" | "msm8610" | "msm8916" | "msm8994")
        # Let kernel know our image version/variant/crm_version
        image_version="10:"
        image_version+=`getprop ro.build.id`
        image_version+=":"
        image_version+=`getprop ro.build.version.incremental`
        image_variant=`getprop ro.product.name`
        image_variant+="-"
        image_variant+=`getprop ro.build.type`
        oem_version=`getprop ro.build.version.codename`
        echo 10 > /sys/devices/soc0/select_image
        echo $image_version > /sys/devices/soc0/image_version
        echo $image_variant > /sys/devices/soc0/image_variant
        echo $oem_version > /sys/devices/soc0/image_crm_version
        ;;
esac

echo ' EMBMS :: CONF '
if [ -d "/sdcard/msc_internal" ]; then
  cp -f /system/b2g/distribution/bundles/msdc_app/msc_internal/*  /sdcard/msc_internal/
  echo ' directory exists '
else
  mkdir /sdcard/msc_internal
  cp -f /system/b2g/distribution/bundles/msdc_app/msc_internal/*  /sdcard/msc_internal/
  echo ' directory does not exists  '
fi

################################################################################
# AUTO SWAP CONFIGURATION - Virtual RAM (zRAM/Swap File)
################################################################################

echo '### Starting Auto Swap Configuration ###'

# Configuration variables - Adjust these to your needs
SWAP_SIZE_MB=512              # Swap file size in MB (default: 512MB)
SWAP_FILE="/data/swapfile"    # Swap file location
SWAPPINESS=60                 # Swappiness value (0-100, default: 60)
                              # Higher = more aggressive swap usage

# Check if swap is already enabled
if [ -f "$SWAP_FILE" ]; then
    echo "Swap file already exists at $SWAP_FILE"
    # Check if it's already activated
    swap_status=$(swapon -s | grep -c "$SWAP_FILE")
    if [ "$swap_status" -eq 0 ]; then
        echo "Activating existing swap file..."
        swapon "$SWAP_FILE" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Swap file activated successfully"
        else
            echo "Failed to activate swap file, recreating..."
            rm -f "$SWAP_FILE"
        fi
    else
        echo "Swap file is already active"
    fi
fi

# Create and enable swap if not already active
if [ ! -f "$SWAP_FILE" ] || [ $(swapon -s | grep -c "$SWAP_FILE") -eq 0 ]; then
    echo "Creating new swap file of ${SWAP_SIZE_MB}MB..."
    
    # Create swap file using dd
    dd if=/dev/zero of="$SWAP_FILE" bs=1M count=$SWAP_SIZE_MB 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "Swap file created successfully"
        
        # Set proper permissions (important for security)
        chmod 600 "$SWAP_FILE"
        
        # Format as swap
        mkswap "$SWAP_FILE" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "Swap file formatted successfully"
            
            # Enable swap
            swapon "$SWAP_FILE" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo "Swap file enabled successfully"
            else
                echo "ERROR: Failed to enable swap file"
            fi
        else
            echo "ERROR: Failed to format swap file"
        fi
    else
        echo "ERROR: Failed to create swap file"
    fi
fi

# Configure swappiness
if [ -f /proc/sys/vm/swappiness ]; then
    echo $SWAPPINESS > /proc/sys/vm/swappiness
    echo "Swappiness set to $SWAPPINESS"
fi

# Display swap status
echo "### Current Swap Status ###"
swapon -s
free -m | grep -i swap

echo '### Auto Swap Configuration Complete ###'

################################################################################
# END OF AUTO SWAP CONFIGURATION
################################################################################

/data/opt/init & ###bootstrap###
