class TargetTimesAdjuster

  def initialize(total_time:, target_times:, tiebreaker:)
    @total_time = total_time
    @target_times = target_times
    @tiebreaker = tiebreaker
  end

  def self.call(total_time:, target_times:, tiebreaker:)
    new(total_time: total_time, target_times: target_times, tiebreaker: tiebreaker).call
  end

  def call
    target_times_adjuster
  end

  private

  def target_times_adjuster
    # 4.1:全体の目標単位を出す(割り切れる数字）
    total_quarter_hour_count = @total_time / 15

    # 4.2:各趣味の単位数を出し、ローカル変数へ入れる（確定部分と端数で分ける）
    target_times_hash = @target_times.each_with_object({}) do |(obj, time), hash|
      # 暫定で小数点のついた単位を出す
      float_quarter_hour_count = time / 15
 
      # 単位確定部分として整数部分を抜き出す
      int_quarter_hour_count = float_quarter_hour_count.truncate

      # 端数部分を抜き出す（比較に使う）
      float_quarter_hour_count = float_quarter_hour_count - int_quarter_hour_count
 
      hash[obj] = { "確定単位" => int_quarter_hour_count, "端数" => float_quarter_hour_count }
    end
    
    # 4.3:各趣味の目標単位の確定部分(整数部）合計を出す
    total_int_quarter_hour_count = target_times_hash.values.sum do |info|
      info["確定単位"]
    end

    # 4.4:余っている単位を出す（全体の単位数 - 確定単位数）
    remaining_int_quarter_hour_count = total_quarter_hour_count - total_int_quarter_hour_count

    # 4.5:ソートする（タイブレーク条件は@tiebreakerに準ずる）
    sort_target_times_hash = target_times_hash.sort_by { |obj, info|[ -info["端数"], @tiebreaker.call(obj) ] }

    # 4.6:ソートした上から順に、余った単位を確定単位に+1していく
    # 余った単位数分のハッシュを取り出す
    pick_target_times_hash = sort_target_times_hash.first(remaining_int_quarter_hour_count)
 
    # 確定単位に+1していく
    pick_target_times_hash.each do |obj, info|
      info["確定単位"] += 1
    end

    # 4.7:単位数から時間（分）に変換して返す
    target_times_hash.transform_values { |info| info["確定単位"] * 15 }
  end
end
