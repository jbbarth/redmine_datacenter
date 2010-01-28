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
    end

    def size
      @size ||= self[:logical_drives].inject(0) {|memo,ld| memo + ld[:size]}
    end

    def free_space
      @free_space ||= self[:logical_drives].select{|ld| ld.free?}.inject(0) {|memo,ld| memo + ld[:size]}
    end

    def pretty_free
      pretty_size(free_space)
    end

    def used_space
      @used_space ||= size - free_space
    end
  end
end
