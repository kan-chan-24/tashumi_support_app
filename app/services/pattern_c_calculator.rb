class PatternCCalculator
  def initialize(target_times:, free_times:)
    # 目標時間・自由時間をインスタンス変数に変換
    @target_times = target_times
    @free_times = free_times
  end

  def self.call(target_times:, free_times:)
    new(target_times: target_times, free_times: free_times).call
  end

  def call
    # 算出ロジックCを呼び出し（これを返り値とする）
    pattern_c_calculator
  end

  private

  def pattern_c_calculator
    # 趣味と自由時間のリストを全て取得しておく（ログイン中のユーザーの分だけ、呼び出し元から渡された値を使う）
    hobby_all = @target_times.keys
    freetime_all = @free_times

    # 曜日のソートを行う（day_of_weekの昇順：同値はないので第二条件なし）
    sort_days = freetime_all.sort_by { |ft|[ ft.day_of_week ] }

    # １週間分の曜日スロットを作成（曜日の残り枠として管理する）
    days_slot = freetime_all.each_with_object({}) do |ft, hash|
      # データ構造：{ FreeTimeオブジェクト => 120min, FreeTimeオブジェクト => 90, ... }
      hash[ft] = ft.minutes
    end

    # 各趣味の目標時間スロットを用意（目標時間の残り枠として管理する）
    target_times_slot = @target_times.dup

    # 曜日の添字を用意する
    day_index = 0

    # スケジュールスロットの空き箱を作成（最終的な返り値とする）
    hobby_schedule = hobby_all.each_with_object({}) do |hobby, hash|
      # データ構造：{Hobbyオブジェクト => {}}この空いた{}にデータを詰めていく
      hash[hobby] = {}
    end

    while day_index < sort_days.length # これからループ条件を埋めていく
      # 現在見ている曜日の更新（初期値は0）（趣味は一曜日ずつ網羅的に見ていく）
      current_day = sort_days[day_index]

      # 計算を終えた曜日を抜いたsort_daysを変数へ保存
      future_sumdays = sort_days.drop(day_index)

      # 一日の理想配分を求める(残り目標時間 * （1日の自由時間合計.to_f / １週間の"残り"自由時間合計）)
      allocate_hobbytime = hobby_all.each_with_object({}) do |hobby, hash|
        # データ構造：{Hobbyオブジェクト => 46.6..., Hobbyオブジェクト => 36.6...,}のイメージ
        hash[hobby] = target_times_slot[hobby] * (days_slot[current_day].to_f / future_sumdays.sum(&:minutes))
      end

      # 丸め処理用のタイブレークproc
      hobby_tiebreak = ->(hobby) { [ -hobby.percentage, hobby.id ] }

      # 丸め処理を行う（救済処置はしない）
      adjust_target_times = TargetTimesAdjuster.call(total_time: days_slot[current_day], target_times: allocate_hobbytime, tiebreaker: hobby_tiebreak)

      # 配分時間を引き、残りの目標時間を出す
      target_times_slot.each do |hobby, hash|
        # 現在のHobbyオブジェクトの値(slot側) - 現在のHobbyオブジェクトの値(adjust側)
        target_times_slot[hobby] -= adjust_target_times[hobby]
      end

      # スケジュールスロット（返り値）に分配時間を入れていく
      hobby_schedule.each do |hobby, hash|
        # データ構造：{Hobbyオブジェクト => {"月" => 30},Hobbyオブジェクト => {"月" => 15},...}
        hobby_schedule[hobby][current_day] = adjust_target_times[hobby]
      end

      # 曜日添字の更新
      day_index += 1
    end

    # 最後に完成したスケジュールを返す
    hobby_schedule
  end
end
