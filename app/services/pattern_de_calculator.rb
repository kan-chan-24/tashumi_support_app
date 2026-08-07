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
      # 現在のグループ内最小の残り時間を取得
      min_chunk_ft = current_chunk.min_by{ |ft| days_slot[ft] }
      
      # フェアシェアがグループ内の最小残り時間に収まるかどうか
      if fairshare <= days_slot[min_chunk_ft]
        # 収まる場合：グループの全日にフェアシェアを丸め処理して配分
        fairshare_scheduler(chunk: current_chunk, fair_share: fairshare, chunk_hobby: chunk_hobby, days_slot: days_slot, target_times_slot: target_times_slot, hobby_schedule_hash: hobby_schedule[chunk_hobby])
                  
      else
        # カスケード処理
        
        # グループ内の確定曜日チェックリスト（割り当て時間が決まった曜日から取り除いていく）
        dup_chunk = current_chunk.dup
        # 対象曜日が残っている かつ 趣味残り時間が残っている
        while !dup_chunk.empty? && target_times_slot[chunk_hobby] > 0
          # 対象曜日リストの中で最小残り時間の曜日を探す（返り値はfreetimeオブジェクト)
          min_chunk_ft = dup_chunk.min_by{ |ft| days_slot[ft] }
          # フェアシェアの再計算をループごとに行う
          re_fairshare = fair_share_calculator(target_times_slot[chunk_hobby], dup_chunk, days_slot)

          # フェアシェアと最小残り時間曜日を比較
          if re_fairshare <= days_slot[min_chunk_ft]
            # 収まる場合：均等配分
            fairshare_scheduler(chunk: dup_chunk, fair_share: re_fairshare, chunk_hobby: chunk_hobby, days_slot: days_slot, target_times_slot: target_times_slot, hobby_schedule_hash: hobby_schedule[chunk_hobby])
          else
            # 収まらない場合：最小曜日だけを確定させ、対象曜日リストから取り除く


          end
        end
      end
    else
      # 現在の首位趣味と次点趣味の比率でグループ内の枠を分ける
    end
  end

  # フェアシェアの計算メソッド
  def fair_share_calculator(remaining_time, group, days_slot)
    # 枠が残っている曜日の数を数える
    group_count = group.count { |gp| days_slot[gp] > 0 }

    # フェアシェアを計算する
    fair_share = remaining_time.to_f / group_count
  end

  # グループ内でフェアシェア均等配分メソッド（フェアシェアがグループ内で収まるときに使用するメソッド）
  def fairshare_scheduler(chunk:, fair_share:, chunk_hobby:, days_slot:, target_times_slot:, hobby_schedule_hash:)
    # 曜日に紐づけたフェアシェア同値のハッシュを用意する
    days_fairshare = chunk.each_with_object({}) do |ft, hash|
      hash[ft] = fair_share
    end        
    # TargetTimesAdjusterに渡すためのタイブレーク条件を用意
    freetime_tiebreak = ->(ft) { [ ft.day_of_week ] }
    # 丸め処理呼び出し
    adjust_target_times  = TargetTimesAdjuster.call(total_time: target_times_slot[chunk_hobby], target_times: days_fairshare, tiebreaker: freetime_tiebreak)
    # 丸めた結果をスケジュールに割り当てる
    adjust_target_times.each do |ft, minutes|
      # 趣味キーのスケジュールに曜日=>分の形で丸め後の目標時間を割り当てる
      hobby_schedule_hash[ft] = minutes
      # 曜日ごとの自由時間を配分した分数だけ減らす
      days_slot[ft] -= minutes
      # 趣味ごとの目標時間を配分した分数だけ減らす
      target_times_slot[chunk_hobby] -= minutes
    end
  end
end
