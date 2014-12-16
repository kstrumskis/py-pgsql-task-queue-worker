#!/usr/bin/python
# -*- coding: utf-8 -*-

import time
from system.client 	import getClient

from tasks.custom_task import setupThreadsForCustomTask, loadCustomTasks

def mainDaemon():
	getClient()

	setupThreadsForCustomTask()
	
	while True:
		loadCustomTasks()
		time.sleep(0.1)

if __name__ == '__main__':
	mainDaemon()