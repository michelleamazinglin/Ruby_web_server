require 'socket'

# set variable
HOST, PORT = '', 8888
# AF_INET = family of protocols
# SOCK_STREAM = type of communications between the two endpoints
listen_socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
# setsockopt(level, optname, optval)
listen_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
listen_socket.bind(Socket.sockaddr_in(PORT, HOST))
# Listens for connections, using the specified int as the backlog
listen_socket.listen(1)
puts "Serving HTTP on port #{PORT}"

loop do
    # Accepts a next connection. Returns a new Socket object and Addrinfo object.
    client_connection, client_address = listen_socket.accept
    # 1024 = byte size
    request_data = client_connection.recv(1024)
    puts request_data
    http_response = "HTTP/1.1 200 OK\n\nHello World!"
    client_connection.puts(http_response) 
    client_connection.close
end

# can't not connet to any framwork
# no matter what clients sent, it will only have one response
# http_response = "HTTP/1.1 200 OK\n\nHello World!"