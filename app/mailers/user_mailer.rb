class UserMailer < ApplicationMailer

  def account_activation(user)
    # インスタンス変数を定義
    @user = user
    # user.emailにタイトルが"Account activation"のメールを送信
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    # インスタンス変数を定義→ビューでも@userを使えるようになる
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end