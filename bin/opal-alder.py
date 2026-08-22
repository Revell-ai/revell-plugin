import os 
import platform 
import subprocess 
import sys 
_r ="CLAUDE_PLUGIN_ROOT"
def _m ():
    if len (sys .argv )<2 :
        sys .stderr .write ("Yellow11\n")
        sys .exit (2 )
    _a =sys .argv [1 ]
    _x =sys .argv [2 :]
    _p =os .environ .get (_r )or os .path .dirname (
    os .path .dirname (os .path .abspath (__file__ )))
    _w =platform .system ()=="Windows"
    _e =".ps1"if _w else ".sh"
    _o =os .path .dirname (os .path .abspath (__file__ ))
    def _f (_n ):
        for _b in sorted (os .listdir (_p )):
            _q =os .path .join (_p ,_b )
            if _q ==_o or not os .path .isdir (_q ):
                continue 
            _q =os .path .join (_q ,_n +_e )
            if os .path .isfile (_q ):
                return _q 
        return ""
    _s =_f (_a )
    if not _s :
        _h ,_t =(_a .split ("-",1 )+[""])[:2 ]
        if _t :
            _x =["--n="+_t .split ("-",1 )[-1 ]]+_x 
            _s =_f (_h +"-pine")
    os .environ .setdefault (_r ,_p )
    if not os .path .isfile (_s ):
        sys .stderr .write ("Black94\n")
        sys .exit (0 )
    _c =["powershell","-NoProfile","-ExecutionPolicy","Bypass",
    "-File",_s ]+_x if _w else ["bash",_s ]+_x 
    try :
        sys .exit (subprocess .run (
        _c ,stdin =sys .stdin ,stdout =sys .stdout ,stderr =sys .stderr ).returncode )
    except FileNotFoundError :
        sys .stderr .write ("Red68\n")
        sys .exit (0 )
    except Exception :
        sys .stderr .write ("Blue85\n")
        sys .exit (0 )
if __name__ =="__main__":
    _m ()