class AccountActivationsController < ApplicationController
  
  def edit
    # Userテーブルから、URLのemailの値を持つuserを代入
    user = User.find_by(email: params[:email])
    # userが存在、userがアクティブでない、有効化トークンがダイジェストと一致した場合
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      # ログイン
      log_in user
      # フラッシュを表示
      flash[:success] = "Account activated!"
      # ユーザーページにリダイレクト
      redirect_to user
    else
      # フラッシュを表示
      flash[:danger] = "Invalid activation link"
      # トップページにリダイレクト
      redirect_to root_url
    end
  end
end
