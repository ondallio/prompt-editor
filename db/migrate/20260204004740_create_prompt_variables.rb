class CreatePromptVariables < ActiveRecord::Migration[7.2]
  def change
    create_table :prompt_variables do |t|
      t.references :prompt, null: false, foreign_key: true
      t.string :name
      t.string :default_value
      t.string :description

      t.timestamps
    end
  end
end
