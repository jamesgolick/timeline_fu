class CreateTimelineEvents < ActiveRecord::Migration
  def up
    create_table :timeline_events do |t|
      t.string   :event_type, :subject_type,  :actor_type,  :secondary_subject_type
      t.integer               :subject_id,    :actor_id,    :secondary_subject_id
      t.timestamps
    end
  end

  def down
    drop_table :timeline_events
  end
end