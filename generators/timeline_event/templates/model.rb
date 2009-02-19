class TimelineEvent < ActiveRecord::Base
  belongs_to :subject,          :polymorphic => true
  belongs_to :actor,            :polymorphic => true
  belongs_to :secondary_actor,  :polymorphic => true
end
