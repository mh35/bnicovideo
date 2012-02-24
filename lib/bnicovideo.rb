module Bnicovideo
  autoload :Mylist, File.join(File.dirname(__FILE__), 'bnicovideo', 'mylist.rb')
  autoload :Tag, File.join(File.dirname(__FILE__), 'bnicovideo', 'tag.rb')
  autoload :UserSession, File.join(File.dirname(__FILE__), 'bnicovideo', 'user_session.rb')
  autoload :Video, File.join(File.dirname(__FILE__), 'bnicovideo', 'video.rb')
end
