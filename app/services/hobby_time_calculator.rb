class HobbyTimeCalculator
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
  # step1の呼び出し(total_free_time)
  total = total_free_time
 end
 
 private
 
 # step1:自由時間の合計を算出
 def total_free_time
  # free_timeの分数の合計を返す
  @free_times.sum do |ft|
    ft.minutes
  end
 end 
end
