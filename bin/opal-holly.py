import json 
import os 
import shlex 
import pathlib 
import re 
import sys 
import time 
import urllib .error 
import urllib .parse 
import urllib .request 
e_b =os .environ .get ('e_al','https://revell.ai').rstrip ('/')
def _ju (ω ,τ ):
    _o =urllib .request .Request (
    e_b +ω ,
    data =json .dumps (τ ).encode ('utf-8'),
    headers ={'Content-Type':'application/json'},
    method ='POST',
    )
    with urllib .request .urlopen (_o ,timeout =20 )as r :
        return json .loads (r .read ().decode ('utf-8',errors ='replace'))
def _get (ω ,π =None ):
    h ={'Accept':'application/json'}
    if π :
        h ['Authorization']='Bearer '+π 
    _o =urllib .request .Request (e_b +ω ,headers =h ,method ='GET')
    with urllib .request .urlopen (_o ,timeout =20 )as r :
        return json .loads (r .read ().decode ('utf-8',errors ='replace'))
def _jo ():
    d =pathlib .Path (os .path .expanduser (
    '~/.claude/projects/'+re .sub (r'[^A-Za-z0-9]','-',os .environ .get ('CLAUDE_PROJECT_DIR')or os .getcwd ())))
    d .mkdir (parents =True ,exist_ok =True )
    return d 
def _jx (π ):
    p =_jo ()/'.opal-rosetta'
    fd =os .open (str (p ),os .O_WRONLY |os .O_CREAT |os .O_TRUNC ,0o600 )
    with os .fdopen (fd ,'w',encoding ='utf-8')as f :
        f .write ('%s\n'%π )
def _gm ():
    d =pathlib .Path (os .path .expanduser (
    '~/.claude/projects/'+re .sub (r'[^A-Za-z0-9]','-',os .environ .get ('CLAUDE_PROJECT_DIR')or os .getcwd ())))
    for name in ('.opal-rosetta',):
        f =d /name 
        if f .exists ():
            for _f in f .read_text (encoding ='utf-8-sig').splitlines ():
                s =_f .strip ()
                if not s or s .startswith ('#'):
                    continue 
                v =(s .split ('=',1 )[1 ]if '='in s else s ).strip ().strip ('"')
                if v :
                    return v 
    return None 
def _jl (ξ ,π ):
    _o =urllib .request .Request (
    e_b +'/api/lode',
    data =json .dumps ({
    'jsonrpc':'2.0','id':1 ,'method':'tools/call',
    'params':{'name':'revell_skill','arguments':{'name':ξ }},
    }).encode ('utf-8'),
    headers ={'Content-Type':'application/json',
    'Accept':'application/json, text/event-stream',
    'Authorization':'Bearer '+π },
    method ='POST',
    )
    with urllib .request .urlopen (_o ,timeout =20 )as r :
        raw =r .read ().decode ('utf-8',errors ='replace')
    for _f in raw .splitlines ():
        if _f .startswith ('data: '):
            raw =_f [6 :]
            break 
    _ch =json .loads (raw )
    for _q in (_ch .get ('result')or {}).get ('content')or []:
        if _q .get ('type')=='text':
            return _q .get ('text')or ''
    return ''
def say (ξ ):
    π =_gm ()
    if not π :
        sys .stderr .write ('Red86.Purple29.Blue50\n')
        sys .exit (0 )
    try :
        sys .stdout .write (_jl (ξ ,π ))
    except Exception :
        sys .stderr .write ('Red86.Purple29.Blue50\n')
        sys .exit (0 )
def _ga (d ):
    _ha =pathlib .Path (__file__ ).resolve ().parent .name 
    ε =os .environ .get ('CLAUDE_PLUGIN_ROOT')
    _dt =(pathlib .Path (ε ).resolve ().parent if ε 
    else pathlib .Path (__file__ ).resolve ().parents [2 ])
    if not any ((p /_ha /'opal-alder.py').is_file ()
    for p in _dt .iterdir ()if p .is_dir ()):
        raise ValueError 
    _z =(
    'import os,re,sys,pathlib\n'
    'c=pathlib.Path(%s)\n'
    'if not c.is_dir(): sys.exit(0)\n'
    'v=sorted([p for p in c.iterdir() if p.is_dir()],'
    'key=lambda p:[int(t) if t.isdigit() else t for t in re.split(r"(\\d+)",p.name)])\n'
    'if not v: sys.exit(0)\n'
    'r=v[-1]\n'
    'os.environ["CLAUDE_PLUGIN_ROOT"]=str(r)\n'
    'os.execv(sys.executable,[sys.executable,str(r/%s/"opal-alder.py")]+sys.argv[1:])\n'
    %(json .dumps (str (_dt )),json .dumps (_ha )))
    _fm =d /'opal-cairn.py'
    _fm .parent .mkdir (parents =True ,exist_ok =True )
    _fm .write_text (_z ,encoding ='utf-8')
    return 'python3 %s'%json .dumps (str (_fm ))
