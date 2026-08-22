import json 
import os 
import pathlib 
import re 
import sys 
_M =re .compile (
r'[Oo][Pp][Aa][Ll][-_]|[Rr][Ee][Vv][Ee][Ll][Ll]|[Mm][Oo][Oo][Nn][Ss][Tt][Oo][Nn][Ee]')
S =_M .search 
E =Exception 
def _r (p ,**k ):
    with open (p ,encoding ='utf-8-sig',**k )as f :
        return f .read ()
def _w (p ,d ):
    t =str (p )+'.q7'
    with open (t ,'w',encoding ='utf-8')as f :
        f .write (json .dumps (d ,indent =2 )+'\n')
    os .replace (t ,p )
def _c8 ():
    hm =pathlib .Path (sys .argv [2 ])
    rt =hm /'.claude'/'projects'
    if not rt .is_dir ():
        return 
    kn ={}
    try :
        for κ in (json .loads (_r (hm /'.claude.json')).get ('projects')or {}):
            kn [re .sub (r'[^A-Za-z0-9]','-',κ )]=κ 
    except E :
        pass 
    for d in sorted (rt .iterdir ()):
        if not d .is_dir ():
            continue 
        wp =''
        α =d /'.opal-anchor.json'
        if α .exists ():
            try :
                wp =json .loads (_r (α )).get ('workspace_path')or ''
            except E :
                wp =''
        if not wp :
            wp =kn .get (d .name ,'')
        if not wp :
            continue 
        md =pathlib .Path (wp )/'.claude'/'CLAUDE.md'
        try :
            if md .exists ()and 'BEGIN REVELL (managed)'in _r (md ,errors ='replace'):
                print (md )
        except E :
            pass 
def _c9 ():
    p =pathlib .Path (sys .argv [2 ])
    try :
        d =json .loads (_r (p )or '{}')
    except E :
        sys .exit (0 )
    h =d .get ('hooks')
    if isinstance (h ,dict ):
        out ={}
        for ev ,_e in h .items ():
            if not isinstance (_e ,list ):
                out [ev ]=_e 
                continue 
            _az =[r for r in _e 
            if not any (S (str (x .get ('command',''))+str (x .get ('url','')))
            for x in ((r .get ('hooks')or [])if isinstance (r ,dict )else []))]
            if _az :
                out [ev ]=_az 
        if out :
            d ['hooks']=out 
        else :
            d .pop ('hooks',None )
    sl =d .get ('statusLine')
    if isinstance (sl ,dict )and S (str (sl .get ('command',''))):
        d .pop ('statusLine',None )
    ep =d .get ('enabledPlugins')
    if isinstance (ep ,dict ):
        _hi ={k :v for k ,v in ep .items ()if not S (k )}
        if _hi :
            d ['enabledPlugins']=_hi 
        else :
            d .pop ('enabledPlugins',None )
    _w (p ,d )
def _ca ():
    hm =pathlib .Path (sys .argv [2 ])
    n =0 
    for p ,κ in ((hm /'.claude'/'plugins'/'installed_plugins.json','plugins'),
    (hm /'.claude'/'plugins'/'known_marketplaces.json',None ),
    (hm /'.claude.json','favoritePlugins')):
        if not p .exists ():
            continue 
        try :
            d =json .loads (_r (p )or '{}')
        except E :
            continue 
        τ =d if κ is None else d .get (κ )
        if isinstance (τ ,dict ):
            g =[k for k in τ if S (k )]
            for k in g :
                τ .pop (k ,None )
        elif isinstance (τ ,list ):
            g =[v for v in τ if isinstance (v ,str )and S (v )]
            if g :
                d [κ ]=[v for v in τ if v not in g ]
        else :
            continue 
        if g :
            n +=len (g )
            _w (p ,d )
    print (n )
e_e ={'8':_c8 ,'9':_c9 ,'a':_ca }
if __name__ =='__main__':
    if len (sys .argv )>1 and sys .argv [1 ]in e_e :
        e_e [sys .argv [1 ]]()