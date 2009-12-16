class CreateApplisIssues < ActiveRecord::Migration
  def self.up
    create_table :applis_issues, :id => false do |t|
      t.column :appli_id, :integer, :null => false
      t.column :issue_id, :integer, :null => false
    end
    add_index :applis_issues, [:appli_id, :issue_id], :unique => true, :name => :applis_issues_ids
  end

  def self.down
    drop_table :applis_issues
  end
end
