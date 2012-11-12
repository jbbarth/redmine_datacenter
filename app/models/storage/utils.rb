module Storage
  module Utils
    def method_missing(*args)
      puts "Unknown method: #{args[0]}"
    end

    def read_value(text, key_regex, value_regex=".*")
      s = text.scan(/#{key_regex}:\s*(#{value_regex})/i).first
      s.first.strip unless s.nil?
    end

    def pretty_size(size=nil)
      size ||= self.size
      #units = %w(o Ko Mo Go To Po)
      units = %w(o Ko Mo Go)
      i = 0
      while size >=1024 && units[i+1]
        size /= 1024.0
        i += 1
      end
      "#{"%.1f" % size}#{units[i]}"
    end

    def percent_free
      return 0 if self.size.to_i == 0
      self.free_space.to_f / self.size.to_f * 100
    end

    def percent_used
      100 - percent_free
    end

    def parse_size(line)
      size = line.gsub(/[^a-z0-9().,]/i, '') #1,234 and 1 234 => 1234 + sanitizes some awful chars
      if size.match(/\dBytes\)/)
        size.tr!(",.","")
        return size.scan(/(\d+)Bytes/).first.try(:first).to_i
      end
      size.gsub!(/\(.*/,"")
      units = %w(KB MB GB TB PB)
      #let's try to guess the format :/
      size.gsub!(",","") if size.include?(",") && size.include?(".")
      size.gsub!(",","") if size.scan(",").length > 1
      size.gsub!(",",".")
      num = size.to_f
      units.each_with_index do |u,idx|
        if size.include?(u)
          num = num * 1024 ** (idx+1) 
        end
      end
      num.round
    end
  end
end
