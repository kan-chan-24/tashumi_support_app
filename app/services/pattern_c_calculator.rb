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
    
  end
end
