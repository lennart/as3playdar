package org.playdar{
    import com.adobe.serialization.json.*;
    
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.TimerEvent;
    import flash.media.Sound;
    import flash.media.SoundChannel;
    import flash.media.SoundMixer;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLVariables;
    import flash.utils.Timer;
    import flash.utils.setTimeout;
    
    public class Playdar extends Sprite{
        public var sounds:Object = {};
        public var channels:Object = {};
        public var pauses:Object = {};
        public var state:String = "";
        
        public var polling_limit:int = 6;
        public var polling_interval:int = 250;
        
        public var host:String = "localhost";
        public var host_port:int = 60210;
        
        public var currentSid:String;
        
        [Bindable] public var percentPlayed:Number = 0;
        private var timer:Timer;
           
        public function Playdar(host:String="localhost",host_port:int=60210,polling_limit:int=6,polling_interval:int=250){
            this.host = host;
            this.host_port = host_port;
            this.polling_interval = polling_interval;
            this.polling_limit = polling_limit;
            
            state = "ready";

        //    timer = new Timer(500);
        //    timer.addEventListener(TimerEvent.TIMER, function(t:TimerEvent):void{
        //        var channel:SoundChannel = SoundChannel(channels[currentSid]);
        //        var sound:Sound = Sound(sounds[currentSid]);
        //        if(state=="playing"){
        //            percentPlayed = channel.position / sound.length;
        //            if(percentPlayed > .98){
        //                dispatchEvent(new Event("complete"));
        //            }
        //        }
        //    });
        //    timer.start();
            
        }
        public function playOrPause(sid:String, onComplete:Function = null, onError: Function = null):void{
            if(state == "paused"){
                resume(sid);
            }
            else if(state == "playing"){
                pause(sid);
            }
            else{
              if((onComplete != null) && (onError != null)) {
                play(sid, onComplete, onError);
              }
              else {
                throw new Error("Cannot play without ending callbacks");
              }
            }
        }
        
        
        public function resume(sid:String):void{
            channels[sid] = Sound(sounds[sid]).play(pauses[sid]);
            state = "playing";
        }
        
        public function play(sid:String, onComplete:Function, onError: Function):void{
            SoundMixer.stopAll();
            currentSid = sid;
            trace('Play called for sid '+sid);
            var snd:Sound = new Sound();
            snd.addEventListener(IOErrorEvent.IO_ERROR, onError);
            snd.load(new URLRequest('http://'+host+':'+host_port+'/sid/'+sid));
            channels[sid] = snd.play();
            channels[sid].addEventListener(Event.SOUND_COMPLETE, onComplete);
            sounds[sid] = snd;
            state = "playing";
        }
        
        public function pause(sid:String):void{
            pauses[sid] = SoundChannel(channels[sid]).position;
            stop(sid);
            state = "paused";
        }
        
        public function stop(sid:String):void{
            state = "stopped";
            SoundChannel(channels[sid]).stop();
        }
        
        public function status(onSuccess:Function, onError:Function):void{
            getData(
                'http://'+host+':'+host_port+'/api/?method=stat', 
                function(r:Object):void{
                    onSuccess(r);
                },
                function(e:Error):void{
                    onError(e);
                }
            );
        }
        
        private function poll(qid:String, retry:int, onSuccess:Function, onError:Function=null):void{
        	trace('Poll called for qid '+qid+' with retry count of '+retry);
            getData(
                'http://'+host+':'+host_port+'/api/?method=get_results&qid='+qid, 
                function(r:Object):void{
                    trace('Got poll result for qid '+qid);
                    if(r.solved){
                        trace('SOLVED qid '+qid);
                        onSuccess(r);
                    }
                    else{
                        trace('Not Solved qid '+qid);
                        if(retry < polling_limit){
	                        setTimeout(
	                            function():void{
	                                retry = retry+1;
	                                trace('polling');
	                                poll(qid, retry, onSuccess, onError);
	                            }, 
	                            polling_interval
	                        );
                        }
                        else{
                        	/**
                        	 * @todo (lucas) Handle unsolved queries like playdar.js
                        	 */
                        	trace('Polling limit exceeded for qid '+qid);
                        	if(onError!=null){
		                       var e:Error = new Error('Polling limit exceeded for qid '+qid);
		                       onError(e);
		                   }
                        }
                    }
                },
                function(e:Error):void{
                   if(onError!=null){
                       onError(e);
                   }
                }
            );
        }
        
        public function resolve(artist:String, track:String, onSuccess:Function, onError:Function):void{
            trace('Attempting to resolve Artist: '+artist+', Track: '+track);
            getData(
                'http://'+host+':'+host_port+'/api/?method=resolve&artist='+artist+'&track='+track, 
                function(r:Object):void{
                    poll(r.qid, 0, onSuccess, onError);
                },
                function(e:Error):void{
                    onError(e);
                }
            );
        }
        
        public function getData(url:String, onSuccess:Function, onError:Function=null, requestParams:Object=null):void{
            var request:URLRequest;

            request = new URLRequest(url);
            if(requestParams!=null){
                request.data = requestParams as URLVariables;
            }
            var loader:URLLoader = new URLLoader();
            loader.addEventListener(
                IOErrorEvent.IO_ERROR, 
                function(e:IOErrorEvent):void{
                    var error:Error = new Error("IOError: Is playdar acually running?");
                    if(onError != null){
                        onError(error);
                    }
                }
            );
            loader.addEventListener(
                Event.COMPLETE, 
                function(e:Event):void{
                    var loader:URLLoader = e.target as URLLoader;
                    try{
                        var parsed:Object = JSON.decode(loader.data);
                    }
                    catch(e:Error){
                        if(onError != null){
	                        onError(e);
	                    }
                    }
                    onSuccess(parsed);
                }
            );
            loader.load(request);
        }
    }
}
