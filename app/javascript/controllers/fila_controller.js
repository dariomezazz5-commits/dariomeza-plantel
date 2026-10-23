import { Controller } from "@hotwired/stimulus"

// Hace clicable toda la fila de la tabla, delegando en el enlace de la primera celda.
export default class extends Controller {
  static targets = ["link"]

  abrir(event) {
    if (event.target.closest("a, button")) return
    this.linkTarget.click()
  }
}
