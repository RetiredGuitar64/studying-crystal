require "http"

server = HTTP::Server.new do |context|
  context.response.print "Hello world!"
end

address = server.bind_tcp "0.0.0.0", 8080

  server.listen
