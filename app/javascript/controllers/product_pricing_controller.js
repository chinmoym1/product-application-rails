import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "price"]

  updatePrice() {
    // Find the currently selected <option> tag
    const selectedOption = this.selectTarget.options[this.selectTarget.selectedIndex]
    
    // Read the 'data-price' attribute we are going to inject into the HTML
    const price = selectedOption.dataset.price

    // If a price exists, update the unit price input field
    if (price) {
      this.priceTarget.value = parseFloat(price).toFixed(2)
    } else {
      this.priceTarget.value = "" // Clears it if they choose "Select Product"
    }
  }
}