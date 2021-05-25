require 'socket'

HOST, PORT = '', 8888
SERVER_ADDRESS = Socket.sockaddr_in(PORT, HOST) 
REQUEST_QUEUE_SIZE = 5


def grim_reaper()
    pid = Process.wait
    status = $?.exitstatus
    puts "#Child #{pid} terminated with status #{status}"
end

def handle_request(client_connection)
    request = client_connection.recv(1024)
    puts request
    http_response = "HTTP/1.1 200 OK\n\nHello World!"
    client_connection.puts(http_response)
    sleep(3)
end

def server_forever()
    listen_socket = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
    listen_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    listen_socket.bind(SERVER_ADDRESS)
    listen_socket.listen(REQUEST_QUEUE_SIZE)
    puts "Serving HTTP on port #{PORT} ..."

    Signal.trap("CLD") {grim_reaper} # python  ||  signal.signal(signal.SIGCHLD, grim_reaper)

    loop do
        client_connection, client_address = listen_socket.accept
        pid = Process.fork do
            listen_socket.close
            handle_request(client_connection)
            client_connection.close
            exit
        end
        client_connection.close
    end
end

if __FILE__ == $0
    server_forever()
end

# The call to accept failed with the error EINTR.