class PatternAbCalculator
  
  # newに呼応して発動
  def initialize(target_times:, sort_direction:)
    # インスタンス変数に変換
    @target_times = target_times
    @sort_direction = sort_direction
  end

  # 外部からこのクラスが呼ばれると最初に走るメソッド（目標時間リストとソートの向きが渡される）
  def self.call(target_times:, sort_direction:)
    new(target_times: target_times, sort_direction: sort_direction).call
  end

  # self.callからcallへ
  def call
    # 
    pattern_ab_calculator
  end

  private

  # 提案パターンABの計算処理メソッド
  def pattern_ab_calculator
    # 趣味と自由時間のリストを全て取得しておく
    hobby_all = Hobby.all
    freetime_all = FreeTime.all

    # 曜日の並び替え（自由時間の長い順：同値なら曜日番号）
    # sort_direcitonの値（シンボル）でソート方向を場合分けする
    if @sort_direction == :desc
      # 曜日の自由時間を降順にソートする（大きい → 小さい順）
      sort_days = freetime_all.sort_by{|ft|[-ft.minutes, ft.day_of_week]}
    elsif @sort_direction == :asc
      # 曜日の自由時間を昇順にソートする（小さい → 大きい順）
      sort_days = freetime_all.sort_by{|ft|[ft.minutes, ft.day_of_week]}
      # どちらの分岐でも、同値の場合に曜日番号の早い方を優先するのは同じ
    end

    # 趣味の並び替え（割合の多い順：同値なら登録の早い方）
    sort_hobbies = hobby_all.sort_by{|hobby|[-hobby.percentage, hobby.id]}

    # １週間分の曜日スロットを作成（曜日の残り枠として管理）
    schedule_slot = freetime_all.each_with_object({}) do |ft, hash|
      hash[ft] = ft.minutes
    end
    # 登録した分の趣味スロットを作成（趣味の残り枠として管理）
    target_times_slot = @target_times.dup

    # 曜日と趣味を見る添字を用意する
    day_index = 0
    hobby_index = 0

    # スケジュールスロットの空き箱を作成（最終的な返り値とする）
    hobby_schedule = hobby_all.each_with_object({}) do |hobby, hash|
      hash[hobby] = {}
    end

    # ループ（曜日の添字が曜日の数の内 かつ 趣味の添字が趣味の数の内はループする
    while day_index < sort_days.length && hobby_index < sort_hobbies.length
      # 現在見ている曜日と趣味の更新（初期値は0）
      current_day = sort_days[day_index]
      current_hobby = sort_hobbies[hobby_index]
    
      # 曜日の枠と目標時間の余り、小さい方の値を抜き取る
      min_slot = [schedule_slot[current_day], target_times_slot[current_hobby]].min

      schedule_slot[current_day] -= min_slot # 小さい方の値を曜日から引く
      target_times_slot[current_hobby] -= min_slot # 小さい方の値を趣味から引く
      
      # スケジュールスロット[趣味][曜日]の箇所に、小さい方の値を代入
      # スケジュールスロット{"ゲーム" => {"月" => 90}}のように対応させられる
      hobby_schedule[current_hobby][current_day] = min_slot

      if schedule_slot[current_day] == 0 # 曜日スロットが0 = 尽きている
        # 尽きた方のインデックスを進める
        day_index += 1
      end

      if target_times_slot[current_hobby] == 0 # 趣味スロットが0 = 尽きている
        # 尽きた方のインデックスを進める
        hobby_index += 1
      end
    end
    
    # 最終的なスケジュールスロットを返り値とする
    hobby_schedule
  end
end
