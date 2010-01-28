module Storage
  class Parser
    def initialize(io)
      while io.gets do
      end
    end

    private
    def read_value(text, key_regex, value_regex=".*")
      s = text.scan(/#{key_regex}:\s*(#{value_regex})/).first
      s.first.strip unless s.nil?
    end
  end
end
