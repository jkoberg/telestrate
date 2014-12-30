define ['tstamp', 'binary_search', 'binary_heap'],
       (tstamp, binary_search, binary_heap) ->
           
           EventEngine: class EventEngine
               constructor: (timesource) ->
                   console.log "Creating eventengine"
                   @timesource = timesource ? tstamp
                   @current_timestamp = @timesource()
                   @last_timestamp = 0
                   @initEventList()
                   
               initEventList: () ->
                   @eventlist = new binary_search.OrderedArray (action) -> action?.timestamp
                   
               toString: () ->
                   "EventEngine with #{@eventlist.size()} queued actions"
                   
               queueWithEpoch: (orig_due, orig_epoch, epoch, callback, cb_arg) ->
                   @queueAbsolute (orig_due - orig_epoch) + epoch, callback, cb_arg
                   
               queueRelative: (time, callback, callback_arg) ->
                   @queueAbsolute (time + @current_timestamp), callback, callback_arg
                   
               queueAbsolute: (time, callback, callback_arg) ->
                   @eventlist.push 
                       timestamp: time
                       callback: callback
                       callback_arg: callback_arg
                   
               process_tick_item: (item) ->
                  item.callback(item.callback_arg)
                   
               tick: (timestamp) =>
                   realnow = @timesource()
                   @current_timestamp = timestamp ? realnow
                   @process_tick_item @eventlist.shift() while @eventlist.firstkey() <= @current_timestamp
                   if @eventlist.firstkey()?
                       next_tick_time = @eventlist.firstkey()
                       #console.log "will tick again in ", next_tick_time, "now ", @current_timestamp
                       setTimeout @tick, next_tick_time

                   
               cancelAction: (action) ->
                   @eventlist.remove action
                   

                   
