import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["target", "template"]

  add(e) {
    e.preventDefault()
    // Clone template + unique ID
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    // Insert before target
    this.targetTarget.insertAdjacentHTML('beforebegin', content)
  }

  remove(e) {
    e.preventDefault()
    const wrapper = e.target.closest('.nested-fields')
    
    // remove if new
    if (wrapper.dataset.newRecord === 'true') {
      wrapper.remove()
    } else {
      // Hide + mark for destroy
      wrapper.style.display = 'none'
      const destroyInput = wrapper.querySelector("input[name*='_destroy']")
      if (destroyInput) destroyInput.value = '1'
    }
  }
}