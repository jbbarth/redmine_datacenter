class DenormalizeIssueElements < ActiveRecord::Migration
  def self.up
    add_column :issue_elements, :appli_id, :integer
    #calling save trigger the before_save callback
    #which will update appli_id on all elements
    #... but doesn't work:
    #IssueElement.all(:include => :element).each(&:save)
    
    #alternative method
    IssueElement.all(:include => :element).map do |ie|
      ie.update_appli_id
      sql = "UPDATE #{IssueElement.table_name} set appli_id=#{ie.appli_id} WHERE "
      sql << "(element_type = '#{ie.element_type}' AND element_id = #{ie.element_id})"
      sql
    end.uniq.each do |sql|
      IssueElement.connection.execute(sql)
    end
  end

  def self.down
    remove_column :issue_elements, :appli_id
  end
end
