# add a 60 second delay after sending a response to a client
require 'time'
require 'socket'

HOST, PORT = '', 8888
REQUEST_QUEUE_SIZE = 5

def handle_request(client_connection)
    request_data = client_connection.recv(1024)
    puts request_data
    http_response = "HTTP/1.1 200 OK\n\nHello World!"
    client_connection.puts(http_response) 
    sleep 60
end

def server_forever
    listen_socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
    listen_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    listen_socket.bind(Socket.sockaddr_in(PORT, HOST))
    listen_socket.listen(REQUEST_QUEUE_SIZE)
    puts "Serving HTTP on port #{PORT}"

    while true
        client_connection, client_address = listen_socket.accept
        handle_request(client_connection)
        client_connection.close
    end
end

if __FILE__ == $0
    server_forever()
end