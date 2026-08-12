class ResultsController < ApplicationController
  def show
    # 目標時間を導き出す
    target_times = HobbyTimeCalculator.call(hobbies: Hobby.all, free_times: FreeTime.all)

    # パターンAを呼び出し保存
    pattern_a = PatternAbCalculator.call(target_times: target_times, sort_direction: :desc)
    # パターンB
    pattern_b = PatternAbCalculator.call(target_times: target_times, sort_direction: :asc)
    # パターンC
    pattern_c = PatternCCalculator.call(target_times: target_times)
    # パターンD
    pattern_d = PatternDeCalculator.call(target_times: target_times, sort_direction: :desc)
    # パターンE
    pattern_e = PatternDeCalculator.call(target_times: target_times, sort_direction: :asc)

    # 5パターンをまとめてハッシュにする
    @patterns = {
      "A" => { catchphrase: "...", schedule: pattern_a },
      "B" => { catchphrase: "...", schedule: pattern_b },
      "C" => { catchphrase: "...", schedule: pattern_c },
      "D" => { catchphrase: "...", schedule: pattern_d },
      "E" => { catchphrase: "...", schedule: pattern_e }
    }

    # 提案パターンを表にするときに基準にする曜日順リストを生成しておく
    @sorted_free_times_by_day = FreeTime.order(:day_of_week)
  end
end
