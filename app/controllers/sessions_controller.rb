class SessionsController < ApplicationController
  def new
  end
  
  def create
    # form_forから送られてきたemailを持つユーザーを探してuserに代入
     user = User.find_by(email: params[:session][:email].downcase)
    # userか存在して、userのパスワードが送られてきたものと一致するか
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in user
      redirect_to user
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination' 
      render 'new'
    end
  end
  
  def destroy
    log_out
    redirect_to root_url
  end
end
