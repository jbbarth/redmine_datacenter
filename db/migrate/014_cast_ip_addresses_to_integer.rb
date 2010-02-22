require 'ipaddr'

class CastIpAddressesToInteger < ActiveRecord::Migration
  TO_CAST = { Interface => [:ipaddress],
              Network   => [:address, :netmask] }
  
  def self.up
    TO_CAST.each do |klass,columns|
      table = klass.table_name
      columns.each do |column|
        #first detect if columns is a string
        unless klass.columns.detect{|c|c.name==column && c.type==:string}
          #rename old string column and create a new int one
          rename_column table, column, "#{column}_text"
          add_column table, column, :integer
          klass.reset_column_information 
          #update data
          klass.all.each do |line|
            ip = line.send("#{column}_text")
            unless ip.blank?
              #in case we already have int IP
              ip = IPAddr.new(ip.to_i,Socket::AF_INET).to_s if ip==ip.to_i.to_s && ip.to_i > 32
              line.send("#{column}=", ip)
              line.send(:save)
            end
          end
          #remove temp column
          remove_column table, "#{column}_text"
        end
      end
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
