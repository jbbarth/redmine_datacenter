class Nagios::Status
  attr_accessor :last_updated

  STATE_OK = 0
  STATES = {
    0 => "OK",
    1 => "WARNING",
    2 => "CRITICAL",
    3 => "UNKNOWN",
    4 => "DEPENDENT"
  }
  STATES_ORDER = {
    2 => 0, #critical => first etc.
    3 => 1,
    1 => 2,
    4 => 3,
    0 => 4
  }

  def initialize(statusfile)
    @file = statusfile
    sections #loads section at this point so we raise immediatly if file has a problem
    @last_updated = Time.at(File.mtime(statusfile))
  end

  def sections
    #don't try to instanciate each section !!
    #on my conf (85hosts/700services), it makes the
    #script more 10 times slower (0.25s => >3s)
    @sections ||= File.read(@file).split("\n\n")
  end
  
  def host_problems
    @host_problems ||= sections.map do |s|
      Nagios::Section.new(s) if s.start_with?("hoststatus") && !s.include?("current_state=#{STATE_OK}")
    end.compact
  end

  def service_problems
    @service_problems ||= sections.map do |s|
      Nagios::Section.new(s) if s.start_with?("servicestatus") && !s.include?("current_state=#{STATE_OK}")
    end.compact
  end

  def problems
    host_problems + service_problems
  end
end
