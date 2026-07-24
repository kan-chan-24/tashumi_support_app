class HobbiesController < ApplicationController
  def index
    @hobbies = Hobby.order(:id) 
  end

  def new
    @hobby = Hobby.new
  end

  def create
    @hobby = Hobby.new(hobby_params)
    if @hobby.save
      redirect_to hobbies_path, notice: "趣味を登録しました"
    else
      render :new, status: :unprocessable_entity 
    end
  end

  def destroy
    Hobby.find(params[:id]).destroy
    redirect_to hobbies_path, notice: "削除しました"
  end

  private

  def hobby_params
    # 趣味の名前と割合（%）を渡す
    params.require(:hobby).permit(:name, :percentage)
  end  
end
