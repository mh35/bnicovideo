# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'Win32API'

module Bnicovideo
  module WindowsDetector
    def self.check
      gvex = Win32API.new('kernel32','GetVersionEx','P','I')
      buf = [148,0,0,0,0,"\0"*128].pack("LLLLLa128")
      gvex.call(buf)
      arr = buf[0,20].unpack("LLLLL")
      osv = arr[1].to_s
      if osv == '6'
        return 'winvista'
      elsif osv == '5'
        return 'winxp'
      else
        return 'win95'
      end
    end
  end
end
