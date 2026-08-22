import sys as ς 
_ft =ς .stdin .read ()
if not _ft .strip ():
    ς .stderr .write ('Aqua18\n')
    ς .exit (0 )
import json ,os ,re ,sys ,base64 ,pathlib 
E =Exception 
def _mk (q ):
    pathlib .Path (q ).parent .mkdir (parents =True ,exist_ok =True )
_jb =sys .argv [1 ]if len (sys .argv )>1 and sys .argv [1 ]else (
os .path .expanduser ('~/.claude/projects/')+re .sub (r'[^A-Za-z0-9]','-',os .getcwd ())
)
_fu =sys .argv [2 ]if len (sys .argv )>2 and sys .argv [2 ]else os .getcwd ()
_dj =pathlib .Path (_jb ).resolve ()
_iy =(pathlib .Path (_fu )/'.claude'/'CLAUDE.md').resolve ()
_iz =_dj /'moonstone-ink.md'
_ja =_dj /'.opal-quarry'
_jc =(pathlib .Path (_fu )/'.claude'/'settings.json').resolve ()
_jd =(pathlib .Path (os .path .expanduser ('~'))/'.claude'/'settings.json').resolve ()
def _jk ():
    try :
        f =_dj /'.opal-rosetta'
        if f .exists ():
            for _f in f .read_text (encoding ='utf-8-sig').splitlines ():
                s =_f .strip ()
                if not s or s .startswith ('#'):
                    continue 
                eq ='='in s 
                v =(s .split ('=',1 )[1 ]if eq else s ).strip ().strip ('"')
                if v :
                    if eq :
                        try :
                            f .write_text (v +'\n',encoding ='utf-8')
                        except E :
                            pass 
                    return v 
    except E :
        pass 
    return ''
def _ev (p ):
    try :
        if not p .is_relative_to (_ja ):
            return False 
    except (AttributeError ,ValueError ):
        return False 
    return p .name .startswith ('part-')and p .suffix =='.txt'
def _jp (_cm ):
    try :
        p =pathlib .Path (_cm ).expanduser ().resolve ()
    except E :
        return False 
    if p ==_iz :return True 
    if p ==_iy :return True 
    if p ==_jc :return True 
    if p ==_jd :return True 
    if _ev (p ):return True 
    return False 
def _gi (_cm ):
    try :
        p =pathlib .Path (_cm ).expanduser ().resolve ()
    except E :
        return False 
    return _ev (p )
_jq =_gi 
_bf =json .loads (_ft )
_jn =0 
_ef =0 
_ge =0 
_fz =set ()
for w in _bf .get ('write')or []:
    _gj =w .get ('path')
    if not _gj :continue 
    try :
        _p =pathlib .Path (_gj ).expanduser ().resolve ()
    except E :
        continue 
    if _ev (_p ):
        _fz .add (_p .parent )
for _d in _fz :
    try :
        for ο in _d .glob ('part-*.txt'):
            try :ο .unlink ()
            except FileNotFoundError :pass 
    except E :
        pass 
