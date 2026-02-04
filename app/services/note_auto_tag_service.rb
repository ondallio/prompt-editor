class NoteAutoTagService
  attr_reader :note, :provider

  SYSTEM_PROMPT = <<~PROMPT
    You are a knowledge management assistant. Analyze the given note content and extract:
    1. Tags: Key topics, themes, or categories (3-7 tags)
    2. Links: Concepts that could be separate notes and connected via [[wiki links]] (1-5 links)

    Respond in JSON format only:
    {
      "tags": ["tag1", "tag2"],
      "links": ["Concept A", "Concept B"]
    }

    Rules:
    - Tags should be single words or short phrases in the same language as the content
    - Links should be key concepts worthy of their own note
    - Support Korean content
    - Do not include generic tags like "note" or "memo"
  PROMPT

  def initialize(note, provider: nil)
    @note = note
    @provider = provider || AiProvider.active.first
  end

  def call
    return { tags: [], links: [], error: "AI Provider가 설정되지 않았습니다." } unless provider

    response_text = send_to_ai
    result = parse_response(response_text)

    apply_tags(result[:tags])
    apply_links(result[:links])

    note.update!(ai_tagged_at: Time.current)
    result
  rescue StandardError => e
    Rails.logger.error("NoteAutoTagService error: #{e.message}")
    { tags: [], links: [], error: e.message }
  end

  private

  def send_to_ai
    prompt = "Analyze this note and extract tags and wiki-links:\n\n#{note.content}"

    case provider.provider_type
    when "openai"
      call_openai(prompt)
    when "anthropic"
      call_anthropic(prompt)
    when "gemini"
      call_gemini(prompt)
    when "custom"
      call_custom(prompt)
    else
      raise "지원하지 않는 프로바이더: #{provider.provider_type}"
    end
  end

  def call_openai(prompt)
    client = OpenAI::Client.new(access_token: provider.api_key)
    response = client.chat(
      parameters: {
        model: provider.ai_model,
        messages: [
          { role: "system", content: SYSTEM_PROMPT },
          { role: "user", content: prompt }
        ],
        temperature: 0.3
      }
    )
    response.dig("choices", 0, "message", "content")
  end

  def call_anthropic(prompt)
    client = Anthropic::Client.new(api_key: provider.api_key)
    response = client.messages(
      parameters: {
        model: provider.ai_model,
        max_tokens: 1024,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: prompt }]
      }
    )
    response.dig("content", 0, "text")
  end

  def call_gemini(prompt)
    conn = Faraday.new(url: "https://generativelanguage.googleapis.com") do |f|
      f.request :json
      f.response :json
    end
    response = conn.post(
      "/v1beta/models/#{provider.ai_model}:generateContent?key=#{provider.api_key}",
      {
        system_instruction: { parts: [{ text: SYSTEM_PROMPT }] },
        contents: [{ parts: [{ text: prompt }] }]
      }
    )
    response.body.dig("candidates", 0, "content", "parts", 0, "text")
  end

  def call_custom(prompt)
    conn = Faraday.new(url: provider.endpoint_url) do |f|
      f.request :json
      f.response :json
      f.headers["Authorization"] = "Bearer #{provider.api_key}"
    end
    response = conn.post("", {
      model: provider.ai_model,
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: prompt }
      ]
    })
    result = response.body
    result.dig("choices", 0, "message", "content") || result["response"]
  end

  def parse_response(text)
    # JSON 블록을 추출 (```json ... ``` 또는 직접 JSON)
    json_text = text.to_s[/\{[^{}]*\}/m] || "{}"
    json = JSON.parse(json_text)
    {
      tags: Array(json["tags"]).map(&:strip).reject(&:blank?).first(7),
      links: Array(json["links"]).map(&:strip).reject(&:blank?).first(5)
    }
  rescue JSON::ParserError
    { tags: [], links: [] }
  end

  def apply_tags(tag_names)
    tag_names.each do |name|
      tag = Tag.find_or_create_by!(name: name.downcase) { |t| t.color = Tag::COLORS.sample }
      note.note_tags.find_or_create_by!(tag: tag, ai_generated: true)
    end
  end

  def apply_links(link_texts)
    link_texts.each do |text|
      note.outgoing_links.find_or_create_by!(linked_text: text, ai_generated: true)
    end
  end
end
