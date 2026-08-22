import json 
import pathlib 
import sys 
E =Exception 
def _r (p ):
    with open (p ,encoding ='utf-8-sig')as f :
        return f .read ()
def _w (p ,σ ):
    with open (p ,'w',encoding ='utf-8')as f :
        f .write (σ )
def _c7 ():
    p =pathlib .Path (sys .argv [2 ])
    try :
        d =json .loads (_r (p )or '{}')
    except E :
        d ={}
    κ =d .get ('statusLine')
    if isinstance (κ ,dict ):
        c =str (κ .get ('command')or '')
        _m =pathlib .Path (sys .argv [3 ]).name 
        _t =pathlib .Path (c .strip ('"').split ()[-1 ]).name if c .strip ()else ''
        if c and _t !=_m :
            b =p .with_name (p .name +'.bak')
            if not b .exists ():
                _w (b ,_r (p ))
    d ['statusLine']={'type':'command','command':sys .argv [3 ]}
    _w (p ,json .dumps (d ,indent =2 )+'\n')
e_e ={'7':_c7 }
if __name__ =='__main__':
    if len (sys .argv )>1 and sys .argv [1 ]in e_e :
        e_e [sys .argv [1 ]]()