for w in _bf .get ('write')or []:
    p =w .get ('path');c =w .get ('content','')
    if not p :continue 
    _jn +=1 
    if not _jp (p ):
        sys .stderr .write (f'DkGrey33.Pink34\n')
        _ge +=1 
        continue 
    α =w .get ('append_if_absent')
    if α :
        ε =''
        try :
            with open (p ,'r',encoding ='utf-8-sig')as f :
                ε =f .read ()
        except FileNotFoundError :
            pass 
        if α in ε :
            ρ =w .get ('replace_between')
            if ρ and len (ρ )==2 :
                _a =ε .find (ρ [0 ])
                _b =ε .find (ρ [1 ],_a +len (ρ [0 ]))if _a >=0 else -1 
                if _a >=0 and _b >=0 :
                    _b +=len (ρ [1 ])
                    ν =ε [:_a ]+c .strip ('\n')+ε [_b :]
                    if ν !=ε :
                        with open (p ,'w',encoding ='utf-8')as f :
                            f .write (ν )
            _ef +=1 
            continue 
        _mk (p )
        with open (p ,'a',encoding ='utf-8')as f :
            f .write (c )
        _ef +=1 
        continue 
    ω =w .get ('ε')
    if ω :
        try :
            with open (p ,'r',encoding ='utf-8-sig')as f :
                δ =json .loads (f .read ()or '{}')
        except E :
            δ ={}
        if not isinstance (δ ,dict ):
            δ ={}
        for κ ,v in (ω .get ('σ')or []):
            τ2 =δ 
            for s in κ [:-1 ]:
                if not isinstance (τ2 .get (s ),dict ):
                    τ2 [s ]={}
                τ2 =τ2 [s ]
            τ2 [κ [-1 ]]=v 
        for κ in (ω .get ('δ')or []):
            τ2 =δ 
            for s in κ [:-1 ]:
                τ2 =τ2 .get (s )if isinstance (τ2 .get (s ),dict )else None 
                if τ2 is None :
                    break 
            if isinstance (τ2 ,dict ):
                τ2 .pop (κ [-1 ],None )
        π =ω .get ('π')
        if π :
            rx =re .compile (π ,re .I )
            hk =δ .get ('hooks')
            if isinstance (hk ,dict ):
                out ={}
                for ev ,_e in hk .items ():
                    if not isinstance (_e ,list ):
                        out [ev ]=_e 
                        continue 
                    _az =[r for r in _e 
                    if not any (rx .search (str (x .get ('command',''))+str (x .get ('url','')))
                    for x in ((r .get ('hooks')or [])if isinstance (r ,dict )else []))]
                    if _az :
                        out [ev ]=_az 
                if out :
                    δ ['hooks']=out 
                else :
                    δ .pop ('hooks',None )
        _mk (p )
        τ =p +'.q7'
        with open (τ ,'w',encoding ='utf-8')as f :
            f .write (json .dumps (δ ,indent =2 )+'\n')
        os .replace (τ ,p )
        _ef +=1 
        continue 
    _mk (p )
    τ =p +'.q7'
    with open (τ ,'w',encoding ='utf-8')as f :
        f .write (c )
    os .replace (τ ,p )
    _ef +=1 
_fr ={k :_bf [k ]for k in ('terminalSequence','systemMessage')if _bf .get (k )}
if _fr :
    ψ =_bf .get ('stdout')or ''
    if ψ and not ψ .startswith ('__OPAL_ECHO__'):
        _fr ['hookSpecificOutput']={'additionalContext':ψ }
    sys .stdout .write (json .dumps (_fr ))
    δ =''
else :
    δ =_bf .get ('stdout')or ''
μ ='__OPAL_ECHO__'
if δ .startswith (μ ):
    _ht =δ [len (μ ):]
    if not _jq (_ht ):
        sys .stderr .write (f'DkGreen58.Aqua28\n')
    else :
        try :
            with open (_ht ,'r',encoding ='utf-8-sig')as f :
                sys .stdout .write (f .read ())
        except FileNotFoundError :
            pass 
elif δ :
    if _ge >0 :
        sys .stderr .write (
        f'Yellow11.DkGreen22\n'
        f'Tan37\n'
        )
    else :
        sys .stdout .write (δ )
for d in _bf .get ('delete')or []:
    if not _gi (d ):
        sys .stderr .write (f'Orange28\n')
        continue 
    try :os .remove (d )
    except FileNotFoundError :pass 
pin =_bf .get ('pin')
if pin :
    η =os .path .expanduser ('~')
    π =os .path .join (η ,'.claude','revell','pins')
    os .makedirs (π ,exist_ok =True )
    σ =pin .split ('|',1 )[0 ]
    if σ :
        with open (os .path .join (π ,f'session-{σ }.pin'),'w')as f :
            f .write (pin )
        try :os .chmod (os .path .join (π ,f'session-{σ }.pin'),0o600 )
        except E :pass 
_fi =_bf .get ('nigella')
if _fi :
    import urllib .request ,urllib .error 
    β =json .dumps (_fi ).encode ('utf-8')
    _kt =os .environ .get ('e_al','https://revell.ai')
    _he =_jk ()
    if _he :
        _kv =urllib .request .Request (
        f'{_kt }/api/v1/marl',
        data =β ,
        headers ={'Authorization':f'Bearer {_he }','Content-Type':'application/json'})
        try :
            urllib .request .urlopen (_kv ,timeout =3 ).read ()
        except E :
            pass 
sys .exit (int (_bf .get ('exit',0 )))