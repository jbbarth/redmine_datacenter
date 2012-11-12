module Storage
  class LogicalDrive < Hash
    include Storage::Utils
    
    def initialize(raw)
      if raw.match(/Free Capacity/)
        self[:name] = "Free Capacity"
        self[:size] = parse_size(raw.scan(/Free Capacity\s+(\S.*)/).first.try(:first).try(:strip))
      else
        self[:name] = read_value(raw, "LOGICAL DRIVE NAME")
        self[:array] = read_value(raw, "Associated array")
        self[:size] = parse_size(read_value(raw, "Capacity"))
        self[:raid] = read_value(raw, "RAID level")
        self[:status] = read_value(raw, "Logical Drive status")
        self[:wwid] = read_value(raw, "Logical Drive ID")
        self[:ssid] = read_value(raw, "Subsystem ID \\(SSID\\)")
        self[:drive_type] = read_value(raw, "Drive type")
        self[:loss_protection] = read_value(raw, "Enclosure loss protection")
        self[:preferred_owner] = read_value(raw, "Preferred owner")
        self[:current_owner] = read_value(raw, "Current owner")
        self[:segment_size] = read_value(raw, "Segment size")
        self[:modification_priority] = read_value(raw, "Modification priority")
      end
    end

    def size
      self[:size]
    end

    def to_s
      "#{self[:name]} (#{self.pretty_size})"
    end

    def free?
      self[:name] == "Free Capacity"
    end
  end
end
