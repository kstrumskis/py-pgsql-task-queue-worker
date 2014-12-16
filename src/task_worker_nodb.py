#!/usr/bin/python
# -*- coding: utf-8 -*-

from tasks.custom_task_nodb import setupThreadsForCustomNoDBTask, loadCustomNoDBTasks

def mainDaemon():
	setupThreadsForCustomNoDBTask()
	
	while True:
		loadCustomTasks()

if __name__ == '__main__':
	mainDaemon()