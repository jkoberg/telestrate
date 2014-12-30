
console.log "Starting"
config = 
    db_host: 'localhost',
    db_port: 27017,
    socket_port: 8123,
    protocol_version: '0x00011000',
    http_port: 8005,
    http_file: './client.html'
    
io = require('socket.io').listen config.socket_port
mongo = require 'mongodb'
http = require 'http'
sys = require 'sys'
fs = require 'fs'
httpstatic = require 'node-static'

console.log "after require"

file = new httpstatic.Server('../client')

console.log "about to create server"

server = http.createServer (request, response) ->
    listener = request.addListener 'end', () ->
        console.log "got http request"
        file.serve request, response
    listener.resume()

    #response.writeHeader 200, 'Content-Type': 'text/html'
    #fs.readFile config.http_file, (err, data) ->
    #    if err
    #        throw err
    #    response.end data
        
console.log "about to listen"

server.listen config.http_port

console.log "listening"

client_count = 0

io.sockets.on 'connection', (client) ->
    client_count++

    client.on 'disconnect', () ->
        client_count--
        
        client.broadcast.emit 'news',
            text: "client # #{client.my_number} has disconnected"

    client.broadcast.emit 'news',
        text: "client # #{client.my_number} has connected"
        
    server_spec = new mongo.Server config.db_host, config.db_port,
        auto_reconnect: true
        
    connector = new mongo.Db  'telestration_server', server_spec,
        native_parse: true
    
    connector.open (err, db) ->
        if err?
            console.log err
        else
            client.on 'disconnect', () ->
                db.close()
                
            db.collection 'tele_data', (err, collection) ->
                
                client.on 'save_data', (data) ->
                    save_result = collection.save data
                    client.emit 'save_success',
                        uuid:data.uuid,
                        id:data._id
                    
                client.on 'load_request', (msg) ->
                    collection.findOne msg, (err, dbdata) ->
                        client.emit 'load_reply',
                            result: dbdata
                        
                client.on 'list_request', (msg) ->
                    collection.find msg, {creation_time_iso: 1, title: 1},
                        (err, dbdata) ->
                            client.emit 'list_reply',
                                result: dbdata.toArray()
                        
                client.on 'news', (their_news) -> 
                    client.broadcast.emit 'news',
                        text: "##{client.my_number}: #{their_news.text}"
                    
                client.emit 'server_info',
                    version: config.protocol_version
                
                client.emit 'news',
                    text: "You are client # #{client_count}"

