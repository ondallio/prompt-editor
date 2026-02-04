class Prompt < ApplicationRecord
  belongs_to :category, optional: true
  has_many :versions, class_name: "PromptVersion", dependent: :destroy
  has_many :variables, class_name: "PromptVariable", dependent: :destroy
  has_many :executions, dependent: :destroy

  validates :title, presence: true
  validates :content, presence: true

  scope :ordered, -> { order(updated_at: :desc) }
  scope :favorites, -> { where(favorite: true) }
  scope :by_category, ->(category_id) { where(category_id: category_id) if category_id.present? }

  after_save :create_version_if_content_changed
  after_save :extract_variables

  # {{변수명}} 패턴으로 변수 추출
  def extract_variable_names
    (content.to_s + system_prompt.to_s).scan(/\{\{(\w+)\}\}/).flatten.uniq
  end

  # 변수를 치환한 프롬프트 렌더링
  def render_content(variable_values = {})
    rendered = content.to_s.dup
    variable_values.each do |key, value|
      rendered.gsub!("{{#{key}}}", value.to_s)
    end
    rendered
  end

  def render_system_prompt(variable_values = {})
    rendered = system_prompt.to_s.dup
    variable_values.each do |key, value|
      rendered.gsub!("{{#{key}}}", value.to_s)
    end
    rendered
  end

  private

  def create_version_if_content_changed
    return unless saved_change_to_content? || saved_change_to_system_prompt?

    next_version = (versions.maximum(:version_number) || 0) + 1
    versions.create!(
      version_number: next_version,
      content: content,
      system_prompt: system_prompt,
      change_note: "v#{next_version}"
    )
    update_column(:current_version, next_version)
  end

  def extract_variables
    existing_names = variables.pluck(:name)
    new_names = extract_variable_names

    # 새 변수 추가
    (new_names - existing_names).each do |name|
      variables.create!(name: name)
    end

    # 없어진 변수 제거
    variables.where.not(name: new_names).destroy_all
  end
end
