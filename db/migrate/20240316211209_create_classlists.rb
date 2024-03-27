class CreateClasslists < ActiveRecord::Migration[7.0]
  def change
    create_table :classlists do |t|
      t.references :student, null: false, foreign_key: true
      t.references :semester, null: false, foreign_key: true

      t.timestamps
    end
  end
end
