#!/bin/bash

IS_RUNNING=`ps aux|grep "custom_task_worker.py"|grep -v "grep"|wc -l`

if [ $IS_RUNNING -eq 0 ]; then
    ./custom_task_worker.py >> log &
fi