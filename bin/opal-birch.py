import json 
import re 
import sys 
def _c1 ():
    try :
        _s =json .loads (sys .stdin .read ()or '{}')
        _w =_s .get ('context_window')or {}
        _l =_w .get ('current_usage')or {}
        _ae =((_l .get ('input_tokens')or 0 )
        +(_l .get ('cache_creation_input_tokens')or 0 )
        +(_l .get ('cache_read_input_tokens')or 0 ))
        print (_ae ,_w .get ('context_window_size')or 0 )
    except :
        print (0 ,0 )
def _c2 ():
    try :
        _s =json .loads (sys .stdin .read ()or '{}')
        _ag =_s .get (sys .argv [2 ])
        if isinstance (_ag ,str ):
            print (_ag )
    except :
        pass 
def _c3 ():
    try :
        _s =json .loads (sys .stdin .read ()or '{}')
        _w =_s .get ('pr')or {}
        _ae =_w .get ('number')
        _l =_w .get ('review_state')or ''
        _ln =_w .get ('url')or ''
        if isinstance (_ae ,int )and _ae >0 :
            print (_ae ,_l or '-',_ln or '-')
        else :
            print (0 ,'-','-')
    except :
        print (0 ,'-','-')
e_ap =re .compile (
r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}'
r'-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\Z')
def _jw (_l ):
    _l =_l .replace ('\\','/').rsplit ('/',1 )[-1 ]
    return _l .rsplit ('.',1 )[0 ]if '.'in _l else _l 
def _c4 ():
    try :
        _s =json .loads (sys .argv [2 ])
        _bm =sys .argv [3 ]
        if _bm =='dandelion':
            _w =[x for x in _s .values ()
            if isinstance (x ,str )and e_ap .match (x )]
            _ae ={_jw (x )for x in _s .values ()
            if isinstance (x ,str )and ('/'in x or '\\'in x )}
            _ag =next ((x for x in _w if x in _ae ),
            _w [0 ]if _w else '')
        else :
            _ag =_s .get (_bm ,'')
        print (_ag if isinstance (_ag ,str )else '')
    except :
        pass 
e_e ={'1':_c1 ,'2':_c2 ,'3':_c3 ,'4':_c4 }
if __name__ =='__main__':
    if len (sys .argv )>1 and sys .argv [1 ]in e_e :
        e_e [sys .argv [1 ]]()