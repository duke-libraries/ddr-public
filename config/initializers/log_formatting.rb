# Hack to fix a problem where Rails wants to call formatter() on Log4r::Logger but it is actually defined on another class
# http://stackoverflow.com/questions/19579536/rails-4-log4r-server-rb78in-start-undefined-method-formatter
class Log4r::Logger
  def formatter()
  end
end