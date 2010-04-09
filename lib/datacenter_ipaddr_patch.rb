require 'ipaddr'

class IPAddr
  if RUBY_VERSION < '1.8.7'
  # Ruby 1.8.6 does not include this method (and I'm on RHEL at work...)
  def to_range
    begin_addr = (@addr & @mask_addr)

    case @family
    when Socket::AF_INET
      end_addr = (@addr | (IN4MASK ^ @mask_addr))
    when Socket::AF_INET6
      end_addr = (@addr | (IN6MASK ^ @mask_addr))
    else
      raise "unsupported address family"
    end

    return [clone.set(begin_addr, @family),clone.set(end_addr, @family)]
  end
  end

  def self.valid?(addr)
    begin
      new(addr)
    rescue ArgumentError
      false
    end
  end

  def self.new_from_int(addr)
    addr = addr.to_i if addr == addr.to_i.to_s #if it's an "Integer"
    new(addr, Socket::AF_INET).to_s unless addr.blank?
  end
end
