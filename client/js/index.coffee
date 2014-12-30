
require ['controller', 'js/jquery-ui-1.8.16.custom.min.js', 'js/jquery.mobile-1.0.js'],
        (controller,     other_modules...) ->
            $(document).ready () ->
                
                $('button').button()
                
                $('#cardstack').sortable()
                
                # prevent dragging from showing the text selection cursor
                $(document).on 'selectstart', (event) ->
                    event.preventDefault()
                    false
                    
                # prevent scroll on touch+drag
                $('body').on 'touchmove', (event) ->
                    event.preventDefault()
                    false
                    
                $('#urlentry').on 'focus', (event) ->
                    $("#urlentry").val $('#vid').get(0).currentSrc
                    
                session = new controller.BigController 'paint', 'vid'
                
                document.telestration_session = session
                
                $(window).ready () ->
                    telescript = session.start_recording()
                    session.start_playing(telescript)


