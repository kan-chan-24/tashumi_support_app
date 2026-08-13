module ResultsHelper
  # 1パターン分のスケジュール表を返す
  def schedule_creator(schedule, week_list)
    # スケジュールの趣味キーを、配分％が高い順にソートする
    sorted_hobby_keys_schedule = schedule.keys.sort_by { |hobby| [ -hobby.percentage, hobby.id ] }
    # 趣味ごとに、曜日順リストを7曜日分たどり、値を取得する
    # 外側.趣味でループする（map）
    sorted_hobby_keys_schedule.map do |hobby|
      # 内側.7曜日分の曜日でループする（each_with_object）
      day_min_set = week_list.each_with_object({}) do |ft, days_hash|
        # 値がnil or 0なら❌　それ以外は"〇〇分"と文字列に変換する
        # FreeTime.day_nameメソッドで、日〜土をdaysハッシュのキーとする
        if schedule[hobby][ft] == 0 || schedule[hobby][ft].nil?
          # [{ hobby: 趣味オブジェクト, days: { "月" => "❌", ... } }, ...]という構成になる
          days_hash[ft.day_name] = "❌"
        else
          # [{ hobby: 趣味オブジェクト, days: { "月" => "90分", ... } }, ...]という構成になる
          days_hash[ft.day_name] = "#{schedule[hobby][ft]}分"
        end
      end
      hobby_schedule = { hobby: hobby, days: day_min_set }
    end
  end

  # 分数を「〇時間〇分」表記に変換する（曜日見出しの自由時間表示用）
  def free_time_label(minutes)
    hours = minutes / 60
    remainder = minutes % 60

    if hours.zero?
      "#{remainder}分"
    elsif remainder.zero?
      "#{hours}時間"
    else
      "#{hours}時間#{remainder}分"
    end
  end
end
