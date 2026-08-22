import json 
import sys 
try :
    print ((json .loads (sys .stdin .read ()).get ('domain')or '').lower (),end ='')
except Exception :
    pass 