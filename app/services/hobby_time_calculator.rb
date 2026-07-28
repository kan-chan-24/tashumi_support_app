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
end
