class CreatePrompts < ActiveRecord::Migration[7.2]
  def change
    create_table :prompts do |t|
      t.string :title
      t.text :content
      t.references :category, foreign_key: true
      t.text :system_prompt
      t.integer :current_version, default: 1
      t.boolean :favorite, default: false

      t.timestamps
    end
  end
end
