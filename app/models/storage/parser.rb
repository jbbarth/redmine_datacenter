module Storage
  class Parser
    attr_accessor :profile

    DEVICE_INFOS  = /^PROFILE FOR STORAGE SUBSYSTEM: (.*) \((.*)\)$/
    SECTION_BEGIN = /^([A-Z][A-Z ]+).*?-------------+$/
    SECTION_END   = /^Script execution complete\.$/

    def initialize(profile)
      @profile = parse(profile)
    end
    
    def parse(profile)
      lines = profile.lines.to_a
      res = {}
      #first search for meta infos
      while res["infos"].nil?
        res["infos"] = lines.shift.chomp.scan(DEVICE_INFOS)
      end
      #then separate each section and parse it
      section = nil
      lines.each do |line|
        case line
        when SECTION_BEGIN
          section = $~[1].downcase.gsub(" ","_")
          res[section] = []
        when SECTION_END
          section = nil
        else
          res[section] << line unless section.nil?
        end
      end
      #ok, we have a cool hash
      #let's parse each section if a specific method exists to do it
      res.keys.each do |key|
        method = "parse_#{key}".to_sym
        if respond_to?(method)
          res[key] = send(method, res[key].join)
        end
      end
      #then return a simple (nested) hash
      res
    end

    def parse_standard_logical_drives(section)
      section.scan(/\nDETAILS\n(.*)(?:\n[A-Z]|$)/m).to_s.split(/^\s*LOGICAL DRIVE NAME/im).map do |sub|
        "LOGICAL DRIVE NAME"+sub if sub.match(/^:/)
      end.compact
    end

    def parse_arrays(section)
      section.split(/\n\s+ARRAY (?=\d)/im).map do |sub|
        "ARRAY "+sub if sub.match(/^\S/)
      end.compact
    end

    def extract_logical_drives
      find_section("logical_drives").map do |section|
        Storage::LogicalDrive.new(section)
      end
    end
    
    def extract_arrays
      find_section("arrays").map do |section|
        Storage::Array.new(section)
      end
    end

    def find_section(name)
      res = @profile.detect do |k,v|
        k.include?(name)
      end
      res.nil? ? "" : res.last
    end

    private
    def read_value(text, key_regex, value_regex=".*")
      s = text.scan(/#{key_regex}:\s*(#{value_regex})/).first
      s.first.strip unless s.nil?
    end
  end
end
