class PatternDeCalculator
  def initialize(target_times:, sort_direction:)
    @target_times = target_times
    @sort_direction = sort_direction
  end

  def self.call(target_times:, sort_direction:)
    new(target_times: target_times, sort_direction: sort_direction).call
  end

  def call
    pattern_de_calculator
  end

  private

  def pattern_de_calculator
    # 趣味と自由時間の全件を取得しておく
    hobby_all = Hobby.all
    freetime_all = FreeTime.all

    # 曜日のソート（ソートの向き引数で場合分け）
    if @sort_direction == :desc
      # 曜日の自由時間を降順にソートする（大きい → 小さい順）
      sort_days = freetime_all.sort_by { |ft|[ -ft.minutes, ft.day_of_week ] }
    elsif @sort_direction == :asc
      # 曜日の自由時間を昇順にソートする（小さい → 大きい順）
      sort_days = freetime_all.sort_by { |ft|[ ft.minutes, ft.day_of_week ] }
      # どちらの分岐でも、同値の場合に曜日番号の早い方を優先するのは同じ
    end

    # 趣味のソート(降順）
    sort_hobbies = hobby_all.sort_by { |hobby|[ -hobby.percentage, hobby.id ] }

    # 同値グループ化（前後で同値の曜日をグループ化する）
    chunk_days = sort_days.chunk_while { |i, j| i.minutes == j.minutes }.to_a

    # １週間分の曜日スロットを作成（曜日の残り枠として管理する）
    days_slot = freetime_all.each_with_object({}) do |ft, hash|
      # データ構造：{ FreeTimeオブジェクト => 120min, FreeTimeオブジェクト => 90, .    .. }
      hash[ft] = ft.minutes
    end
    
    # 各趣味の目標時間スロットを用意（目標時間の残り枠として管理する）
    target_times_slot = @target_times.dup

    # 最終的な返り値になるスケジュールスロットを作成
    hobby_schedule = hobby_all.each_with_object({}) do |hobby, hash|
      hash[hobby] = {}
    end

    # ループで使用する添字を定義
    chunk_index = 0

    # 1.同値グループの配列から順番にグループを取得する
    current_chunk = chunk_days[chunk_index]

    # 2.同値グループの先頭の.minutesをグループの代表値とする
    chunk_minutes = current_chunk.first.minutes

    # 3.配列の中で残り時間が1以上で、一番先頭にある趣味を取得
    chunk_hobby = sort_hobbies.find{  |hobby| target_times_slot[hobby] > 0 }

    # 4.フェアシェア計算処理を呼び出す
    fairshare = fair_share_calculator(target_times_slot[chunk_hobby], current_chunk, days_slot)

    # 5.フェアシェアが代表値に収まるかチェック
    if fairshare <= chunk_minutes
      # 曜日に紐づけたフェアシェア同値のハッシュを用意する
      days_fairshare = current_chunk.each_with_object({}) do |ft, hash|
        hash[ft] = fairshare
      end
      
      # TargetTimesAdjusterに渡すためのタイブレーク条件を用意
      freetime_tiebreak = ->(ft) { [ ft.day_of_week ] }
 
      # 丸め処理を呼び出し
      adjust_target_times  = TargetTimesAdjuster.call(total_time: target_times_slot[chunk_hobby], target_times: days_fairshare, tiebreaker: freetime_tiebreak)

      # 丸めた結果をスケジュールに割り当てる
      adjust_target_times.each do |ft, minutes|
        # 趣味キーのスケジュールに曜日=>分の形で丸め後の目標時間を割り当てる
        hobby_schedule[chunk_hobby][ft] = minutes

        # 曜日ごとの自由時間を配分した分数だけ減らす
        days_slot[ft] -= minutes
          
        # 趣味ごとの目標時間を配分した分数だけ減らす
        target_times_slot[chunk_hobby] -= minutes
      end
    else
   
    end
  end

  # フェアシェアの計算メソッド
  def fair_share_calculator(remaining_time, group, days_slot)
    # 枠が残っている曜日の数を数える
    group_count = group.count { |gp| days_slot[gp] > 0 }

    # フェアシェアを計算する
    fair_share = remaining_time.to_f / group_count
  end
end
