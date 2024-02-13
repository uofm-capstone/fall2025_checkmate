class CreateSprints < ActiveRecord::Migration[6.0]
  def change
    create_table :sprints do |t|
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
