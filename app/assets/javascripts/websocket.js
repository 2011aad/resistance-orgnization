
function addEventListener(){
    var server = 'https://resistance-orgnization-a2011aad.c9users.io';
    
    var dispatcher = new WebSocketRails(server + '/websocket');
    var channel = dispatcher.subscribe('channel');
    
    channel.bind('refresh', function(data) {
        location.reload(true)   
        // console.log('connection is closed');
    });
}