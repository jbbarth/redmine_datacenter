require_dependency 'issue'

class Issue
  has_and_belongs_to_many :servers
  has_and_belongs_to_many :applis

  def has_server?(server)
    server_ids.include?(server.id)
  end

  def has_appli?(appli)
    appli_ids.include?(appli.id)
  end
end
