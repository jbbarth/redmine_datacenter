require_dependency 'query'

class Query
  def available_filters_with_datacenter_custom_filters
    available_filters_without_datacenter_custom_filters
    if project.nil? || project.module_enabled?(:datacenter)
      @available_filters["server_id"] = { :type => :list,
                                          :order => 25,
                                          :values => Server.active.collect{|s| [s.name, s.id.to_s] } }
      @available_filters["appli_id"] = { :type => :list,
                                          :order => 30,
                                          :values => Appli.all.collect{|s| [s.name, s.id.to_s] } }
    end
    @available_filters
  end
  alias_method_chain :available_filters, :datacenter_custom_filters
  
  def statement_with_datacenter_custom_filters
    custom_filters = %w(server_id appli_id)
    filters_orig = self.filters.clone
    if (self.filters.keys & custom_filters).any? #filters include custom ones
      filter_clauses = []
      (self.filters.keys & custom_filters).each do |field|
        sql = ''
        v = values_for(field).clone
        next unless v and !v.empty?
        operator = operator_for(field)
        case field
        when "server_id"
          db_table = Server.reflections[:issues].options[:join_table]
          db_field = 'server_id'
          is_custom_filter = true
          sql << "#{Issue.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } "
          sql << "(SELECT #{db_table}.issue_id FROM #{db_table} WHERE "
          sql << sql_for_field(field, '=', v, db_table, db_field) + ')'
        when "appli_id"
          db_table = Appli.reflections[:issues].options[:join_table]
          db_field = 'appli_id'
          is_custom_filter = true
          sql << "#{Issue.table_name}.id #{ operator == '=' ? 'IN' : 'NOT IN' } "
          sql << "(SELECT #{db_table}.issue_id FROM #{db_table} WHERE "
          sql << sql_for_field(field, '=', v, db_table, db_field) + ')'
        else
          #nothing:-), this shouldn't happen
          #todo(?): raise an exception
        end
        filter_clauses << sql
      end
      #we now delete these filters so that they don't interfer
      #with normal ones in core method Query#statementother
      self.filters.delete_if{|k,v| custom_filters.include?(k)}
      #let's go back to "normal" filters
      filter_clauses << statement_without_datacenter_custom_filters
      #re-insert filter (appearance in next page?)
      self.filters = filters_orig
      #return
      filter_clauses.delete_if(&:blank?).join(" AND ")
    else
      statement_without_datacenter_custom_filters
    end
  end
  alias_method_chain :statement, :datacenter_custom_filters
end
