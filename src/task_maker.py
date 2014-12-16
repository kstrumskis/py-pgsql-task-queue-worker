#!/usr/bin/python
# -*- coding: utf-8 -*-

from system.db import session
from system.data import Task, TaskType

def customTaskMaker():

	task_type = session.query(TaskType.id).filter(TaskType.name=='tasks.custom_task').first()

	for i in range(10):
		task = Task()
		task.type = task_type
		task.reference_id = i
		session.add(task)
		session.flush()


def mainDaemon():
   
	customTaskMaker()

	while True:
		pass

if __name__ == '__main__':
    mainDaemon()