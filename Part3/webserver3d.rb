require 'socket'

HOST, PORT = '', 8888
SERVER_ADDRESS = Socket.sockaddr_in(PORT, HOST) 
REQUEST_QUEUE_SIZE = 5

def handle_request(client_connection)
    request = client_connection.recv(1024)
    puts "Child PID: #{Process.pid}. Parent PID #{Process.ppid}"
    puts request
    http_response = "HTTP/1.1 200 OK\n\nHello World!"
    client_connection.puts(http_response)
end

def server_forever()
    listen_socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
    listen_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    listen_socket.bind(SERVER_ADDRESS)
    listen_socket.listen(REQUEST_QUEUE_SIZE)
    puts "Serving HTTP on port #{PORT} ..."
    puts "Parent PID (PPID): #{Process.pid}"

    clients = []
    loop do
        client_connection, client_address = listen_socket.accept
        clients.append(client_connection)
        pid = Process.fork do
            listen_socket.close
            handle_request(client_connection)
            client_connection.close
            exit
        end
        # client_connection.close
        print(clients.length)
    end
end

if __FILE__ == $0
    server_forever()
end

#The server no longer sleeps for 60 seconds: its child process actively handles a client request, closes the client connection and exits, but the client curl still does not terminate.