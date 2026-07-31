class PattertnCCalculator.rb
  def initialize(target_times:)
    # 目標時間をインスタンス変数化
    @target_ties = target_times
  end

  def self.call(target_times:)
    # 目標時間だけを引数でもらってくる（向きは不要）
    new(target_times: target_times).call
  end

  def call
    # 算出ロジックCを呼び出し（これを返り値とする）
    pattern_c_calculator
  end

  private

  def pattertn_c_calculator
    # 趣味と自由時間を全件リストで取得
    hobby_all = Hooby.all
    freetime_all = FreeTime.all

    # 曜日のソートを行う（day_of_weekの昇順：同値はないので第二条件なし）
    sort_days = freetime_all.sort_by { |ft|[ ft.day_of_week ] }
    
    # 趣味の並び替え（割合の降順：同値ならidの昇順）
    sort_hobbies = hobby_all.sort_by { |hobby|[ -hobby.percentage, hobby.id ] }

    # １週間分の曜日スロットを作成（曜日の残り枠として管理する）
    days_slot = freetime.all.each_with_object({}) do |ft, hash|
      # データ構造：{ FreeTimeオブジェクト => 120min, FreeTimeオブジェクト => 90, ... }
      hash[ft] = ft.minutes
    end
    
    # 各趣味の目標時間スロットを用意（目標時間の残り枠として管理する）
    target_times_slot = @taget_time.dup

    # 曜日と趣味用の添字を用意する
    day_index = 0
    hobby_index = 0

    # スケジュールスロットの空き箱を作成（最終的な返り値とする）
    hobby_schedule = hobby_all.each_with_object({}) do |hobby, hash|
      # データ構造：{Hobbyオブジェクト => {}}この空いた{}にデータを詰めていく
      hash[hobby] = {}
    end
  end
end
