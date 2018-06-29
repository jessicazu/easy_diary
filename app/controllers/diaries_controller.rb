class DiariesController < ApplicationController
  before_action :authenticate_user!

  def index
    # 現在のユーザーの日記
    diaries = current_user.diaries
    # ユーザーの登録日から、本日までの日付の範囲
    days = (Date.parse(current_user.created_at.strftime('%F'))..Date.today)

    # daysに対して、その日付の日記データがあれば、日付データと置き換える
    datas = days.map do |day|
      if diary = diaries.find { |d| Date.parse(d.created_at.strftime('%F')) == day }
        diary
      else
        day
      end
    end

    # ページネーションを実装
    @datas = Kaminari.paginate_array(datas.reverse).page(params[:page]).per(20)
  end

  def show
  end

end
