from system.db import meta

from sqlalchemy import Table
from sqlalchemy.orm import mapper

schema_name = 'task-queue-worker'

################################################################################

table_worker_task_queue = Table('task_queue', meta, schema=schema_name, autoload=True)

class Task(object):
    def __init__(self): pass

mapper(Task, table_worker_task_queue)

################################################################################

table_worker_task_type = Table('task_type', meta, schema=schema_name, autoload=True)

class TaskType(object):
    def __init__(self): pass

mapper(TaskType, table_worker_task_type)

################################################################################

table_v_task_queue_fresh = Table('v_task_queue_fresh', meta, schema=schema_name, autoload=True)

class TaskFresh(object):
    def __init__(self): pass

mapper(TaskFresh, table_v_task_queue_fresh,primary_key=[table_v_task_queue_fresh.c.id])

################################################################################

table_worker_client = Table('client', meta, schema=schema_name, autoload=True)

class Client(object):
    def __init__(self): pass

mapper(Client, table_worker_client)