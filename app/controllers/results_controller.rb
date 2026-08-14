class ResultsController < ApplicationController
  def show
    # 目標時間を導き出す
    target_times = HobbyTimeCalculator.call(hobbies: Current.user.hobbies, free_times: Current.user.free_times)

    # パターンAを呼び出し保存
    pattern_a = PatternAbCalculator.call(target_times: target_times, free_times: Current.user.free_times, sort_direction: :desc)
    # パターンB
    pattern_b = PatternAbCalculator.call(target_times: target_times, free_times: Current.user.free_times, sort_direction: :asc)
    # パターンC
    pattern_c = PatternCCalculator.call(target_times: target_times, free_times: Current.user.free_times)
    # パターンD
    pattern_d = PatternDeCalculator.call(target_times: target_times, free_times: Current.user.free_times, sort_direction: :desc)
    # パターンE
    pattern_e = PatternDeCalculator.call(target_times: target_times, free_times: Current.user.free_times, sort_direction: :asc)

    # 5パターンをまとめてハッシュにする
    @patterns = {
      "A" => { catchphrase: "時間をかけたいことは、時間のある日に。", schedule: pattern_a },
      "B" => { catchphrase: "時間をかけたいことは、毎日の日課に。", schedule: pattern_b },
      "C" => { catchphrase: "やりたいことを、毎日少しずつ。", schedule: pattern_c },
      "D" => { catchphrase: "時間のある日に、好きなことを分け合おう。", schedule: pattern_d },
      "E" => { catchphrase: "毎日の日課に、好きなことを分け合おう。", schedule: pattern_e }
    }

    # 提案パターンを表にするときに基準にする曜日順リストを生成しておく
    @sorted_free_times_by_day = Current.user.free_times.order(:day_of_week)
  end
end
