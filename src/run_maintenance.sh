#!/bin/bash

# ~/.pgpass file has to exist in order to avoid password requirement
#
# .pgpass internal structure:
#
# host:5432:dbname:user:pass
#

psql -h host -U user dbname -c "SELECT \"task-queue-worker\".clean_task_queue();"
