class SavedSchedulesController < ApplicationController
  def show
    # テーブルの最初の一件を取得（nilが入れば、まだ保存未実施ということ）
    @saved_schedule = SavedSchedule.first
  end
end
