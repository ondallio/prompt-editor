import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submitBtn"]

  connect() {
    this.element.addEventListener("turbo:submit-start", () => {
      if (this.hasSubmitBtnTarget) {
        this.submitBtnTarget.disabled = true
        this.submitBtnTarget.textContent = "실행 중..."
      }
    })

    this.element.addEventListener("turbo:submit-end", () => {
      if (this.hasSubmitBtnTarget) {
        this.submitBtnTarget.disabled = false
        this.submitBtnTarget.textContent = "실행"
      }
    })
  }
}
