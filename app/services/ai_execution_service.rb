class AiExecutionService
  attr_reader :execution

  def initialize(execution)
    @execution = execution
  end

  def call
    execution.update!(status: "running")
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    response = send_to_provider
    duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) * 1000).to_i

    execution.update!(
      response_text: response[:text],
      token_count: response[:tokens],
      status: "completed",
      duration_ms: duration
    )
    execution
  rescue StandardError => e
    execution.update!(
      status: "failed",
      response_text: "Error: #{e.message}"
    )
    execution
  end

  private

  def send_to_provider
    provider = execution.ai_provider
    case provider.provider_type
    when "openai"
      call_openai(provider)
    when "anthropic"
      call_anthropic(provider)
    when "gemini"
      call_gemini(provider)
    when "custom"
      call_custom(provider)
    else
      raise "지원하지 않는 프로바이더: #{provider.provider_type}"
    end
  end

  def call_openai(provider)
    client = OpenAI::Client.new(access_token: provider.api_key)

    messages = []
    if execution.rendered_content.present? && execution.prompt.system_prompt.present?
      rendered_sys = execution.prompt.render_system_prompt(execution.input_variables || {})
      messages << { role: "system", content: rendered_sys }
    end
    messages << { role: "user", content: execution.rendered_content }

    response = client.chat(
      parameters: {
        model: provider.ai_model,
        messages: messages,
        temperature: 0.7
      }
    )

    {
      text: response.dig("choices", 0, "message", "content"),
      tokens: response.dig("usage", "total_tokens")
    }
  end

  def call_anthropic(provider)
    client = Anthropic::Client.new(api_key: provider.api_key)

    params = {
      model: provider.ai_model,
      max_tokens: 4096,
      messages: [{ role: "user", content: execution.rendered_content }]
    }

    if execution.prompt.system_prompt.present?
      rendered_sys = execution.prompt.render_system_prompt(execution.input_variables || {})
      params[:system] = rendered_sys
    end

    response = client.messages(parameters: params)

    {
      text: response.dig("content", 0, "text"),
      tokens: response.dig("usage", "input_tokens").to_i + response.dig("usage", "output_tokens").to_i
    }
  end

  def call_gemini(provider)
    conn = Faraday.new(url: "https://generativelanguage.googleapis.com") do |f|
      f.request :json
      f.response :json
    end

    body = {
      contents: [{ parts: [{ text: execution.rendered_content }] }]
    }

    if execution.prompt.system_prompt.present?
      rendered_sys = execution.prompt.render_system_prompt(execution.input_variables || {})
      body[:system_instruction] = { parts: [{ text: rendered_sys }] }
    end

    response = conn.post(
      "/v1beta/models/#{provider.ai_model}:generateContent?key=#{provider.api_key}",
      body
    )

    result = response.body
    {
      text: result.dig("candidates", 0, "content", "parts", 0, "text"),
      tokens: result.dig("usageMetadata", "totalTokenCount")
    }
  end

  def call_custom(provider)
    conn = Faraday.new(url: provider.endpoint_url) do |f|
      f.request :json
      f.response :json
      f.headers["Authorization"] = "Bearer #{provider.api_key}"
    end

    response = conn.post("", {
      model: provider.ai_model,
      messages: [{ role: "user", content: execution.rendered_content }]
    })

    result = response.body
    {
      text: result.dig("choices", 0, "message", "content") || result["response"],
      tokens: result.dig("usage", "total_tokens")
    }
  end
end
