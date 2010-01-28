require 'open3'

module Storage
  class Bay
    SMCLI_BIN = "SMcli"
    
    def initialize(name, ipaddress = nil)
      @name = name
      @ipaddress = ipaddress
    end
    
    def profile
      @profile ||= load_profile_from_smcli(:ipaddress => @ipaddress)
    end
    
    def load_profile_from_smcli(options)
      raise ArgumentError, "You should provide at least one controller IP" if options[:ipaddress].nil?
      @profile = execute("show storagesubsystem profile", options)
    end
    
    def load_profile_from_file(file)
      @profile = File.read(file)
    end
    
    def execute(command, options)
      #see: http://tech.natemurray.com/2007/03/ruby-shell-commands.html
      #for the moment, we'll use Open3#popen3 so that we can differentiate STDOUT and STDERR
      #and because we don't have Open4 on our machines
      cmd = "#{SMCLI_BIN} #{options[:ipaddress]}"
      cmd << " -p #{options[:password]}" unless options[:password].blank?
      cmd << " -c '#{command};'"
      logger.info "[storage->#{options[:ipaddress]}] Executing #{cmd}"
      ret = ""
      stdin, stdout, stderr = Open3.popen3(cmd)
      while stdout.gets do
        if block_given?
          yield $_
        else
          ret << $_
        end
      end
      ret
    end
    
    def logical_drives
      @logical_drives ||= profile.scan(/\nDETAILS\n(.*?)\n[A-Z]{5,}/m).first.first.split(/\n\s*LOGICAL /m).map do |section|
        Storage::LogicalDrive.new("LOGICAL "+section) if section.match(/^DRIVE/)
      end.compact
    end
     
    def fresh_logical_drives
      return @logical_drives unless @logical_drives.nil?
      ld = ""
      @logical_drives = []
      execute "show logicalDrives" do |line|
        if line.strip.match(/^[A-Z]{5,}/) #we have a new section
          @logical_drives << Storage::LogicalDrive.new(ld) if ld.strip.match(/^LOGICAL/) #ld contains a logical_drive
          ld = ""
        end
        ld << line
      end
      @logical_drives
    end
    
    def arrays
      return @arrays unless @arrays.nil?
      @arrays = profile.scan(/ARRAYS-*\n(.*?)\n[A-Z]{5,}/m).first.first.split(/\n\s*ARRAY /m).map do |section|
        Storage::Array.new("ARRAY "+section) if section.match(/^\S/)
      end.compact
      @arrays.each do |array|
        array[:logical_drives].map! do |ld|
          if ld.match(/Free Capacity/)
            Storage::LogicalDrive.new(ld)
          else
            logical_drives.detect{|l| ld == l[:name]}
          end
        end
      end
      @arrays
    end
    
    def fresh_arrays
      @arrays ||= logical_drives.map do |ld|
        ld[:array].to_i
      end.uniq.sort.map do |array|
        puts execute("show array[#{array}]")
      end
    end

    def disk_usage_for(regex)
      logical_drives.select do |ld|
        ld[:name].match(regex)
      end.inject(0) do |sum,ld|
        sum + ld[:size]
      end
    end
  end
end
