import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slot", "input", "mobileRank"]
  static values = { count: Number }

  connect() {
    this.currentSlotIndex = 0
    this.selectSlot(0)
    this.cards = new Array(this.countValue).fill(null)
    this.selectedRank = null
  }

  selectSlot(index) {
    if (index < 0 || index >= this.countValue) return

    this.currentSlotIndex = index
    this.slotTargets.forEach((el, i) => {
      if (i === index) el.classList.add("selected")
      else el.classList.remove("selected")
    })
  }

  clickSlot(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    this.selectSlot(index)
  }

  // Desktop: One click adds card
  addCard(event) {
    const rank = event.currentTarget.dataset.rank
    const suit = event.currentTarget.dataset.suit
    this.submitCard(rank, suit)
  }

  // Mobile: Step 1 - Select Rank
  selectRank(event) {
    this.selectedRank = event.currentTarget.dataset.rank
    
    // UI Feedback
    this.mobileRankTargets.forEach(el => el.classList.remove("active"))
    event.currentTarget.classList.add("active")
  }

  // Mobile: Step 2 - Select Suit
  selectSuit(event) {
    if (!this.selectedRank) {
      // Visual shake or feedback could go here
      return
    }
    const suit = event.currentTarget.dataset.suit
    this.submitCard(this.selectedRank, suit)
  }

  submitCard(rank, suit) {
    const code = rank + suit
    
    // Update Data
    this.cards[this.currentSlotIndex] = code
    this.updateInput()

    // Update UI
    const slot = this.slotTargets[this.currentSlotIndex]
    slot.innerHTML = this.renderCardLabel(rank, suit)
    slot.classList.add("filled")

    // Auto-advance
    if (this.currentSlotIndex < this.countValue - 1) {
      this.selectSlot(this.currentSlotIndex + 1)
    }
  }

  clearSlot() {
    this.cards[this.currentSlotIndex] = null
    this.updateInput()
    
    const slot = this.slotTargets[this.currentSlotIndex]
    slot.innerHTML = ""
    slot.classList.remove("filled")
  }

  updateInput() {
    this.inputTarget.value = this.cards.filter(c => c).join(",")
  }

  renderCardLabel(rank, suit) {
    const suitIcon = { 'H': '♥', 'D': '♦', 'S': '♠', 'C': '♣' }[suit]
    const color = (suit === 'H' || suit === 'D') ? '#d9534f' : '#292b2c'
    return `<span style="color: ${color}; font-weight: bold; font-size: 1.2rem;">${rank}${suitIcon}</span>`
  }
}
