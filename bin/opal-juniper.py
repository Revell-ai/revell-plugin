import json 
import os 
import pathlib 
import re 
import sys 
e_d =re .compile (
r'<!-- BEGIN REVELL \(managed\) -->.*?<!-- END REVELL \(managed\) -->\r?\n?',
re .DOTALL )
S =e_d .sub 
E =Exception 
def _r (p ):
    with open (p ,encoding ='utf-8-sig')as f :
        return f .read ()
def _w (p ,s ):
    with open (p ,'w',encoding ='utf-8')as f :
        f .write (s )
def _c1 ():
    p ,θ =pathlib .Path (sys .argv [2 ]),sys .argv [3 ]
    σ =pathlib .Path (sys .argv [4 ])
    τ =_r (p )if p .exists ()else ''
    τ =S ('',τ )
    if σ .exists ():
        _ei =S ('',_r (σ )).strip ()
        if _ei :
            if not τ .strip ():
                τ =_ei 
            elif _ei not in τ :
                τ =τ .rstrip ('\n')+'\n\n'+_ei 
    _gq =('\n<!-- BEGIN REVELL (managed) -->\n'
    f'@{θ }\n'
    '<!-- END REVELL (managed) -->\n')
    _w (p ,τ .rstrip ('\n')+'\n'+_gq if τ .strip ()else _gq .lstrip ('\n'))
def _c2 ():
    p =pathlib .Path (sys .argv [2 ])
    try :
        d =json .loads (_r (p )or '{}')
    except E :
        d ={}
    d .setdefault ('enabledPlugins',{})['revell@revell-plugin']=True 
    d ['statusLine']={'type':'command','command':sys .argv [3 ]}
    _w (p ,json .dumps (d ,indent =2 ))
def _c3 ():
    import datetime 
    json .dump ({
    'moved_to':sys .argv [3 ],
    'moved_at':datetime .datetime .now (datetime .timezone .utc ).strftime (
    '%Y-%m-%dT%H:%M:%SZ'),
    },open (sys .argv [2 ],'w'),indent =2 )
def _c4 ():
    p =pathlib .Path (sys .argv [2 ])
    if p .exists ():
        τ =S ('',_r (p ))
        _w (p ,τ )if τ .strip ()else p .unlink ()
def _c5 ():
    p =pathlib .Path (sys .argv [2 ])
    if p .exists ():
        try :
            d =json .loads (_r (p )or '{}')
        except E :
            sys .exit (0 )
        d .pop ('statusLine',None )
        _w (p ,json .dumps (d ,indent =2 ))
def _c6 ():
    print (os .path .abspath (os .path .expanduser (sys .argv [2 ])))
e_e ={'1':_c1 ,'2':_c2 ,'3':_c3 ,'4':_c4 ,'5':_c5 ,'6':_c6 }
if __name__ =='__main__':
    if len (sys .argv )>1 and sys .argv [1 ]in e_e :
        e_e [sys .argv [1 ]]()