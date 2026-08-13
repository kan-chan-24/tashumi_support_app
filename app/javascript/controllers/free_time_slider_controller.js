import { Controller } from "@hotwired/stimulus"

// 自由時間スライダー（15分刻み）の値を「〇時間〇分」表示に反映する
export default class extends Controller {
  static targets = ["slider", "display"]

  connect() {
    this.updateDisplay()
  }

  updateDisplay() {
    const minutes = Number(this.sliderTarget.value)
    const hours = Math.floor(minutes / 60)
    const remainder = minutes % 60
    this.displayTarget.textContent = `${hours}時間${remainder}分`
  }
}
