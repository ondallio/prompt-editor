import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "preview"]

  contentChanged() {
    const text = this.contentTarget.value
    if (this.hasPreviewTarget) {
      if (text.includes("[[") || text.includes("#")) {
        this.previewTarget.classList.remove("hidden")
        this.previewTarget.innerHTML = this.renderPreview(text)
      } else {
        this.previewTarget.classList.add("hidden")
      }
    }
  }

  renderPreview(text) {
    let html = text
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
    // [[link]] 하이라이트
    html = html.replace(
      /\[\[([^\]]+)\]\]/g,
      '<span class="text-indigo-600 font-medium">[[$1]]</span>'
    )
    // #tag 하이라이트
    html = html.replace(
      /(^|\s)#([\w가-힣]+)/gm,
      '$1<span class="text-emerald-600 font-medium">#$2</span>'
    )
    return html
  }
}
