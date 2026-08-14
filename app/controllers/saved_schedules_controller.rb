class SavedSchedulesController < ApplicationController
  def show
    # ログイン中のユーザーが持つスケジュールを取得（nilが入れば、まだ保存未実施ということ）
    @saved_schedule = Current.user.saved_schedule
  end

  def create
    # 空のスケジュール用の入れ物を用意する（既にあれば取得、なければ新しい入れ物を作る）
    saved_schedule = Current.user.saved_schedule || Current.user.build_saved_schedule

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
