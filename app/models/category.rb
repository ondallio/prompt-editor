class Category < ApplicationRecord
  has_many :prompts, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:position, :name) }

  before_create :set_default_position

  COLORS = %w[
    #3B82F6 #EF4444 #10B981 #F59E0B #8B5CF6
    #EC4899 #06B6D4 #F97316 #6366F1 #14B8A6
  ].freeze

  private

  def set_default_position
    self.position ||= (Category.maximum(:position) || 0) + 1
  end
end
