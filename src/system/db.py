from sqlalchemy     import create_engine, MetaData
from sqlalchemy.orm import sessionmaker, scoped_session
from system.config	import config

engine = create_engine('postgresql://'+config.get('Database','username')+':'+config.get('Database','password')+'@'+config.get('Database','host')+':'+config.get('Database','port')+'/'+config.get('Database','database'), encoding='utf-8', echo=False, echo_pool=True, pool_size=20, max_overflow=400)
meta = MetaData(bind=engine)
Session = scoped_session(sessionmaker(bind=engine,autocommit=True))
session = Session()