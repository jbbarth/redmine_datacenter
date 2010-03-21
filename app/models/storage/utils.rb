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
      line.gsub!(/(\d)[, ](\d)/, '\1\2') #1,234 and 1 234 => 1234
      size = line.scan(/(\d+) Bytes/)
      return size.to_s.to_i if size.any?
      size = line.to_s.gsub(/\(.*/,"")
      units = %w(KB MB GB TB PB)
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
