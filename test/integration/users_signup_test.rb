require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    # ユーザー登録ページにアクセス
    get signup_path
    # ブロックの実行前後でユーザー数が変わっていないことを確認
    assert_no_difference 'User.count' do
      #エラーが出るユーザー情報を送信
      post signup_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    # ユーザー登録ページが表示されることをテスト
    assert_template 'users/new'
    # ユーザー登録ページの送信先がsignup_pathになっているのか
    assert_select 'form[action="/signup"]'
    # エラーメッセージのテスト
    # id = "error_explanation"を持つdivが表示されるか
    assert_select 'div#error_explanation'
    # class = "field_with_errors"を持つdivが表示されるか
    assert_select 'div.field_with_errors'
  end
  
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    # flashメッセージに対するテスト
    assert_not flash.empty?
    assert is_logged_in?
  end
end