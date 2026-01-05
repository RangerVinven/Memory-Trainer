import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status"]

  connect() {
    this.timeout = null
    this.isDirty = false
    this.saveText = "Saved"
    this.savingText = "Saving..."
    
    this.boundBeforeUnload = this.beforeUnload.bind(this)
    window.addEventListener("beforeunload", this.boundBeforeUnload)
  }

  disconnect() {
    window.removeEventListener("beforeunload", this.boundBeforeUnload)
  }

  change(event) {
    this.isDirty = true
    this.setStatus("Unsaved changes...")
    
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.submit()
    }, 1000) // Auto-save after 1 second of inactivity
  }

  submit() {
    this.setStatus(this.savingText)
    // Use Rails UJS / Turbo submit
    this.element.requestSubmit()
  }

  // Called by rails-ujs or Turbo on successful submission (ajax:success)
  // But standard requestSubmit might trigger a full page reload unless it's a Turbo Frame or remote: true form.
  // We will assume Turbo is handling the form submission.
  
  onPostSuccess(event) {
    this.isDirty = false
    this.setStatus(this.saveText)
    setTimeout(() => {
       if(!this.isDirty) this.setStatus("") 
    }, 2000)
  }

  setStatus(msg) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = msg
    }
  }

  // Browser level protection
  beforeUnload(event) {
    if (this.isDirty) {
      event.preventDefault()
      event.returnValue = ''
    }
  }
}