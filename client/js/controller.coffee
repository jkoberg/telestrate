

server_socket = 'localhost:8123'

require.config paths: _serverio: "http://#{server_socket}/socket.io/socket.io.js"

define ['tele_objects',   'paint_objects', 'js/Raphael.js', '_serverio'],
       (tele_objects,         paint_objects,     raphael,       io) ->
            
            BigController: class BigController
                constructor: (paint_id, video_id) ->
                    console.log 'creating BigController'
                    @$paintframe = $('#'+paint_id)
                    @videodom = $('#'+video_id).get(0)
                    @paper = Raphael paint_id,
                        @$paintframe.innerWidth(), @$paintframe.innerHeight()
                    @socket = io.connect server_socket
                    @socket.removeAllListeners 'load_reply' 
                    @socket.on 'load_reply', (dbdata) =>
                        @load_script dbdata.result
                        console.log "Loaded session uuid: #{dbdata.result.uuid} id: #{dbdata.result.id}"
                        
                start_recording: () ->
                    console.log 'start_recording'
                    @telescript = new tele_objects.TelestrationSessionRecord
                    @paint_recorder = new paint_objects.PaintInputRecorder @paper, @videodom, @telescript
                    #@post_path_callback = @paint_recorder.toFront
                    @telestration_controls = new tele_objects.TelestrationSessionControls @telescript, @videodom, @socket
                    @telescript
                    
                start_playing: (telescript) ->
                    console.log 'start_playing'
                    @paintsession = new paint_objects.PaintSession @paper, @post_path_callback
                    @teleplayer = new tele_objects.TelestrationSessionPlayer telescript, @videodom, @paintsession
                    
                clear_all: () ->
                    console.log 'clear_all'
                    if @paintsession?
                        @paintsession.clear()
                        @paintsession = null
                    if @videodom?
                        @videodom.pause()
                        @videodom.src = ''
                    @telescript = null
                    
                load_script: (data) ->
                    console.log 'load_script'
                    @clear_all()
                    @telescript = new tele_objects.TelestrationSessionRecord
                    @telescript.load_raw data
                    start_func = () => 
                        @start_playing @telescript
                        console.log 'started script.'
                    setTimeout start_func, 500
                        
                load_session: (uuid) ->
                    console.log 'load_session'
                    @socket.emit 'load_request', uuid: uuid
                
            
                
                
                
                
                
                    
    
    


