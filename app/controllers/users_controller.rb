class UsersController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # 新規登録が成功したら、7曜日分のFreeTimeを初期作成する
      FreeTime::DAYS.each_index do |index|
        @user.free_times.create!(day_of_week: index, minutes: 0)
      end
      # 登録が成功したら、そのままログイン状態にする
      start_new_session_for @user
      redirect_to after_authentication_url, notice: "ようこそ、#{@user.nickname}さん！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:nickname, :password, :password_confirmation)
  end
end
