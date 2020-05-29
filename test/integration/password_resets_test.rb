require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    # 配列に保存されたメールを削除
    ActionMailer::Base.deliveries.clear
    # テストユーザーとしてログイン
    @user = users(:michael)
  end
  
  test "password resets" do
    # 新しいパスワード設定画面へアクセス
    get new_password_reset_path
    # 新しいパスワード設定画面が表示されるか
    assert_template 'password_resets/new'
    
    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "" } }
    # flashはからでないか？　空でないならGREEN
    assert_not flash.empty?
    # 新しいパスワード設定画面が表示されるか
    assert_template 'password_resets/new'
    
    # メールアドレスが有効
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    # reset_digestが変化するか
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    # 配列にメールが1件挿入されているか（→メールが送信されるか）
    assert_equal 1, ActionMailer::Base.deliveries.size
    # flashは表示されるか
    assert_not flash.empty?
    # rootページにリダイレクトされるか
    assert_redirected_to root_url
    
    
    # パスワード再設定フォームのテスト
    # assignsでユーザーに@userを代入→モデルのattr_accessorを使用できるようになる
    user = assigns(:user)
    
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "")
    # ルートページにリダイレクトされるか
    assert_redirected_to root_url
    
    # 無効なユーザー
    # userのactivatedを反転、ノンアクティブに変更
    user.toggle!(:activated)
    # 新しいパスワードを送信
    get edit_password_reset_path(user.reset_token, email: user.email)
    # ルートページにリダイレクトされるか
    assert_redirected_to root_url
    # userをアクティブ状態に戻す
    user.toggle!(:activated)
    
    # メールアドレスが有効で、トークンが無効
    get edit_password_reset_path('wrong token', email: user.email)
    # ルートページにリダイレクトされるか
    assert_redirected_to root_url
    
    # メールアドレスもトークンも有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    # パスワード変更用ページにアクセス
    assert_template 'password_resets/edit'
    # 隠しフォームにメールアドレスが入っているか
    assert_select "input[name=email][type=hidden][value=?]", user.email
    
    # 無効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "barquux" } }
    # エラーメッセージが表示されているか
    assert_select 'div#error_explanation'
    
    # パスワードが空
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "",
                            password_confirmation: "" } }
    # エラーメッセージが表示されるか
    assert_select 'div#error_explanation'
    
    # 有効なパスワードとパスワード確認
    patch password_reset_path(user.reset_token),
          params: { email: user.email,
                    user: { password:              "foobaz",
                            password_confirmation: "foobaz" } }
    # ダイジェストはnilになっているか
    assert_nil user.reload.reset_digest
    # ログインしているか
    assert is_logged_in?
    # flashは表示されているか
    assert_not flash.empty?
    # userページにリダイレクトされるか
    assert_redirected_to user
  end
  
  # 再設定トークンが無効な場合のテスト
  test "expired token" do
    # パスワード再設定フォームにアクセス
    get new_password_reset_path
    # 有効なメールアドレスを入力
    post password_resets_path,
         params: { password_reset: { email: @user.email } }

    
    @user = assigns(:user)
    # @userのreset_sent_atを3時間後に変更
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    # 新しいパスワードを送信
    patch password_reset_path(@user.reset_token),
          params: { email: @user.email,
                    user: { password:              "foobar",
                            password_confirmation: "foobar" } }
    # レスポンスはリダイレクトか
    assert_response :redirect
    # POSTの送信結果に沿ってリダイレクト先に移動
    follow_redirect!
    # response.bodyに"expired"という文字があるのか
    assert_match /expired/i, response.body
  end
end