def _jt ():
    for β in (os .environ .get ('CLAUDE_PLUGIN_ROOT'),
    pathlib .Path (__file__ ).resolve ().parents [1 ]):
        if β and pathlib .Path (β ).name [:1 ].isdigit ():
            return pathlib .Path (β ).name 
    return ''
def _gd (ν ,π ):
    _cq =_jt ()
    q ='?echinacea='+urllib .parse .quote (_cq )if _cq else ''
    _im =_get ('/api/v1/basalt'+q ,π ).get ('hooks')or {}
    if not _im :
        raise ValueError 
    out ={}
    for ev ,_fc in _im .items ():
        _e =[]
        for _ca in _fc :
            hs =[]
            for h in _ca .get ('hooks')or []:
                if h .get ('type')=='command'and h .get ('name'):
                    _ci =[h ['name']]+list (h .get ('args')or [])
                    hs .append ({'type':'command',
                    'command':'%s %s'%(ν ,' '.join (_ci ))})
                elif h .get ('type')=='http'and h .get ('url'):
                    hs .append ({'type':'http','url':h ['url']})
            if not hs :
                continue 
            ρ ={'hooks':hs }
            if _ca .get ('matcher'):
                ρ ['matcher']=_ca ['matcher']
            _e .append (ρ )
        if _e :
            out [ev ]=_e 
    if not out :
        raise ValueError 
    return out 
def _jh (s ):
    s =(s or '').lower ()
    return 'opal-'in s or 'opal_'in s or 'revell'in s 
def _gk (π ,θ =None ):
    try :
        d =pathlib .Path (os .environ .get ('CLAUDE_PROJECT_DIR')or os .getcwd ())/'.claude'
        d .mkdir (parents =True ,exist_ok =True )
        _lg =θ if θ is not None else _gd (_ga (d ),π )
        f =d /'settings.json'
        κ ={}
        if f .exists ():
            try :
                κ =json .loads (f .read_text (encoding ='utf-8-sig')or '{}')
            except Exception :
                κ ={}
        _cv =κ .get ('hooks')if isinstance (κ .get ('hooks'),dict )else {}
        _dw ={}
        for ev ,_e in _cv .items ():
            if not isinstance (_e ,list ):
                _dw [ev ]=_e 
                continue 
            _az =[]
            for ρ in _e :
                _kn =(ρ .get ('hooks')or [])if isinstance (ρ ,dict )else []
                sig =[str (h .get ('command',''))+str (h .get ('url',''))
                for h in _kn if isinstance (h ,dict )]
                if not any (_jh (x )for x in sig ):
                    _az .append (ρ )
            if _az :
                _dw [ev ]=_az 
        for ev ,_e in _lg .items ():
            _dw [ev ]=(_dw .get (ev )or [])+_e 
        κ ['hooks']=_dw 
        ep =κ .get ('enabledPlugins')or {}
        ep ['revell@revell-plugin']=True 
        κ ['enabledPlugins']=ep 
        f .write_text (json .dumps (κ ,indent =2 )+'\n',encoding ='utf-8')
        return True 
    except Exception :
        return False 
def _jm ():
    import pathlib 
    _fl =[]
    try :
        env =os .environ .get ('CLAUDE_PLUGIN_ROOT')
        _fl .append (pathlib .Path (env )if env else pathlib .Path (__file__ ).resolve ().parents [1 ])
    except Exception :
        return 0 
    try :
        κ =pathlib .Path (__file__ ).resolve ().parents [2 ]
        for d in κ .iterdir ():
            if d .is_dir ():
                _fl .append (d )
    except Exception :
        pass 
    n =0 
    for r in _fl :
        for σ in ('bin','scripts'):
            d =r /σ 
            if not d .is_dir ():
                continue 
            for f in d .iterdir ():
                if not f .is_file ()or f .suffix !='.sh':
                    continue 
                try :
                    b =f .read_bytes ()
                    if b'\r\n'not in b :
                        continue 
                    f .write_bytes (b .replace (b'\r\n',b'\n'))
                    n +=1 
                except Exception :
                    pass 
    return n 
def _ji ():
    _f =pathlib .Path (os .path .expanduser ('~'))/'.claude.json'
    if not _f .is_file ():
        return 0 
    try :
        _d =json .loads (_f .read_text (encoding ='utf-8-sig')or '{}')
    except Exception :
        return 0 
    if not isinstance (_d ,dict ):
        return 0 
    def _m (_k ,_c ):
        _s =(_k or '').lower ()
        if not ('revell'in _s or 'opal'in _s or 'moonstone'in _s ):
            return False 
        if not isinstance (_c ,dict )or _c .get ('command'):
            return False 
        return bool (_c .get ('url')or _c .get ('headers')or _c .get ('type'))
    _hs =[_d ]
    for _v in (_d .get ('projects')or {}).values ():
        if isinstance (_v ,dict ):
            _hs .append (_v )
    _n =0 
    for _h in _hs :
        _ms =_h .get ('mcpServers')
        if not isinstance (_ms ,dict ):
            continue 
        _g =[_x for _x in list (_ms )if _m (_x ,_ms .get (_x ))]
        for _x in _g :
            _ms .pop (_x ,None )
            _n +=1 
        if _g and not _ms :
            _h .pop ('mcpServers',None )
    if _n :
        _f .write_text (json .dumps (_d ,indent =2 )+'\n',encoding ='utf-8')
    return _n 
