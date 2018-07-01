class AddDefaultToDiary < ActiveRecord::Migration[5.0]
  def up
    change_column :diaries, :end, :boolean, after: :score, default: false
  end

  def down
    change_column :diaries, :end, :boolean, after: :score
  end
end
