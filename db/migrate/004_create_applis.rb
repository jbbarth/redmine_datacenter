class CreateApplis < ActiveRecord::Migration
  def self.up
    create_table :applis do |t|
      t.string :name
      t.text :description
      t.timestamps
    end
  end
  
  def self.down
    drop_table :applis
  end
end
