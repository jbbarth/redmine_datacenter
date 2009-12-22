require_dependency 'issue'

class Issue
  has_and_belongs_to_many :servers
  has_many :issue_elements, :dependent => :destroy
  has_many :applis, :through => :issue_elements,
           :source => :element, :source_type => 'Appli'
  has_many :instances, :through => :issue_elements,
           :source => :element, :source_type => 'Instance'

  def has_server?(server)
    server_ids.include?(server.id)
  end

  def has_appli?(appli)
    appli_ids.include?(appli.id)
  end

  def appli_instance_ids
    appli_ids.map{|i|"Appli:#{i}"} + instance_ids.map{|i|"Instance:#{i}"}
  end

  def appli_instance_ids=(appli_instances)
    self.appli_ids = appli_instances.select{|e|e.match(/Appli:/)}.map{|e|e.gsub("Appli:","").to_i}
    self.instance_ids = appli_instances.select{|e|e.match(/Instance:/)}.map{|e|e.gsub("Instance:","").to_i}
  end

  def applis_and_instances
    self.applis + self.instances
  end
end
