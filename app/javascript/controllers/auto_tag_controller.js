import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.element.addEventListener("turbo:submit-start", () => this.start())
    this.element.addEventListener("turbo:submit-end", () => this.complete())
  }

  start() {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = true
      this.originalText = this.buttonTarget.textContent
      this.buttonTarget.textContent = "AI 분석 중..."
    }
  }

  complete() {
    if (this.hasButtonTarget) {
      this.buttonTarget.disabled = false
      this.buttonTarget.textContent = this.originalText || "AI 자동 태깅"
    }
  }
}
