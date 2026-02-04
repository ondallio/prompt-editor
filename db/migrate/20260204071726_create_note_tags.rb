class CreateNoteTags < ActiveRecord::Migration[7.2]
  def change
    create_table :note_tags do |t|
      t.references :note, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true
      t.boolean :ai_generated, default: false

      t.timestamps
    end

    add_index :note_tags, [:note_id, :tag_id], unique: true
  end
end
