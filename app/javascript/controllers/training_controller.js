import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "progress", "durationInput", "finishForm"]
  static values = {
    data: String,
    type: String,
    batchSize: Number
  }

  connect() {
    this.items = this.parseData()
    this.currentIndex = 0
    this.startTime = Date.now()
    
    this.renderBatch()
    
    // Bind Spacebar
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
  }

  handleKeydown(event) {
    if (event.code === "Space") {
      event.preventDefault() // Prevent scrolling
      this.next()
    }
  }

  parseData() {
    if (this.typeValue === "number") {
      return this.dataValue.split("")
    } else {
      return this.dataValue.split(",")
    }
  }

  renderBatch() {
    const batch = this.items.slice(this.currentIndex, this.currentIndex + this.batchSizeValue)
    
    if (batch.length === 0) {
      this.finish()
      return
    }

    let html = ""
    if (this.typeValue === "number") {
      html = `<div class="number-batch">${batch.join("")}</div>`
    } else {
      // Use hidden templates or constructing simpler HTML structure 
      // Since generating SVG in JS is complex, we assume the view pre-rendered them 
      // OR we just show text for now and rely on a server-side render helper?
      // BETTER: The View renders ALL items hidden, and this controller toggles visibility.
      // Let's refactor to Toggle Visibility approach.
    }
    
    // Actually, let's stick to the Visibility Toggle approach for simpler HTML/SVG handling.
    // See updated View strategy below.
  }
  
  // Refactored Strategy:
  // The view renders ALL items. We just toggle 'hidden' class on groups.
  
  next() {
    const batches = this.displayTargets
    if (this.currentIndex < batches.length - 1) {
      batches[this.currentIndex].classList.add("hidden")
      this.currentIndex++
      batches[this.currentIndex].classList.remove("hidden")
      this.updateProgress()
    } else {
      this.finish()
    }
  }

  updateProgress() {
    const total = this.displayTargets.length
    this.progressTarget.textContent = `Batch ${this.currentIndex + 1} / ${total}`
  }

  finish(event) {
    // If called via event (submit), just populate duration and let it proceed
    const elapsed = Math.floor((Date.now() - this.startTime) / 1000)
    this.durationInputTarget.value = elapsed
    
    // If called manually (e.g. from next()), we need to submit the form
    if (!event) {
      this.finishFormTarget.requestSubmit()
    }
  }
}