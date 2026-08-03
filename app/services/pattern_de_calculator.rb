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
  end

  def fair_share_test(remaining_time, group, days_slot)
    # 枠が残っている曜日の数を数える
    group_count = group.count { |gp| days_slot[gp] > 0 }

    # フェアシェアを計算する
    fair_share = remaining_time.to_f / group_count
  end
end
