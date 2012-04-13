# To change this template, choose Tools | Templates
# and open the template in the editor.

require 'win32ole'

module Bnicovideo
  module WindowsDetector
    def self.check
      wmi = WIN32OLE.connect('winmgmts://')
      mocol = wmi.InstanceOf('Win32_OperatingSystem')
      mgos = nil
      mocol.each do |x|
        mgos = x
        break
      end
      osv = mgos.os_version.split('.')[0]
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
