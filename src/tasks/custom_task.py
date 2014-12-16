import threading
import Queue
from system.db      import session
from system.db      import Session
from system.data 	import Task
from sqlalchemy import and_
from system.data import Task, TaskFresh, TaskType
from system.db import session
from system.client import getClient

custom_task_queue = Queue.Queue()

################################################################################

class CustomTaskThread(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue

    def run(self):
        session = Session()

        while True:

            task_id = self.queue.get()

            task = session.query(Task).filter(Task.id == task_id).first()

            task.started = True
            session.flush()

            try:
                print task
            

                task.completed = True
                session.flush()
                
            except:
                if sys:
                    print sys.exc_info()[0]
                    print sys.exc_info()
            
            self.queue.task_done()


################################################################################

def setupThreadsForCustomTask():
    for i in range(8):
        t = CustomTaskThread(custom_task_queue)
        t.setDaemon(True)
        t.start()

################################################################################

def loadCustomTasks():

    if custom_task_queue.qsize()<32:
    
        task_type = session.query(TaskType.id).filter(TaskType.name=='tasks.custom_task').first()
        
        for item in session.query(Task).filter(
                                               and_(
                                                    Task.type == task_type.id,
                                                    Task.reserved == False,
                                                    Task.completed == False
                                                    )
                                               ).limit(25).all():
            
            item.reserved = True
            item.client = getClient()
            id = item.id
            session.flush()
            custom_task_queue.put(id)
        
################################################################################
