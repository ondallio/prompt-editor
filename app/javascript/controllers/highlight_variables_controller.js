import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const content = this.element.innerHTML
    this.element.innerHTML = content.replace(
      /\{\{(\w+)\}\}/g,
      '<span class="bg-indigo-100 text-indigo-700 px-1 rounded font-semibold">{{$1}}</span>'
    )
  }
}
