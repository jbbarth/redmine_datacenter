class OperatingSystem < ActiveRecord::Base
  has_many :servers
  
  acts_as_nested_set :order => "name"
  
  validates_presence_of :name
  validates_uniqueness_of :name

  named_scope :hypervisors, :conditions => { :hypervisor => true }, :order => "name"

  def set_parent!(value)
    if !new_record?
      target = self.class.find_by_id(value)
      if target && move_possible?(target)
        move_to_child_of(target)
      else
        move_to_root
      end
    end
  end
end
