class MakeAppsIssuesPolymorphic < ActiveRecord::Migration
  def self.up
    remove_index :applis_issues, :name => :applis_issues_ids
    add_column :applis_issues, :element_type, :string
    rename_column :applis_issues, :appli_id, :element_id
    rename_table :applis_issues, :issue_elements
    add_index :issue_elements, [:element_id, :element_type, :issue_id],
              :unique => true, :name => :issue_elements_ids
    IssueElement.update_all("element_type = 'Appli'")
  end

  def self.down
    remove_index :issue_elements, :name => :issue_elements_ids
    rename_table :issue_elements, :applis_issues
    rename_column :applis_issues, :element_id, :appli_id
    IssueElement.find(:conditions => ["element_type != ?", "Appli"]).destroy
    remove_column :applis_issues, :element_type
    add_index :applis_issues, [:appli_id, :issue_id], :unique => true, :name => :applis_issues_ids
  end
end
