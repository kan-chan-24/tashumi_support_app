module HobbiesHelper
  # 円グラフのセグメントに使う色（落ち着いたトーンで色相違いの6色）
  # 趣味の数が増えても対応できるよう、6色を超えたら先頭から繰り返す
  PIE_CHART_COLORS = %w[
    #9cab84
    #c2a97c
    #b79cc2
    #7ca6c2
    #c27c8e
    #7cc2ae
  ].freeze

  # 趣味一覧（hobby.percentageを持つ配列）から、円グラフ用のconic-gradient文字列を生成する
  # percentageの算出方法（手動入力／将来の自動均等割り）に依存せず、値をそのまま使うだけの設計
  def hobby_pie_chart_gradient(hobbies)
    return "conic-gradient(var(--color-border-soft) 0% 100%)" if hobbies.empty?

    current_angle = 0
    segments = hobbies.each_with_index.map do |hobby, index|
      color = PIE_CHART_COLORS[index % PIE_CHART_COLORS.length]
      next_angle = current_angle + hobby.percentage
      segment = "#{color} #{current_angle}% #{next_angle}%"
      current_angle = next_angle
      segment
    end

    "conic-gradient(#{segments.join(', ')})"
  end

  # 趣味と円グラフの色を対応させた凡例用データを返す
  def hobby_pie_chart_legend(hobbies)
    hobbies.each_with_index.map do |hobby, index|
      { hobby: hobby, color: PIE_CHART_COLORS[index % PIE_CHART_COLORS.length] }
    end
  end
end
