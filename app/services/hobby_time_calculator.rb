class HobbyTimeCalculator
 # 自由時間が足りない場合のエラーを定義（特別な処理は特になし）
 class NotEnoughFreeTimeError < StandardError; end

 # new時に引数をインスタンス変数に変換
 def initialize(hobbies:, free_times:)
  # 趣味の割合
  @hobbies = hobbies
  # １週間の自由時間
  @free_times = free_times
 end

 # インスタンスをnewして.callを呼び、その結果をそのまま返すだけ（外部からの窓口役）
 def self.call(hobbies:, free_times:)
  # 引数をnewして、initialize発動（引数をインスタンス変数として保存=材料化）
  # .callでcallインスタンスメソッドを呼び出し
  new(hobbies: hobbies, free_times: free_times).call
 end

 # 計算処理の入り口（クラス内部のメソッド呼び出し役）
 def call
  # step1の呼び出し(自由時間合計を算出)
  total = total_free_time

  # step2の呼び出し（自由時間合計が分配に足りているかを判定）
  free_time_sufficient_for_hobbies!(total)
  
  # step3の呼び出し（各趣味の丸め前の目標時間を出す）
  target_times = target_times_calculator(total)

  # step4の呼び出し(各趣味の丸め後の目標時間を出す）
  adjust_target_times = target_times_adjuster(total,target_times)
  
  # step5の呼び出し（0分趣味の救済措置）
  rescue_zero_hobbies(adjust_target_times)
 end
 
 private
 
 # step1:自由時間の合計を算出
 def total_free_time
  # free_timeの分数の合計を返す
  @free_times.sum do |ft|
    ft.minutes
  end
 end

 # step2:自由時間合計が趣味の数に対して最低限登録されているか
 def free_time_sufficient_for_hobbies!(total_time)
  if (@hobbies.length * 15) > total_time
    raise NotEnoughFreeTimeError, "自由時間を合計#{@hobbies.length * 15}分以上設定してください"  
  end
 end

 # step3:合計時間に各趣味の割合をかけ、各趣味の目標時間を出す（丸めはstep4へ委託）
 def target_times_calculator(total_time)
  # 各趣味の目標時間がハッシュ形式で返される
  @hobbies.each_with_object({}) do |hobby, hash|
    # 自由時間合計 * 配分％ = 各趣味の目標時間（小数点ありで返り値を出す）
    hash[hobby] = total_time * (hobby.percentage / 100.0)
  end
 end
 
 # step4:各趣味の目標時間の丸め処理（15分単位で値を扱いやすくする）
 def target_times_adjuster(total_time,target_times)
  # 4.1:全体の目標単位を出す(割り切れる数字）
  total_quarter_hour_count = total_time / 15

  # 4.2:各趣味の単位数を出し、ローカル変数へ入れる（確定部分と端数で分ける）
  target_times_hash = target_times.each_with_object({}) do |(hobby,time), hash|
    # 暫定で小数点のついた単位を出す
    float_quarter_hour_count = time / 15
    
    # 単位確定部分として整数部分を抜き出す
    int_quarter_hour_count = float_quarter_hour_count.truncate

    # 端数部分を抜き出す（比較に使う）
    float_quarter_hour_count = float_quarter_hour_count - int_quarter_hour_count

    hash[hobby] = {"確定単位" => int_quarter_hour_count, "端数" => float_quarter_hour_count}
  end

  # 4.3:各趣味の目標単位の確定部分(整数部）合計を出す
  total_int_quarter_hour_count = target_times_hash.values.sum do |info|
    info["確定単位"]
  end
  
  # 4.4:余っている単位を出す（全体の単位数 - 確定単位数）
  remaining_int_quarter_hour_count = total_quarter_hour_count - total_int_quarter_hour_count

  # 4.5:端数を数値が大きい順にソートする
  sort_target_times_hash = target_times_hash.sort_by{|hobby, info|[-info["端数"], -hobby.percentage, hobby.id]}
  
  # 4.6:ソートした上から順に、余った単位を確定単位に+1していく
  # 余った単位数分のハッシュを取り出す
  pick_target_times_hash = sort_target_times_hash.first(remaining_int_quarter_hour_count)

  # 確定単位に+1していく
  pick_target_times_hash.each do |hobby, info|
    info["確定単位"] += 1
  end

  # 4.7:単位数から時間（分）に変換して返す
  target_times_hash.transform_values{|info| info["確定単位"] * 15}
 end

 # step5:0分の趣味の時間があった場合の救済措置（15分分配）
 def rescue_zero_hobbies(target_times)
  # 趣味の目標時間の値に、0が存在する間繰り返す
  while target_times.value?(0)
    # 0分の趣味を1つ見つける
    zero_hobby, _ = target_times.find{|hobby, time| time == 0}

    # 趣味目標時間をソート（時間が多い順、同値なら%昇順、さらに同値ならid降順）
    sort_target_times = target_times.sort_by{|hobby, time|[-time, hobby.percentage, -hobby.id]}
    # ソートしたtarget_timesから、Top1を抜き取る
    top_hobby, _ = sort_target_times.first

    # リストの一番上の目標時間を-15分
    target_times[top_hobby] -= 15
    # 0分の目標時間に+15分
    target_times[zero_hobby] += 15
  end
  target_times
 end
end
