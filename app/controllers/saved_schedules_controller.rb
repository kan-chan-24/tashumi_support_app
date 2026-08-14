class SavedSchedulesController < ApplicationController
  def show
    # テーブルの最初の一件を取得（nilが入れば、まだ保存未実施ということ）
    @saved_schedule = SavedSchedule.first
  end

  def create
    # 空のスケジュール用の入れ物を用意する
    saved_schedule = SavedSchedule.first_or_initialize

    # paramsを受け取る
    saved_schedule.pattern_key = params[:pattern_key]
    saved_schedule.catchphrase =  params[:catchphrase]
    saved_schedule.schedule_data = JSON.parse(params[:schedule_data])

    # 選択したスケジュールをDBに保存する
    if saved_schedule.save
      redirect_to root_path, notice: "スケジュールをお気に入りしました"
    end
  end
end
