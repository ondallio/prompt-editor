class CreatePromptVersions < ActiveRecord::Migration[7.2]
  def change
    create_table :prompt_versions do |t|
      t.references :prompt, null: false, foreign_key: true
      t.integer :version_number
      t.text :content
      t.text :system_prompt
      t.string :change_note

      t.timestamps
    end
  end
end
