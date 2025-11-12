class AddDeadlinesToSprints < ActiveRecord::Migration[7.0]
  def change
    add_column :sprints, :planning_deadline, :date
    add_column :sprints, :progress_deadline, :date
    add_column :sprints, :demo_deadline, :date
  end
end
