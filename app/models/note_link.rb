class NoteLink < ApplicationRecord
  belongs_to :source_note, class_name: "Note"
  belongs_to :target_note, class_name: "Note", optional: true

  validates :linked_text, presence: true
  validates :linked_text, uniqueness: { scope: :source_note_id }

  before_save :resolve_target_note

  private

  def resolve_target_note
    self.target_note ||= Note.find_by(title: linked_text)
  end
end
