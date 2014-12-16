from system.db import session, meta
import socket
from sqlalchemy import Table
from sqlalchemy.orm import mapper
from system.data import Client

gid = 0

def getClient():
    global gid
    if gid==0:
        client = Client()
        client.category = 'misc'
        client.hostname = socket.gethostname()
        client.hostip = getNetworkIp()
        session.add(client)
        session.flush()
        gid = client.id
    return gid

def getNetworkIp():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(('google.com', 0))
    return s.getsockname()[0]