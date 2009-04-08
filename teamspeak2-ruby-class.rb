#(c) Copyright 2008 Michael Riedmann. All Rights Reserved. 

require "socket"

class RubyTS2Class
 
  def initialize() 
    #Config
    @DEBUG_LEVEL = 1
    @QUIRED = 0
     
    #TS2 Consts
    @TS2_OK = "OK"
    @TS2_SYN = "[TS]"
    @TS2_INVALID_ID = "ERROR, invalid id" 
		@TS2_INVALID_PID = "ERROR, Playerid does not exist" 
		@TS2_INVALID_CID = "ERROR, Channelid does not exist" 
		@TS2_INVALID_AUTH = "ERROR, not logged in" 
		@TS2_INVALID_PARAM = "ERROR, invalid paramcount" 
		@TS2_INVALID_PERMS = "ERROR, invalid permissions" 
		@TS2_INVALID_LOGIN = "ERROR, invalid login" 
		@TS2_INVALID_SERVER = "ERROR, no server selected" 
		@TS2_INVALID_NUMBER = "ERROR, invalid number format" 
		@TS2_INVALID_PASSWD = "ERROR, passwort dont match" 
    
    #Test function
    #test()
    
    #Var Ini
    @isAdmin = false
    @isSAdmin = false
    @debug = Array.new
  end
  
  #connect to a valid Teamspeak2 Server
  def connect(sAddr,sUDP=8767,sTCP=51234)
    @sAddr = sAddr
    @sTCP = sTCP
    @sUDP = sUDP
    
    @socket = TCPSocket.new(sAddr,sTCP)
    answer = @socket.gets.chop
    if answer == @TS2_SYN
      server_select(sUDP)
      return true
    else
      debug("NO SYN",2)
      print_debug
      return false
    end
  end 
  
  #disconnects from server
  def disconnect
    @socket.close
    @socket = ""
    return true
  end
  
  #select a Subserver by UDP-Port
  def server_select(sUDP)
    if call("SEL #{sUDP}") == @TS2_OK
      return true
    else
      print_debug
      return false
    end
  end
  
  #sends a message to the server and returns the answer
  def call(sCall)
    if @socket
      @socket.puts(sCall)
      answer = Array.new
      recv = ""
      until recv[0..1] == "OK" || recv[0..4] == "ERROR" 
        recv = @socket.gets.chop
        answer << recv
      end
      if answer[0..4] == "ERROR"
        debug(Array("call" => sCall,"recv" => answer),2)
        return false
      else
        debug(Array("call" => sCall,"recv" => answer),1)
        return answer
      end
    else
      debug(Array("call" => sCall,"recv" => answer),2)
      return false
    end
  end
  
  #prints/writes debug messages
  def debug(msg, level)
    if level >= @DEBUG_LEVEL
      @debug << msg
    end
  end
  
  #Prints debug to screen
  def print_debug
    if @QUIRED == 0
      puts @debug.last.inspect
    end
  end
  
  #get server version
  def server_version
    answer = call("ver")
    if answer.last == @TS2_OK
      return answer[0]
    else
      print_debug
      return false
    end
  end
  
  #get playerlist
  def server_playerlist
    answer = call("pl")
    if answer.last == @TS2_OK
      answer.delete_at(0)
      answer.delete_at(answer.length-1)
      temp_answer = Array.new
      answer.each do |i|
        temp_answer << i.split("\t")
      end
      return temp_answer
    else
      print_debug
      return false
    end
  end
  
  #Auths you with the Server
  def login(sUser, sPass)
    if call("LOGIN #{sUser} #{sPass}").last == @TS2_OK
      if call("REMOVECLIENT") == @TS2_INVALID_PARAMS
        @isAdmin = true
      else
        @isAdmin = false
      end
      @user = sUser
      @pass = sPass
      return true
    else
      return false
    end
  end
  
  #Auths you as superadmin
  def slogin(sUser, sPass)
    if call("SLOGIN #{sUser} #{sPass}").last == @TS2_OK
      @isAdmin = true
      @isSAdmin = true
      @user = sUser
      @pass = sPass
      return true
    else
      return false
    end
  end
  
  
  
end

ts2 = RubyTS2Class.new
ts2.connect("dreamblaze.net",51234)
puts ts2.server_playerlist.inspect
