require_dependency 'query'

class Query
  def available_filters_with_servers
    available_filters_without_servers
    @available_filters["server_id"] = { :type => :list,
                                        :order => 25,
                                        :values => Server.active.collect{|s| [s.name, s.id.to_s] } }
    @available_filters
  end
  alias_method_chain :available_filters, :servers
  
  def statement_with_servers
    filters_orig = self.filters.clone
    if self.filters.has_key?("server_id")
      #filter for server_id
      sql = ''
      field = "server_id"
      v = values_for(field).clone
      next unless v and !v.empty?
      operator = operator_for(field)
      db_table = Server.reflections[:issues].options[:join_table]
      db_field = 'server_id'
      is_custom_filter = true
      sql << "#{Issue.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } "
      sql << "(SELECT #{db_table}.issue_id FROM #{db_table} WHERE "
      sql << sql_for_field(field, '=', v, db_table, db_field) + ')'
      #other filters
      self.filters.delete_if{|k,v| k == "server_id"}
      filters_clauses = [sql, statement_without_servers]
      #re-insert filter (appearance in next page?)
      self.filters = filters_orig
      #return
      filters_clauses.delete_if(&:blank?).join(" AND ")
    else
      statement_without_servers
    end
  end
  alias_method_chain :statement, :servers
end
