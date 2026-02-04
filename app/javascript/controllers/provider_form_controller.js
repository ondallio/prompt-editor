import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["providerType", "modelInput"]

  static models = {
    openai: ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "o1", "o1-mini", "o3-mini"],
    anthropic: ["claude-opus-4-5-20251101", "claude-sonnet-4-20250514", "claude-3-5-haiku-20241022"],
    gemini: ["gemini-2.0-flash", "gemini-1.5-pro", "gemini-1.5-flash"],
    custom: []
  }

  updateModels() {
    const type = this.providerTypeTarget.value
    const models = this.constructor.models[type] || []

    if (models.length > 0 && this.hasModelInputTarget) {
      this.modelInputTarget.placeholder = models.join(", ")
      if (!this.modelInputTarget.value) {
        this.modelInputTarget.value = models[0]
      }
    }
  }
}
