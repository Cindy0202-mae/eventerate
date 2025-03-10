class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title
      t.boolean :completed
      t.text :comment
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
