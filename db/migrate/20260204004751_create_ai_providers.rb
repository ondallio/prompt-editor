class CreateAiProviders < ActiveRecord::Migration[7.2]
  def change
    create_table :ai_providers do |t|
      t.string :name
      t.string :provider_type
      t.string :api_key
      t.string :ai_model
      t.string :endpoint_url
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
