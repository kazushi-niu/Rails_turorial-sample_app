module SessionsHelper

  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # ユーザーのセッションを永続的にする
  def remember(user)
    # 永続セッションのためにユーザーをデータベースに記憶する
    user.remember
    # cookiesメソッドでcookiesに暗号化したユーザーIDを保存
    cookies.permanent.signed[:user_id] = user.id
    # cookiesメソッドでcookiesに暗号化した記憶トークンを保存
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end
  
  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end
  
  # 永続的セッションを破棄する
  def forget(user)
    # データベースから記憶トークンを削除
    user.forget
    # cookieからuser_idを削除
    cookies.delete(:user_id)
    # cookieから記憶トークンを削除
    cookies.delete(:remember_token)
  end
  
  # 現在のユーザーをログアウトする
  def log_out
    # 永続セッションを破棄する
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end