Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # 趣味入力フォーム（一覧・登録・削除。登録は一覧画面のフォームから非同期で行う）
  resources :hobbies, only: [ :index, :create, :destroy ]

  # 自由時間入力フォーム
  resources :free_times, only: [ :index ] do
    # 7曜日を一括更新するオリジナルアクション
    collection do
      patch :update_all
    end
  end

  # スケジュール計算結果を表示するビュー
  resource :result, only: [ :show ]

  # 保存済みスケジュール（TOPページとしても表示する）
  resource :saved_schedule, only: [ :show, :create ]
  root "saved_schedules#show"
end
