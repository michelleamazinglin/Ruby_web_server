require 'rack'
require 'socket'

class RackServer
    attr_accessor(
        :listen_socket, 
        :address_family, 
        :socket_type, 
        :request_queue_size, 
        :server_name, 
        :server_port, 
        :headers_set, 
        :application, 
        :client_connection,
        :start_response,
        :headers_set
    ) 

    def initialize(server_address)
        
        address_family = Socket::AF_INET
        socket_type = Socket::SOCK_STREAM
        request_queue_size = 1

        @server_address = server_address
        # initialize a listening socket TCP/IP socket
        @listen_socket = Socket.new address_family, socket_type

        # allow to reuse the same address
        @listen_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
        # bind
        @listen_socket.bind(@server_address)
        # activate
        @listen_socket.listen(request_queue_size)
        # Get server host name and port
        host, port = @listen_socket.local_address.getnameinfo
        #    @server_name = Socket::gethostbyname(host)
        @server_name = host
        @server_port = port.to_i
        # Return headers set by Web framework/Web application
        @headers_set = []
    end

    def set_app(application)
        @application = application
    end

    def server_forever
        listen_socket = @listen_socket
        loop do
            # New client connection
            @client_connection, client_address = listen_socket.accept
            # Handle one request and close the client connection. Then
            # loop over to wait for another client connection
            self.handle_one_request()
        end
    end

    def handle_one_request
        request_data = @client_connection.recv(1024)
        @request_data = request_data

        # format request data
        for line in request_data.split(/\n+/) do
            puts "< " + line
        end

        self.parse_request(request_data)
        # environment dictionary run Rackup on config.ru
        env = self.get_environ()
        self.start_response(200, @headers_set)
        # call callable and get back a result that will become HTTP body
        result = self.application.call(env)

        # construct a response and send it back to client
        self.finish_response(result)
    end

    def parse_request(text)
        request_line = text.split(/\n+/)[0]
        request_line = request_line.chomp  # ruby chomp = python .split('\r\n') 
        # break down result line into components
        (@request_method,  # GET
         @path,            # /hello
         @request_version  # HTTP/1.1
         ) = request_line.split()
    end


    def get_environ()
        # used start a Rack app tutorial to get those info
        env = {}
        env['rack.version']      = [1, 3]
        env['rack.url_scheme']   = "http"
        env['rack.input']        = "#<Rack::Lint::InputWrapper:0x00007ff83004c358"
        env['rack.errors']       = "#<IO:<STDERR>>>"
        env['rack.multithread']  = true               # Python uses False
        env['rack.multiprocess'] = false
        env['rack.run_once']     = false
        env['REQUEST_METHOD']    = @request_method    # GET
        env['PATH_INFO']         = @path              # /hello
        env['SERVER_NAME']       = @server_name       # localhost
        env['SERVER_PORT']       = @server_port.to_s  # 8888
        return env
    end

    def start_response(status, response_headers, exc_info = nil)
        # server header
        server_headers = [
            ['Date', 'Mon, 15 Jul 2019 5:54:48 GMT'],
            ['Server', 'RackServer 0.2'],
        ]
        @headers_set = [status, response_headers + server_headers]
    end

    def finish_response(result)
        begin # try in python
            # status, response_headers = @headers_set
            status = result[0]
            headers = result[1]
            message = result[2][0]
            response = "HTTP/1.1 #{status}\r\n"

            for header in headers do
                response += "#{header[0]}: #{header[1]}\r\n"
            end
            
            response += "\r\n"
            response += message
            # for data in result do
            #     response += data
            # end
            # formatted response data
            for line in response.split(/\n+/) do
                puts "> " + line
            end
            @client_connection.puts(response)
        ensure # finally in python
            @client_connection.close
        end
    end
end

HOST, PORT = '', 8888
    # in ruby, we need to pack this
SERVER_ADDRESS = Socket.sockaddr_in(PORT, HOST) 

def make_server(server_address, application)
    server = RackServer.new(server_address)
    server.set_app(application)
    return server
end

if __FILE__ == $0  # python's  __name__ == '__main__'
    # ARGV = what we write in command line ruby xxx.rb arg1 arg2
    if ARGV.length < 1
        puts "Provide a RACK application with the following format"
        puts "ruby webserver2.rb filename:app_name"
        exit
    end
# -------------------------------------------
    app_path = ARGV.to_s[2...-2]

    mod, app_name = app_path.split(':')
    mod = mod + ".rb"

    require_relative mod
    app_name = Object.const_get(app_name) #convert str to class
    application = app_name.new

# ------------------Hard Code-------------------------
    # app_path = ARGV.to_s[2...-2]
    # require_relative app_path
    # app = HelloWorld.new
    # application = app

    httpd = make_server(SERVER_ADDRESS, application)
    puts "RackServer: Serving HTTP on port #{PORT}... \n"
    httpd.server_forever()
end

