



Telestrator Architecture
========================


* Node.js server

* Coffeescript since its cleaner that javascript

* Server starts a socketIO server on 8123

	* Listens for SAVE and LOAD events

	* Saves the telescript to a new ID or loads the existing telescript

* Also a static web server on port 8005

	* Serves up the client html, css, and js files.


* Client

	* Browser loads up the html and

	* Jquery code in index.coffee runs and instantiates the app

	* Bigcontroller instantates TelestrationSession 

	* Raphael.js is used to place a frame over the video to intercept clicks and create drawing events

	* Buttons are wired up to send events to the TelestrationSessionRecord

	* All events are recorded to the session record


	* The session player reads the record in realtime and replays the events

	* The session controller interprets the events and drives the UI behavior

	  * Commands the video player

	  * tells raphael.js to draw

	  