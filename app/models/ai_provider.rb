class AiProvider < ApplicationRecord
  has_many :executions, dependent: :nullify

  validates :name, presence: true
  validates :provider_type, presence: true, inclusion: { in: %w[openai anthropic gemini custom] }
  validates :api_key, presence: true
  validates :ai_model, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  PROVIDER_MODELS = {
    "openai" => %w[gpt-4o gpt-4o-mini gpt-4-turbo o1 o1-mini o3-mini],
    "anthropic" => %w[claude-opus-4-5-20251101 claude-sonnet-4-20250514 claude-3-5-haiku-20241022],
    "gemini" => %w[gemini-2.0-flash gemini-1.5-pro gemini-1.5-flash],
    "custom" => []
  }.freeze
end
