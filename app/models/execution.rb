class Execution < ApplicationRecord
  belongs_to :prompt
  belongs_to :ai_provider

  validates :status, inclusion: { in: %w[pending running completed failed] }

  scope :recent, -> { order(created_at: :desc) }
end
