class FreeTimesController < ApplicationController
  def index
    @free_times = FreeTime.order(:day_of_week) 
  end

  def update_all
    # 入力された各曜日の自由時間を初期値（仮）から更新する
    params[:free_times].each do |day ,time |
      # day(id)を使って、該当するFreeTimeのレコードを1件探す
      @free_time =  FreeTime.find(day)
      #見つけたレコードのminutesを、timeから取り出した数字で更新する
      @free_time.update(minutes:time[:minutes]) 
    end
    redirect_to free_times_path, notice: "更新しました"
  end
end
