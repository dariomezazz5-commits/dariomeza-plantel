import { Controller } from "@hotwired/stimulus"

// Cierra la ficha lateral o el diálogo vaciando el turbo-frame que los contiene.
export default class extends Controller {
  static targets = ["focus"]

  connect() {
    this.previous = document.activeElement
    if (this.hasFocusTarget) this.focusTarget.focus({ preventScroll: true })
  }

  close() {
    const frame = this.element.closest("turbo-frame")
    if (frame) {
      frame.removeAttribute("src")
      frame.innerHTML = ""
    } else {
      this.element.remove()
    }
    this.previous?.focus?.({ preventScroll: true })
  }

  closeOnBackdrop(event) {
    if (event.target === this.element) this.close()
  }
}
