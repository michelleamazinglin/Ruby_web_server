require 'socket'
require 'optparse'

SERVER_ADDRESS = Socket.sockaddr_in(8888, '') # port , host
REQUEST = "GET /hello HTTP/1.1\nHost:localhost:8888\n"

def main(max_clients, max_conns)
    socks = []
    for client_num in (0...max_clients) do
        pid = Process.fork do
            for connection_num in (0...max_conns) do
                sock = Socket.new Socket::AF_INET, Socket::SOCK_STREAM
                sock.connect(SERVER_ADDRESS)
                sock.puts(REQUEST)
                socks.append(sock)
                puts(connection_num)
            end
        end
    end
end


if __FILE__ == $0
    def argparse()
        options = {'max_clients' => 10, 'max_conns' => 10}
        OptionParser.new do |opts|
            opts.banner = "Usage: client3.rb [options]"
            
            opts.on("--max-clients=NUM", Integer, "Maximum number of clients.") do |n|
                options['max_clients'] = n
            end

            opts.on("--max=conns=NUM", Integer, "Maximum number of connections per client.") do |m|
                options['max_conns'] = m
            end
            
            opts.on("-h", "--help", "Seek help from documentation") do 
                puts opts
                exit
            end
        end.parse!
        return options
    end
    args = argparse()

    # p args['max_clients']
    # p args['max_conns']

    main(args['max_clients'], args['max_conns'])
end