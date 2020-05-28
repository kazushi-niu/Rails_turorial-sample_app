class SessionsController < ApplicationController
  def new
  end
  
  def create
    # form_forから送られてきたemailを持つユーザーを探してuserに代入
    @user = User.find_by(email: params[:session][:email].downcase)
    # userか存在して、userのパスワードが送られてきたものと一致するか
    if @user && @user.authenticate(params[:session][:password])
      # userがactiveのとき
      if @user.activated?
        # ログインする
        log_in @user
        # :remember_meが１のとき@userを記憶、そうでなければuserを忘れる
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        # SessionsHelperで定義したredirect_back_orメソッドを呼び出して
        redirect_back_or @user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination' 
      render 'new'
    end
  end
  
  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
