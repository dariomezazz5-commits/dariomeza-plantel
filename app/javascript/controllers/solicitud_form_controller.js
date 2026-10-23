import { Controller } from "@hotwired/stimulus"

const MESES = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]

// Resumen en vivo ("2–6 nov · 5 días hábiles") y habilitación del botón "Crear solicitud".
export default class extends Controller {
  static targets = ["colaborador", "desde", "hasta", "resumen", "submit"]
  static values = { feriados: Array }

  connect() {
    this.feriados = new Set(this.feriadosValue)
    this.actualizar()
  }

  actualizar() {
    const desde = this.parse(this.desdeTarget.value)
    const hasta = this.parse(this.hastaTarget.value)
    const valido = this.colaboradorTarget.value !== "" && desde && hasta && desde <= hasta

    this.submitTarget.disabled = !valido
    if (valido) {
      const n = this.diasHabiles(desde, hasta)
      this.resumenTarget.textContent = `${this.rango(desde, hasta)} · ${n} ${n === 1 ? "día hábil" : "días hábiles"}`
    } else {
      this.resumenTarget.textContent = "Elige colaborador y un rango de fechas válido."
    }
  }

  parse(value) {
    if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return null
    const [y, m, d] = value.split("-").map(Number)
    return new Date(Date.UTC(y, m - 1, d))
  }

  diasHabiles(desde, hasta) {
    let n = 0
    for (let d = new Date(desde); d <= hasta; d.setUTCDate(d.getUTCDate() + 1)) {
      const wd = d.getUTCDay()
      if (wd !== 0 && wd !== 6 && !this.feriados.has(d.toISOString().slice(0, 10))) n++
    }
    return n
  }

  rango(a, b) {
    const dm = d => `${d.getUTCDate()} ${MESES[d.getUTCMonth()]}`
    if (a.getTime() === b.getTime()) return dm(a)
    if (a.getUTCMonth() === b.getUTCMonth() && a.getUTCFullYear() === b.getUTCFullYear()) return `${a.getUTCDate()}–${dm(b)}`
    return `${dm(a)}–${dm(b)}`
  }
}
