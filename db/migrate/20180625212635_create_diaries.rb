class CreateDiaries < ActiveRecord::Migration[5.0]
  def change
    create_table :diaries do |t|
      t.references :user, foreign_key: true
      t.string :feeling
      t.text :detail
      t.integer :score

      t.timestamps
    end
  end
end
