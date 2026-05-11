import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.close()
    }, 3000)
  }

  close() {
    this.element.classList.add("transform", "opacity-0", "transition", "duration-500", "ease-in-out")
    
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
