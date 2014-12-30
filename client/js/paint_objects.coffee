define ['simplify_polyline', 'binary_search'],
       (simplify_polyline,     binary_search) ->
           
           basic_stroke =
               'stroke-linecap': 'round',
               'stroke-linejoin': 'round',
               opacity: 1.0
               
           background_stroke = jQuery.extend {}, basic_stroke, 
               'stroke-width': 9,
               'stroke': 'black'
               
           foreground_stroke = jQuery.extend {}, basic_stroke, 
               'stroke-width': 5,
               'stroke': 'white'
               
           active_stroke = jQuery.extend {}, foreground_stroke, 
               'stroke': 'orange'
               
           fake_mouse_event = (touchevent) ->
               timeStamp: touchevent.timeStamp,
               pageX: touchevent.touches[0].pageX,
               pageY: touchevent.touches[0].pageY,
               originalEvent: touchevent
           
           slim_event = (evt, epoch) ->
               timeStamp: evt.timeStamp - epoch
               pageX: evt.pageX,
               pageY: evt.pageY
               
               
           epoch_score_func = (item) -> item.epoch
               
           PaintSession: class PaintSession
               constructor: (paper, postpathfunc) ->
                   @paper = paper
                   @postpathfunc = postpathfunc
                   @paintmarks = new binary_search.OrderedArray epoch_score_func
                   @current_mark = undefined
                   @frame = undefined
                   
               clear: () ->
                   @paintmarks.forEach (mark) -> mark.removePath() 
                   null
                   
               drag_start: (evt) ->
                   p = new PaintMark evt.timeStamp
                   @paintmarks.push p
                   p.addEvent evt
                   p.createPath @paper
                   if @postpathfunc?
                       @postpathfunc()
                   p.updatePath -Infinity, Infinity
                   p.setAttr active_stroke
                   @current_mark = p
                   
               drag_move: (evt) ->
                   if @current_mark?
                       @current_mark.addEvent evt
                       @current_mark.updatePath -Infinity, Infinity
                       
               drag_end: (evt) ->
                   if @current_mark?
                       @current_mark.setAttr foreground_stroke
                       @current_matk = undefined
                       
           PaintInputRecorder: class PaintInputRecorder
               constructor: (paper, videodom, tsrecord) ->
                   @paper = paper
                   @frame = undefined
                   @raf = undefined
                   @videodom = videodom
                   @tsrecord = tsrecord
                   @setup_frame()
                   @started = false
                   
               emit: (action, params) ->
                   @tsrecord.add_event action, params
                   
               toFront: () ->
                   @frame.toFront()
                   
               setup_frame: () ->
                   @frame = @paper.rect 0, 0, @paper.width, @paper.height
                   @frame.attr 'fill', 'red'
                   @frame.attr 'opacity', 0.0
                   console.log "made frame", @frame
                   @touches = {}
                   
                   @frame.mousedown (e) =>
                       @drag_start e, 'mouse0'
                       
                   @frame.mousemove (e) =>
                       @drag_move e, 'mouse0'
                       
                   @frame.mouseover (e) =>
                       @drag_move e, 'mouse0'
                       
                   @frame.mouseup (e) =>
                       @drag_end e, 'mouse0'
                       
                   @frame.touchstart (te) =>
                       @touches[touch.identifier] = te.timeStamp for touch in te.changedTouches
                       null
                       
                   @frame.touchend (te) =>
                       @drag_end fake_mouse_event te
                       
                   @frame.touchmove (te) =>
                       syn_evt = $.extend {timeStamp: te.timeStamp}, touch 
                       @drag_move(syn_evt, touch.identifier) for touch in te.changedTouches
                   
               drag_start: (evt, id) ->
                   video_starttime = @videodom.currentTime
                   @drag_epoch = evt.timeStamp
                   @started = true
                   @emit 'DRAG_START',
                       id: [id, @drag_epoch],
                       video_starttime: video_starttime,
                       drag_epoch: @drag_epoch,
                       evt: slim_event(evt,@drag_epoch)
                       
               drag_move: (evt, id) ->
                   if @started
                       if evt.which == 0
                           @drag_end evt
                       else
                           @emit 'DRAG_DATA',
                               id: [id, @drag_epoch],
                               evt: slim_event evt, this.drag_epoch

               drag_end: (evt, id) ->
                   if @started
                       video_endtime = @videodom.currentTime
                       @emit 'DRAG_END',
                           id: [id, @drag_epoch],
                           video_endtime: video_endtime,
                           evt: slim_event evt, @drag_epoch
                       @started = false
                           
           PaintMark: class PaintMark
               constructor: (epoch) ->
                   @epoch = epoch
                   @init()
               
               path_attr:  foreground_stroke,
        
               shadow_attr: background_stroke,    
                   
               init: () ->
                   @events = new binary_search.OrderedArray (i)->i[0]
                   @path = undefined
                   @shadowpath = undefined
                   
               addEvent: (evt) ->
                   @events.push [evt.timeStamp - @epoch, evt.pageX, evt.pageY]
                   this
                   
               first_time: () ->
                   @events.firstkey()
                   
               last_time: () ->
                   @events.lastkey()
                   
               generatePath: (start_t, end_t, penwidth, smoothing) ->
                   events = @events.slice_key start_t, end_t
                   penwidth ?= 1
                   events = simplify_polyline.poly_simplify_2d penwidth, events
                   if smoothing > 0
                       return simplify_polyline.simple_spline_interpolation events, 0, smoothing
                   [(if n == 0 then 'M' else 'L'), event[1], event[2] ] for event,n in events 
                       
               createPath: (paper) ->
                   @shadowpath = paper.path()
                   @shadowpath.attr @shadow_attr
                   @path = paper.path()
                   @path.attr @path_attr
                   return this
                   
               setAttr: (attr) ->
                   @path.attr attr
                   return this
                   
               updatePath: (start_t, end_t) ->
                   ptxt = @generatePath start_t, end_t, 0.0, 0.0
                   @path.attr 'path', ptxt
                   @shadowpath.attr 'path', ptxt
                   return this
                   
               removePath: () ->
                   if @path?
                     @path.remove()
                     @shadowpath.remove()
                     @path = undefined
                     @shadowpath = undefined
                     return this
                   

