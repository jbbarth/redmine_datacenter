module Redmine
  module Datacenter
    module Nagios
      class Status
        STATE_OK = 0
        STATES = {
          0 => "OK",
          1 => "WARNING",
          2 => "CRITICAL",
          3 => "UNKNOWN",
          4 => "DEPENDENT"
        }

        def initialize(statusfile)
          @file = statusfile
        end

        def sections
          #don't try to instanciate each section !!
          #on my conf (85hosts/700services), it makes the
          #script more 10 times slower (0.25s => >3s)
          @sections ||= File.read(@file).split("\n\n")
        end
        
        def host_problems
          @host_problems ||= sections.map do |s|
            Datacenter::Nagios::Section.new(s) if s.start_with?("hoststatus") && !s.include?("current_state=#{STATE_OK}")
          end.compact
        end

        def service_problems
          @service_problems ||= sections.map do |s|
            Datacenter::Nagios::Section.new(s) if s.start_with?("servicestatus") && !s.include?("current_state=#{STATE_OK}")
          end.compact
        end

        def problems
          host_problems + service_problems
        end
      end
    end
  end
end
