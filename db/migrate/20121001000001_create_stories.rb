class CreateStories < ActiveRecord::Migration

  def change
    create_table :stories do |t|
      t.string :name
      t.string :birthday
      t.string :classify

      t.timestamps
    end
  end
end
