class CreateNoteLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :note_links do |t|
      t.references :source_note, null: false, foreign_key: { to_table: :notes }
      t.references :target_note, foreign_key: { to_table: :notes }
      t.string :linked_text, null: false
      t.boolean :ai_generated, default: false

      t.timestamps
    end

    add_index :note_links, [:source_note_id, :linked_text], unique: true
    add_index :note_links, :linked_text
  end
end
