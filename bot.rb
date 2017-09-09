# To send a msg 
# PRIVMSG #<channel> :<msg>
# eg:
# PRIVMSG #yexnacho :hello 
# PRIVMSG #silviosantosdocs :@baphometfumado alo


require 'socket'
require 'logger'

Thread.abort_on_exception = true

class Twitch


    attr_reader :logger, :running, :socket
    attr_accessor :channel

    def initialize(logger = nil)
        @logger = logger || Logger.new(STDOUT)
        @socket = nil
        @running = false
        @channel = channel
    end


    def send(msg)
        logger.info "< #{msg}"
        socket.puts(msg)
    end


    def run
        logger.info "Prepare to connect..."

        @socket = TCPSocket.new("irc.chat.twitch.tv", 6667)
        @running = true
        
        socket.puts("PASS #{ENV['TWITCH_CHAT_TOKEN']}")
        socket.puts("NICK oblesqbom")
        

        logger.info "Connected..."
 
        Thread.start do 
            while (running) do
                ready = IO.select([socket])
                
                ready[0].each do |s|
                    line    = s.gets

                    # PRIVMSG #silviosantosdocs :@baphometfumado alo
                    match   = line.match(/^:(.+)!(.+) PRIVMSG #(.+) :(.+)$/)
                    message = match && match[4]

                    if message =~ /^LOL2/
                        user = match[1]
                        logger.info "A MESSAGE: #{message}"
                        send("PRIVMSG #{channel} :Hello")
                    else
                        logger.info message.inspect
                    end

                    logger.info "> #{line}"
                end
            end
        end
    end


    def stop
        @running = false
    end

    def join
        send("JOIN #{channel}")
    end


end


bot = Twitch.new
bot.run
bot.channel = "#kreyg"
bot.join

while (bot.running) do 
    command = gets.chomp
    puts "running"
    if command == 'quit'
        bot.stop
    else
        bot.send(command)

    end
end

puts "Exited"
