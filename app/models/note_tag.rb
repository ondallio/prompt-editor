class NoteTag < ApplicationRecord
  belongs_to :note
  belongs_to :tag, counter_cache: :notes_count

  validates :tag_id, uniqueness: { scope: :note_id }
end
