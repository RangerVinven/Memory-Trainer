import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "list", "item"]
  static values = { url: String }

  connect() {
    this.modalTarget.classList.add("hidden")
  }

  open() {
    this.modalTarget.classList.remove("hidden")
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  up(event) {
    const item = event.target.closest("[data-reorder-target='item']")
    const prev = item.previousElementSibling
    if (prev) {
      this.listTarget.insertBefore(item, prev)
      this.updateButtons()
    }
  }

  down(event) {
    const item = event.target.closest("[data-reorder-target='item']")
    const next = item.nextElementSibling
    if (next) {
      this.listTarget.insertBefore(next, item)
      this.updateButtons()
    }
  }

  // Optional: Disable first Up and last Down buttons visually
  updateButtons() {
    // Implement if polish needed
  }

  save() {
    const ids = this.itemTargets.map(item => item.dataset.id)
    
    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ loci_ids: ids })
    }).then(() => {
      window.location.reload()
    })
  }
}