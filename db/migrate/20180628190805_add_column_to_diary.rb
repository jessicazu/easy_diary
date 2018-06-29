class AddColumnToDiary < ActiveRecord::Migration[5.0]
  def change
    add_column :diaries, :impressive_event_exist, :boolean, after: :detail
    add_column :diaries, :impressive_event_good, :boolean, after: :impressive_event_exist
    add_column :diaries, :end, :boolean, after: :score
  end
end
