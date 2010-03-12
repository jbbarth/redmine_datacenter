module Storage
  module Utils
    def method_missing(*args)
      puts "Unknown method: #{args[0]}"
    end

    def read_value(text, key_regex, value_regex=".*")
      s = text.scan(/#{key_regex}:\s*(#{value_regex})/).first
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
      self.free_space.to_f / self.size.to_f * 100
    end
  end
end
