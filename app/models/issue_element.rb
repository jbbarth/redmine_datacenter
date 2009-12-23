class IssueElement < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :element, :polymorphic => true

  attr_accessible :element_id, :element_type, :issue_id, :appli_id

  before_save :update_appli_id
  
  def update_appli_id
    self.appli_id = (self.element_type == "Appli" ? self.element_id : self.element.appli_id)
  end
end
