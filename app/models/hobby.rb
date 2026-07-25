class Hobby < ApplicationRecord
  # 趣味の名前：空NG
  validates :name, presence: true
  # 割合：空NG、数字チェック（整数かつ1~100までの数字のみを許可)
  validates :percentage,
            presence: true,
            numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
end
