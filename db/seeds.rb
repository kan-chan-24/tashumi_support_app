# 7曜日分ループをまわす
FreeTime::DAYS.each_index do |index|
  # day_of_weekカラムのレコードが存在するかチェック（存在しない = 初期化処理）
  FreeTime.find_or_create_by!(day_of_week: index) do |ft|
    # 今のループで扱っている曜日レコードのminutesに0をセットする（初期化）
    ft.minutes = 0
  end
end
