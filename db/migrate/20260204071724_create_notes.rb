class CreateNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :notes do |t|
      t.string :title
      t.text :content, null: false
      t.boolean :favorite, default: false
      t.datetime :ai_tagged_at

      t.timestamps
    end
  end
end
