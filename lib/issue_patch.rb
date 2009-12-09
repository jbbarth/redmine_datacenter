require_dependency 'issue'

class Issue
  has_and_belongs_to_many :servers

  def has_server?(server)
    server_ids.include?(server.id)
  end
end