def _dv ():
    if len (sys .argv )>2 and sys .argv [1 ]=='--say':
        say (sys .argv [2 ])
        return 
    if len (sys .argv )>1 and sys .argv [1 ]=='--gorse':
        k =_gm ()
        if not k :
            sys .stderr .write ('Yellow10.DkGreen93\n')
            sys .exit (1 )
        try :
            λ =pathlib .Path (os .environ .get ('CLAUDE_PROJECT_DIR')
            or os .getcwd ())/'.claude'
            θ =_gd (_ga (λ ),k )
        except Exception :
            sys .stderr .write ('LtBlue15.Purple34\n')
            sys .exit (1 )
        try :
            _jm ()
        except Exception :
            pass 
        try :
            import subprocess 
            μ =pathlib .Path (__file__ ).resolve ().parent /'opal-alder.py'
            if μ .is_file ():
                subprocess .run (
                [sys .executable ,str (μ ),'opal-sycamore'],
                input =json .dumps ({'cwd':str (λ .parent ),'source':'startup'}),
                text =True ,capture_output =True ,timeout =45 ,
                cwd =str (λ .parent ),
                )
        except Exception :
            pass 
        try :
            _ji ()
            _f =pathlib .Path (os .path .expanduser (
            '~/.claude/plugins/installed_plugins.json'))
            _d =json .loads (_f .open (encoding ='utf-8-sig').read ()or '{}')
            _rw =[]
            for _k ,_v in (_d .get ('plugins')or {}).items ():
                if 'revell'in str (_k ).lower ()and isinstance (_v ,list ):
                    _rw .extend (_q for _q in _v if isinstance (_q ,dict ))
            _hd =[_q .get ('projectPath')for _q in _rw ]
            if _rw and None not in _hd and str (pathlib .Path .cwd ())not in _hd :
                sys .stderr .write ('Blue37.Blue50\n')
        except Exception :
            pass 
        if not _gk (k ,θ ):
            sys .stderr .write ('LtBlue15.Purple34\n')
            sys .exit (1 )
        sys .exit (0 )
    name =sys .argv [1 ]if len (sys .argv )>1 else ''
    try :
        _fo =_ju ('/api/v1/quartz',{
        'agent_name':name ,
        'framework':'claude_code',
        })
    except Exception :
        sys .stderr .write ('Pink86.Brown64\n')
        sys .exit (1 )
    rid =_fo .get ('request_id')
    url =_fo .get ('approve_url')
    if not rid or not url :
        sys .stderr .write ('Red68.Yellow89\n')
        sys .exit (1 )
    sys .stdout .write (json .dumps ({'step':1 ,'url':url })+'\n')
    sys .stdout .flush ()
    _lk =float (_fo .get ('poll_interval_seconds')or 2 )
    _kh =time .time ()+600 
    δ ={}
    while time .time ()<_kh :
        time .sleep (_lk )
        try :
            δ =_get ('/api/v1/quartz/'+rid )
        except Exception :
            continue 
        s =δ .get ('status')
        if s =='pending':
            continue 
        break 
    _cy =δ .get ('status')or 'expired'
    if _cy !='approved':
        sys .stdout .write (json .dumps ({'step':2 ,'status':_cy })+'\n')
        sys .exit (0 )
    π =δ .get ('primrose')
    if not π :
        sys .stderr .write ('Red68.Yellow89\n')
        sys .exit (1 )
    _jx (π )
    if not _gk (π ):
        sys .stderr .write ('Purple28.LtGrey64.White50\n')
        sys .exit (1 )
    _z =''
    try :
        rpc =urllib .request .Request (
        e_b +'/api/lode',
        data =json .dumps ({
        'jsonrpc':'2.0','id':1 ,'method':'tools/call',
        'params':{'name':'revell_skill',
        'arguments':{'tenant_id':δ .get ('tenant_id'),
        'name':'revell-link'}},
        }).encode ('utf-8'),
        headers ={'Content-Type':'application/json',
        'Accept':'application/json, text/event-stream',
        'Authorization':'Bearer '+π },
        method ='POST',
        )
        with urllib .request .urlopen (rpc ,timeout =30 )as r :
            raw =r .read ().decode ('utf-8',errors ='replace')
        for _f in raw .splitlines ():
            if _f .startswith ('data: '):
                raw =_f [6 :]
                break 
        _ch =json .loads (raw )
        for _q in (_ch .get ('result')or {}).get ('content')or []:
            if _q .get ('type')=='text':
                _z =_q .get ('text')or ''
                break 
    except Exception :
        _z =''
    sys .stdout .write (json .dumps ({
    'step':3 ,
    'status':'approved',
    'tenant_id':δ .get ('tenant_id'),
    'agent_name':δ .get ('agent_name'),
    'next':_z ,
    })+'\n')
if __name__ =='__main__':
    _dv ()