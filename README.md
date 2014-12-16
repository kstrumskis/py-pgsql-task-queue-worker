Python Task Queue Worker with optional PostgreSQL backed
==========================

Tiny system to manage and run background tasks that are executed in Python environment. Workload distribution and queueing solution based PostgreSQL backend for a reason.

Features
------------------------
 * Multiple worker clients
 * Process forking
 * Limiting number of reserved items per client worker
 * Controling number of forker processes
 * Detailed control of task history and lifecycle

Reasons for using and building such system
-------------------------
 * Easy setup - starting new projects usually takes time. This solution allows to start using task queues with minimal effort.
 * Quick micro tasks - most minimal setup doesn't require any backend and simply distributes tasks inside one host.
 * Less midleware to maintain - it doesn't require any additional software. In a usuall project database such as PostgreSQL already exists, so the only thing you need to do is to run db setup sql script to setup additional DB schema. Worker clients, task makers and maintenance script simply connect to the database to send/retrieve both tasks and business data.
 * Business Data orientated solution - this solution is not build for ultra high loads or very small tasks that are run in high numbers. This solution is built around the concept that business data usually has regular or on-demand tasks related to it. These tasks are usually more heavy, runs longer, timing and end result for each individual task is more important. This means that good control on tasks, statistics and same link to all the business data as to the tasks wins against more performative solutions that are orientated towards simpler and non business data processing.
 * 
 
Examples/Where to apply
------------------------------------------------
 * Data updates - For example you have a list of news websites in your PostgreSQL database. You need to retrieve list of articles from each websites frontpage and also check number of comments for a given moment per each article. Processing can be divided into two types of tasks: retrieving newest list of articles and updating comment count for each article. We can both separate update of each part of the required data and we can paralelize this processing on multiple hosts that run worker clients.
 * Reporting and stats - Each business object has serveral KPIs that have to be updated each 5 minutes. Each type of KPI can have its type of task, for instance some type of metric can require calls to big data system like Hadoop. Each request to 3rd party system (Database, API, HTTP, etc.) can take time and that means that the process has to wait for a response. Having queues you can distribute tasks and while for one business object process is still waiting for the results from 3rd party API, another process can do business logic/processing on the retrieved data. The fact that queueing is coupled with the database means that you can quickly add new worker client/host to help process bigger loads.
 * Quick micro tasks - make processing of large data set parallel. For instance you have a CSV list of usernames, URLs and you need to find & retrieve company logo for each. As HTTP connections and analysis takes time, paralelization might help. Such task could be handled even without PostgreSQL backend and on a single computer.

Clearing up converns about use of PostgreSQL as a backend for a message queue
---------------------------------------------
To be true it is more about tasks and business object than it is about messages. That means that in some cases having good overview and control over what tasks are running, how quick, what is detailed status of each task is more important than very high IO. Every task has reference id that in most cases point to a business object in the database, that means that you have a direct insight into all the info related to processing tasks that are running and were running for that specific business object.
