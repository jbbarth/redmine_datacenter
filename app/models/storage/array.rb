module Storage
  class Array < Hash
    include Storage::Utils

    def initialize(raw)
      self[:name], self[:raid] = raw.scan(/ARRAY (\S*) \(RAID (\S+)\)/).first
      self[:status] = read_value(raw, "Array status")
      self[:drive_type] = read_value(raw, "Drive type")
      self[:logical_drives] = []
      raw.scan(/LOGICAL DRIVE.*?\n(.*?)\n\n/m).to_s.each_line do |line|
        if line.match(/Free Capacity/)
          self[:logical_drives] << line
        else
          self[:logical_drives] << line.split.first
        end
      end
      #ds4100
      if self[:logical_drives].empty?
        r = /^\s+Associated logical.*?:(.*)\s+Associated drives/m
        raw.scan(r).to_s.split(/\n|,/).map(&:strip).compact.each do |line|
          if line.match(/Free Capacity/)
            self[:logical_drives] << line
          else
            self[:logical_drives] << line.split.first
          end
        end
        self[:logical_drives] = self[:logical_drives].compact
      end
    end

    def size
      @size ||= self[:logical_drives].inject(0) do |memo,ld|
        memo + ld[:size]
      end
    end

    def free_space
      @free_space ||= self[:logical_drives].inject(0) do |memo,ld|
        ld.free? ? memo + ld[:size] : memo
      end
    end

    def pretty_free
      pretty_size(free_space)
    end

    def used_space
      @used_space ||= size - free_space
    end
  end
end
