class FreeTime < ApplicationRecord
  belongs_to :user

  # 曜日の日本語訳リスト
  DAYS = %w[日 月 火 水 木 金 土].freeze

  # 曜日（空NG、0~6までの数字=曜日番号のみ許可、同じユーザー内で重複してはいけない）
  validates :day_of_week, presence: true, inclusion: { in: 0..6 }, uniqueness: { scope: :user_id }
  # 分数（空NG、整数のみ 0以上のみ許可）
  validates :minutes,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # 数字を日本語訳と対応させるメソッド
  def day_name
    # DAYS配列から、day_of_weekの数値（添字）に対応する曜日名を取り出す
    DAYS[day_of_week]
  end
end
