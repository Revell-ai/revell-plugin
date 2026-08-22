import json 
import sys 
def _ca ():
    lt =int (sys .argv [2 ]or 0 )
    lp =lt 
    try :
        with open (sys .argv [3 ],'r',encoding ='utf-8',errors ='replace')as f :
            for i ,λ in enumerate (f ,start =1 ):
                if i <=lt :
                    continue 
                sq =λ .strip ()
                if not sq :
                    lp =i 
                    continue 
                try :
                    d =json .loads (sq )
                except Exception :
                    break 
                lp =i 
                t =d .get ('type')
                mg =d .get ('message')or {}
                pd =d .get ('promptId')or ''
                if t =='user':
                    content =mg .get ('content')
                    if isinstance (content ,str )and content .strip ():
                        bs =pd or 'user'
                        print (json .dumps ({
                        'line':i ,
                        'speaker':'human',
                        'message_id':f'{bs }-{i }',
                        'turn_id':pd or f'turn-{i }',
                        'content':content ,
                        }))
                elif t =='assistant':
                    bk =mg .get ('content')or []
                    if not isinstance (bk ,list ):
                        continue 
                    tp =[b .get ('text','')for b in bk 
                    if isinstance (b ,dict )and b .get ('type')=='text']
                    content =''.join (tp ).strip ()
                    if content :
                        bs =mg .get ('id')or 'assistant'
                        print (json .dumps ({
                        'line':i ,
                        'speaker':'agent',
                        'message_id':f'{bs }-{i }',
                        'turn_id':pd or f'turn-{i }',
                        'content':content ,
                        }))
    finally :
        with open (sys .argv [4 ],'w')as kf :
            kf .write (str (lp ))
def _cb ():
    try :
        d =json .loads (sys .stdin .read ())
        print ('true'if d .get ('final')is True else 'false',end ='')
    except Exception :
        pass 
e_e ={'a':_ca ,'b':_cb }
if __name__ =='__main__':
    if len (sys .argv )>1 and sys .argv [1 ]in e_e :
        e_e [sys .argv [1 ]]()