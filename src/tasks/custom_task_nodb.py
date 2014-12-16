import threading
import Queue

custom_task_nodb_queue = Queue.Queue()

################################################################################

class CustomTaskNoDBThread(threading.Thread):
    def __init__(self, queue):
        threading.Thread.__init__(self)
        self.queue = queue

    def run(self):
        while True:

            task_id = self.queue.get()

            try:
                print task_id
                            
            except:
                if sys:
                    print sys.exc_info()[0]
                    print sys.exc_info()
            
            self.queue.task_done()


################################################################################

def setupThreadsForCustomNoDBTask():
    for i in range(8):
        t = CustomTaskNoDBThread(custom_task_nodb_queue)
        t.setDaemon(True)
        t.start()

################################################################################

def loadCustomNoDBTasks():
    
    for i in range(10):
        custom_task_nodb_queue.put(i)
        
################################################################################
