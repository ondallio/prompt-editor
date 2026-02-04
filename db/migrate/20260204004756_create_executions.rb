class CreateExecutions < ActiveRecord::Migration[7.2]
  def change
    create_table :executions do |t|
      t.references :prompt, null: false, foreign_key: true
      t.references :ai_provider, null: false, foreign_key: true
      t.jsonb :input_variables, default: {}
      t.text :rendered_content
      t.text :response_text
      t.integer :token_count
      t.string :status, default: "pending"
      t.integer :duration_ms

      t.timestamps
    end
  end
end
