class HobbiesController < ApplicationController
  def index
    @hobbies = Hobby.order(:id)
    @hobby = Hobby.new
  end

  def create
    # スライダーで調整済みの暫定値を先にDBへ反映してから、最後尾の分割計算を行う
    update_existing_percentages

    last_hobby = Hobby.last

    # 趣味の登録がすでにある場合/ない場合
    if last_hobby
      # あるなら、最後尾の趣味の半分の％で趣味を追加する
      half_percentage = last_hobby.percentage / 2
      last_hobby.update(percentage: last_hobby.percentage - half_percentage)
      @hobby = Hobby.new(name: hobby_params[:name], percentage: half_percentage)
    else
      # ないなら、100%で入れる
      @hobby = Hobby.new(name: hobby_params[:name], percentage: 100)
    end

    if @hobby.save
      @hobbies = Hobby.order(:id)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to hobbies_path, notice: "趣味を登録しました" }
      end
    else
      redirect_to hobbies_path, alert: "趣味名を入力してください"
    end
  end

  def destroy
    # スライダーで調整済みの暫定値を先にDBへ反映してから削除する
    update_existing_percentages

    Hobby.find(params[:id]).destroy
    redirect_to hobbies_path, notice: "削除しました"
  end

  private

  def hobby_params
    # 趣味の名前を渡す
    params.require(:hobby).permit(:name)
  end

  # フォーム送信時にJavaScriptから送られてくる、既存の趣味の暫定的な配分％を
  # DBへ反映する（趣味の追加・削除で配分が変わる直前に必ず呼ぶ）
  def update_existing_percentages
    return unless params[:existing_percentages]

    params[:existing_percentages].each do |hobby_id, percentage|
      Hobby.find(hobby_id).update(percentage: percentage)
    end
  end
end
