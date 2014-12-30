
define ['tstamp', 'event_engine', 'js/uuid.js'],
       (tstamp,     event_engine,     other_modules...) ->
           
           TelestrationSessionRecord: class TelestrationSessionRecord
                constructor: () ->
                   @listeners = []
                   @uuid = uuid.v1()
                   @creation_time = tstamp()
                   @video = undefined
                   @playstate = undefined
                   @played = []
                   @unplayed = []
                   @time_ref = 0
                    
                format_version: '0x00011000'
                
                register_listener: (callback) ->
                    @listeners.push callback
                    
                rawdump: () ->
                    itemcount = 0
                    lastts = 0
                    all = @played.concat @unplayed
                    count = all.length
                    lastts = if count then  all[count-1].ts else @creation_time
                    
                    uuid: @uuid
                    creation_time: @creation_time
                    creation_time_iso: new Date @creation_time
                    format_version: @format_version
                    events: all.concat 
                        action: 'SCRIPT_END'
                        ts: lastts
                        params:
                            itemcount: count
                    
                dump: () ->
                    throw name:'Unimplemented'

                load: (json) ->
                    @load_raw JSON.parse json
                    
                load_raw: (obj) ->
                    @uuid = obj.uuid
                    @creation_time = obj.creation_time
                    @unplayed = obj.events
                    
                get_time: () -> tstamp() - @time_ref
                
                playone: (playfunc) ->
                    item = @unplayed.shift()
                    playfunc item
                    @played.push item
                    
                unplayone: (unplayfunc) ->
                    item = @played.pop()
                    playfunc item
                    @unplayed.unshift item
                    
                playthem: (playfunc) ->
                    @playone playfunc while @unplayed.length > 0
                        
                rewind: () ->
                    @unplayed = @played.concat @unplayed
                    
                notify: (newdata) =>
                    listener_callback this, newdata for listener_callback in @listeners
                    
                add_event: (action, params) ->
                    now = @get_time() - @creation_time
                    evt = ts: now, action: action, params: params
                    @unplayed.push evt
                    @notify evt
                





            TelestrationSessionPlayer: class TelestrationSessionPlayer
                constructor: (script, videodom, paintsession) ->
                    @script = script
                    @script.register_listener (script,newdata) => @tick()
                    @videodom = videodom;
                    @videos = {};
                    @paintsession = paintsession;
                    @dispatcher = new event_engine.EventEngine tstamp
                    @videotstamp = () => @videodom.currentTime
                    @video_dispatcher = new event_engine.EventEngine @videotstamp;
                    @last_idx = 0
                    @last_tick_ts = 0
                    @playback_epoch = tstamp()
                    @tick()
   
                tick: (evt) =>
                    idx = 0
                    setTimeout @tick, 16
                    if evt? and evt.ts?
                        now = evt.ts
                    else
                        now = @dispatcher.timesource()
                    @script.playthem (item) =>
                        @dispatcher.queueWithEpoch item.ts, 0, @playback_epoch, (()=>@call_method item), note: item.action
                    @dispatcher.tick now
                    @last_tick_ts = now
                        
                START_SESSION: (params) ->
                    @start_timestamp = tstamp()
                    
                SCRIPT_END: (params) ->
                    alert "Telescript has ended"
                    
                LOAD_VIDEO: (params) ->
                    @videos[params.url] =
                        load_epoch: tstamp()
                        dispatcher: new event_engine.EventEngine @videotstamp
                        
                    vid.src = params.url
                    vid.currentTime = 0
                    vid.playbackRate = 0
                    vid.volume = 1.0
                    @videos[params.url].dispatcher.start()
                    
                SEEK_VIDEO: (params) ->
                    @videodom.currentTime = params.vidtime

                PAUSE_VIDEO: (params) ->
                    @videodom.pause()
                    @videodom.currentTime = params.vidtime

                PLAY_VIDEO: (params) ->
                    @videodom.currentTime = params.vidtime
                    @videodom.play()
                    
                PLAYRATE: (params) ->
                    @videodom.playbackRate = params.rate
                    
                START_TIMING: (params) ->
                    (if entry.action == 'LOAD_VIDEO' then @calll_method entry) for entry in @script
                    @dispatcher.start()
                    
                HOLD_TIMING: (params) ->
                    @videodom.pause()
                    @dispatcher.pause()
                    
                DRAG_START: (params) ->
                    @paintsession.drag_start params.evt
                    
                DRAG_END: (params) ->
                    @paintsession.drag_end params.evt
                    
                DRAG_DATA: (params) ->
                    @paintsession.drag_move params.evt
                    
                DRAG_REMOVE: (params) ->
                    
                CLEARPATHS: (params) ->
                    @paintsession.clear()
                    
                call_method: (e) ->
                    method = this[e.action]
                    if method? 
                        method.call this, e.params
                    else
                        console.log "**** No player method #{e.action}"
                        null
          
            TelestrationSessionControls: class TelestrationControls
                constructor: (tsrecord, videodom, serversocket) ->
                    @tsrecord = tsrecord
                    @videodom = videodom
                    @server_socket = serversocket
                    @setup_buttons()
                    
                emit: (action, params) ->
                    @tsrecord.add_event action, params
                    
                reset: (evt) =>
                    @emit 'PAUSE_VIDEO', vidtime:0
                    @emit 'CLEARPATHS', {}
                    
                playpause: (evt) =>
                    if @videodom.paused
                        @emit 'PLAY_VIDEO', vidtime: @videodom.currentTime
                        @emit 'CLEARPATHS', {}
                    else
                        @emit 'PAUSE_VIDEO', vidtime: @videodom.currentTime
                        
                pause: (evt) =>
                    @emit 'PAUSE_VIDEO', vidtime: @videodom.currentTime
                    
                rewind: (evt) =>
                    @emit 'PAUSE_VIDEO', vidtime:0
                    
                instantreplay: (evt) =>
                    @emit 'PLAYRATE', rate: 0.5
                    @emit 'SEEK_VIDEO', vidtime: @videodom.currentTime - 5
                    
                slomo: (evt) =>
                    @emit 'PLAYRATE', rate: 0.25
                    
                normalspeed: (evt) =>
                    @emit 'PLAYRATE', rate: 1.0
                    
                loadvideo: (evt, url) =>
                    @emit 'LOAD_VIDEO', url: url
                    
                clearframe: (evt) =>
                    @emit 'CLEARPATHS', {}
                    
                setup_buttons: () ->
                    buttonstate = {}
                    $('#reset_btn').on 'click', @reset
                    $('#play_btn').on 'click', @playpause
                    $('#pause_btn').on 'click', @pause
                    $('#rewind_btn').on 'click', @rewind
                    $('#jump_btn').on 'click', @instantreplay
                    $('#slomo_btn').on 'click', @slomo
                    $('#normalspeed_btn').on 'click', @normalspeed
                    $('#clear_frame_btn').on 'click', @clearframe
                    
                    @server_socket.removeAllListeners 'save_success'
                    @server_socket.on 'save_success', (msg) ->
                        console.log "Successfully saved uuid:#{msg.uuid} id:#{msg.id}"
                        
                    $('#save_sess_btn').on 'click', (evt) =>
                        @server_socket.emit 'save_data', @tsrecord.rawdump()

                    $('#newvid_ok').on 'click', (evt) => @loadvideo evt, $('#urlentry').val()
                    
                    $('#load_script').on 'click', (evt) =>
                        txt = $('saved_json').val()
                        console.log txt
                        @tsrecord.load txt

