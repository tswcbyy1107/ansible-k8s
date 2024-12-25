#!/bin/bash
# kubelet config --log-dir=/data0/log/kube
for i in {WARNING,INFO,ERROR,FATAL}; do
    num=$(ls -lt /data0/log/kube/*$i* | grep -v lrwxrwxrwx | wc -l)
    delete_num=$(expr $num - 5)
    if [ "$num" -gt 5 ]; then
        ls -lt /data0/log/kube/*$i* | grep -v lrwxrwxrwx | tail -n $delete_num | awk '{print $9}' | xargs rm
    else
        echo "$i is OK"
    fi
done

total_size=$(du -sm /data0/log/kube | awk '{print $1}')
for level in {ERROR,WARNING,INFO}; do
    link_file=$(readlink /data0/log/kube/kubelet.${level})
    for file in $(ls -ltr /data0/log/kube/*$level* | grep -v "lrwxrwxrwx" | awk '{print $9}'); do
        file_name=$(basename $file)
        if [ x"$file_name" = x"$link_file" ]; then
            continue
        fi
        if [ $total_size -lt 9000 ]; then
            break
        fi
        size=$(du -sm $file | awk '{print $1}')
        rm -f $file
        total_size=$((total_size - size))
    done
done
