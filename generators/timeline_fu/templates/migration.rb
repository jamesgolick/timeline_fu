class CreateTimelineEvents < ActiveRecord::Migration
  def self.up
    create_table :timeline_events do |t|
      t.references :account
      t.string   :event_type, :subject_type,  :actor_type,  :secondary_subject_type
      t.integer               :subject_id,    :actor_id,    :secondary_subject_id
      t.timestamps
    end

    add_index :timeline_events, :account_id
    add_index :timeline_events, [:subject_id , :subject_type]
    add_index :timeline_events, [:actor_id , :actor_type]
    add_index :timeline_events, [:secondary_subject_id , :secondary_subject_type], :name => 'secondary_subject_timeline_events'
  end

  def self.down
    drop_table :timeline_events
  end
end
