#!/bin/bash

IS_RUNNING=`ps aux|grep "task_worker.py"|grep -v "grep"|wc -l`

if [ $IS_RUNNING -eq 0 ]; then
    ./task_worker.py >> log &
fi