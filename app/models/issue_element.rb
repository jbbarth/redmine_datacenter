class IssueElement < ActiveRecord::Base
  unloadable

  belongs_to :issue
  belongs_to :element, :polymorphic => true
end
