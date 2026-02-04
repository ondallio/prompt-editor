class PromptVersion < ApplicationRecord
  belongs_to :prompt

  validates :version_number, presence: true, uniqueness: { scope: :prompt_id }
  validates :content, presence: true

  scope :ordered, -> { order(version_number: :desc) }

  def diff_from(other_version)
    {
      content_changed: content != other_version&.content,
      system_prompt_changed: system_prompt != other_version&.system_prompt
    }
  end
end
