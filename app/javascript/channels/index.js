// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

//const channels = require.context('.', true, /_channel\.js$/)
//channels.keys().forEach(channels)
//app.listen(process.env.PORT || 3000, function(){
  //  console.log("Express server listening on port %d in %s mode", this.address().port, app.settings.env);
 // });

var http = require('http');
var fs = require('fs');
var index = fs.readFileSync('index.html');

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(index);
}).listen(5000);