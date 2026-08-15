import { Controller } from "@hotwired/stimulus"

// 趣味の配分％スライダーを操作すると、合計％表示・円グラフ・
// 「次へ進む」ボタンの有効/無効をリアルタイムで更新する
export default class extends Controller {
  static targets = ["slider", "percentageDisplay", "legendPercentage", "pieChart", "totalDisplay", "totalWrapper", "submitButton", "nameInput", "addButton"]

  // 円グラフのセグメント色。hobbies_helper.rbのPIE_CHART_COLORSと同じ並びにする
  colors = [
    "#9cab84",
    "#c2a97c",
    "#b79cc2",
    "#7ca6c2",
    "#c27c8e",
    "#7cc2ae",
  ]

  connect() {
    this.updateAll()
    this.updateAddButton()
  }

  // 数値入力欄が変更されたとき、同じ趣味のスライダーにも値を反映してから全体を更新する
  updateFromInput(event) {
    const index = this.percentageDisplayTargets.indexOf(event.target)
    this.sliderTargets[index].value = event.target.value
    // 今まさに入力中の要素自身には値を書き戻さない（カーソル位置がリセットされ、入力を邪魔してしまうため）
    this.updateAll(event.target)
  }

  // 趣味の追加・削除フォームが送信される直前、現在の全スライダーの値を
  // hidden fieldとしてそのフォームに追加する（DBへの暫定保存のため）
  addSliderValues(event) {
    const form = event.target

    this.sliderTargets.forEach((slider) => {
      const hiddenField = document.createElement("input")
      hiddenField.type = "hidden"
      hiddenField.name = `existing_percentages[${slider.dataset.hobbyId}]`
      hiddenField.value = slider.value
      form.appendChild(hiddenField)
    })
  }

  updateAll(skipElement = null) {
    const values = this.sliderTargets.map((slider) => Number(slider.value))
    const total = values.reduce((sum, value) => sum + value, 0)

    values.forEach((value, index) => {
      if (this.percentageDisplayTargets[index] !== skipElement) {
        this.percentageDisplayTargets[index].value = value
      }
      this.legendPercentageTargets[index].textContent = value
    })

    this.totalDisplayTarget.textContent = total
    this.updatePieChart(values)
    this.updateSubmitButton(total)
    this.updateTotalColor(total)
  }

  updatePieChart(values) {
    let currentAngle = 0
    const segments = values.map((value, index) => {
      const color = this.colors[index % this.colors.length]
      const nextAngle = currentAngle + value
      const segment = `${color} ${currentAngle}% ${nextAngle}%`
      currentAngle = nextAngle
      return segment
    })

    // 合計が100%に届かない残りは、「未配分」だとわかる色で埋める
    if (currentAngle < 100) {
      segments.push(`var(--color-bar-track) ${currentAngle}% 100%`)
    }

    this.pieChartTarget.style.background = `conic-gradient(${segments.join(", ")})`
  }

  updateSubmitButton(total) {
    if (total === 100) {
      this.submitButtonTarget.classList.remove("opacity-50", "pointer-events-none")
    } else {
      this.submitButtonTarget.classList.add("opacity-50", "pointer-events-none")
    }
  }

  // 趣味名の入力欄が空文字（スペースのみ含む）のときは、登録ボタンをグレーアウトして押せなくする
  updateAddButton() {
    if (this.nameInputTarget.value.trim() === "") {
      this.addButtonTarget.classList.add("opacity-50", "pointer-events-none")
    } else {
      this.addButtonTarget.classList.remove("opacity-50", "pointer-events-none")
    }
  }

  updateTotalColor(total) {
    if (total === 100) {
      this.totalWrapperTarget.classList.remove("text-ink-muted")
      this.totalWrapperTarget.classList.add("text-accent-dark")
    } else {
      this.totalWrapperTarget.classList.remove("text-accent-dark")
      this.totalWrapperTarget.classList.add("text-ink-muted")
    }
  }
}
