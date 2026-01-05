import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "overlay"]

  toggle() {
    this.sidebarTarget.classList.toggle("open")
    this.overlayTarget.classList.toggle("hidden")
  }

  close() {
    this.sidebarTarget.classList.remove("open")
    this.overlayTarget.classList.add("hidden")
  }
}