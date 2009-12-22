require_dependency 'issue'

class Issue
  has_and_belongs_to_many :servers
  has_many :issue_elements, :dependent => :destroy
  has_many :applis,
           :through => :issue_elements,
           :source => :element,
           :source_type => 'Appli'

  def has_server?(server)
    server_ids.include?(server.id)
  end

  def has_appli?(appli)
    appli_ids.include?(appli.id)
  end
end
