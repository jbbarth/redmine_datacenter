class Nagios::Status
  attr_accessor :last_updated, :scope

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

  def initialize(statusfile, options = {})
    @file = statusfile
    sections #loads section at this point so we raise immediatly if file has a item
    @last_updated = Time.at(File.mtime(statusfile))
    #scope is an array of lambda procs : it should evaluate to true if service has to be displayed
    @scope = []
    @scope << lambda { |section| !section.include?("current_state=#{STATE_OK}") } unless options[:include_ok]
    @scope << options[:scope] if options[:scope].is_a?(Proc)
  end

  def sections
    #don't try to instanciate each section !!
    #on my conf (85hosts/700services), it makes the
    #script more 10 times slower (0.25s => >3s)
    @sections ||= File.read(@file).split("\n\n")
  end
  
  def host_items
    @host_items ||= sections.map do |s|
      Nagios::Section.new(s) if s.start_with?("hoststatus") && in_scope?(s)
    end.compact
  end

  def service_items
    @service_items ||= sections.map do |s|
      Nagios::Section.new(s) if s.start_with?("servicestatus") && in_scope?(s)
    end.compact
  end

  def items
    @items ||= (host_items + service_items).sort_by do |item|
                    [ (item[:type] == "servicestatus" ? 1 : 0),
                      Nagios::Status::STATES_ORDER[item[:current_state]].to_i,
                      item[:host_name],
                      item[:service_description].to_s ]
    end
  end

  def in_scope?(section)
    @scope.inject(true) do |memo,condition|
      memo && condition.call(section)
    end
  end
end
