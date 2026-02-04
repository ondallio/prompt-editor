class Tag < ApplicationRecord
  has_many :note_tags, dependent: :destroy
  has_many :notes, through: :note_tags

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
  scope :popular, -> { order(notes_count: :desc) }

  COLORS = %w[
    #3B82F6 #EF4444 #10B981 #F59E0B #8B5CF6
    #EC4899 #06B6D4 #F97316 #6366F1 #14B8A6
  ].freeze

  # 태그 이름이 본문에 있지만 태그로 연결되지 않은 노트들
  def unlinked_references
    tagged_ids = notes.pluck(:id)
    Note.where("content ILIKE ?", "%#{name}%")
        .where.not(id: tagged_ids)
  end
end
