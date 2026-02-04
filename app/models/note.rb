class Note < ApplicationRecord
  has_many :note_tags, dependent: :destroy
  has_many :tags, through: :note_tags

  has_many :outgoing_links, class_name: "NoteLink", foreign_key: :source_note_id, dependent: :destroy
  has_many :incoming_links, class_name: "NoteLink", foreign_key: :target_note_id, dependent: :nullify

  has_many :linked_notes, through: :outgoing_links, source: :target_note
  has_many :linking_notes, through: :incoming_links, source: :source_note

  validates :content, presence: true

  scope :ordered, -> { order(updated_at: :desc) }
  scope :favorites, -> { where(favorite: true) }
  scope :search, ->(q) { where("title ILIKE :q OR content ILIKE :q", q: "%#{q}%") if q.present? }

  # content에서 [[링크]] 패턴 추출
  def extract_wiki_links
    content.to_s.scan(/\[\[([^\]]+)\]\]/).flatten.uniq
  end

  # content에서 #태그 패턴 추출
  def extract_hash_tags
    content.to_s.scan(/(?:^|\s)#([\w가-힣]+)/).flatten.uniq
  end

  # Linked References: [[이 노트]]를 명시적으로 참조하는 다른 노트들
  def linked_references
    return Note.none if title.blank?
    Note.joins(:outgoing_links)
        .where(note_links: { linked_text: title })
        .where.not(id: id)
        .distinct
  end

  # Unlinked References: 링크 없이 이 노트 제목을 언급하는 노트들
  def unlinked_references
    return Note.none if title.blank?
    linked_ids = linked_references.pluck(:id) + [id]
    Note.where("content ILIKE ?", "%#{title}%")
        .where.not(id: linked_ids)
  end

  # 표시 제목 (title이 없으면 content 첫 줄)
  def display_title
    title.presence || content.to_s.lines.first&.strip&.truncate(50) || "제목 없음"
  end

  # content 미리보기 (태그/링크 제외한 텍스트)
  def preview_text(length = 150)
    text = content.to_s
                  .gsub(/\[\[([^\]]+)\]\]/, '\1')
                  .gsub(/#([\w가-힣]+)/, '')
                  .strip
    text.truncate(length)
  end
end
