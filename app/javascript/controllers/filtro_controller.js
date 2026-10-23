import { Controller } from "@hotwired/stimulus"

// Búsqueda y chips de área en Colaboradores: envía el formulario GET (respuesta turbo_stream).
export default class extends Controller {
  buscar() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => this.submit(), 200)
  }

  submit() {
    this.element.requestSubmit()
  }

  disconnect() {
    clearTimeout(this.timeout)
  }
}
