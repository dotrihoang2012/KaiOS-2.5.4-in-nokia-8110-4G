#!/system/bin/sh
# Copyright (c) 2017, The Linux Foundation. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

mtd_file="/proc/mtd"

# mount underlying ubi device onto mount-points
Mount () {
    partition=$1
    device_num=$2
    volume_num=$3
    dir=$4
    options=$5
    should_attach=$6

    device="/dev/ubi${device_num}_${volume_num}"

    mtd_block_number=`cat /proc/mtd | grep -i $partition | awk -F ':' '{print $1}' | cut -c4-`

    # Check whether an explicit ubiattach needs to be done or not
    if [ "$should_attach" == "attach" ]; then
        echo "Attaching ubi device" $device_num "to mtd device" $mtd_block_number > /dev/kmsg
        ubiattach -m $mtd_block_number -d $device_num /dev/ubi_ctrl
    fi

    while [ 1 ]
    do
        if [ -c $device ]
        then
            mount -t ubifs -o $options $device $dir
            break
        else
            echo $device not yet detected > /dev/kmsg
            sleep 0.010
        fi
    done
}

# Mount userdata/cache and persist volumes
# onto the same ubi device
# Format:
# eval Mount <mtd_partition_name> <ubi_device_id> <volume_id> <mnt_point> <mnt_flags> <attach/noattach>

# For a given mtd-to-ubi_device mapping, ubiattach needs to called only once.
# If there are multiple volumes mapped to the same ubi_device,
# pass "attach" only for the first volume being mapped
# and "noattach" for the other volumes on that ubi_device

eval Mount userdata 1 0 /data "nosuid,nodev,bulk_read" "attach"
eval Mount userdata 1 1 /cache "nosuid,nodev" "noattach"
eval Mount userdata 1 2 /persist "nosuid,nodev" "noattach"

#Mount modem onto /firmware
eval Mount modem 2 0 /firmware "nosuid,nodev" "attach"
