class PromptVariable < ApplicationRecord
  belongs_to :prompt

  validates :name, presence: true, uniqueness: { scope: :prompt_id }
end
