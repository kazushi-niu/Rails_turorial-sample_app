require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    # テスト前にログインする
    log_in_as(@user)
    # @userの編集ページにアクセス
    get edit_user_path(@user)
    # ＠userの編集画面が描画されるか？描画されたら→true
    assert_template 'users/edit'
    # 無効な編集データを送信
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    # @userの編集画面が再描画されるのか？描画されたら→true
    assert_template 'users/edit'
    # 正しい数のエラーメッセージが表示されているのか
    assert_select "div.alert", "The form contains 4 errors."
    assert_select "div#error_explanation"
    assert_select "div.alert-danger"
    assert_select "div.field_with_errors"
  end
  
  test "successful edit" do
    # テスト前にログインする
    log_in_as(@user)
    # 編集ページにアクセス
    get edit_user_path(@user)
    # 編集ページが表示されるか？
    assert_template 'users/edit'
    # 名前を変更
    name  = "Foo Bar"
    # emailアドレスを変更
    email = "foo@bar.com"
    # 変更内容を送信
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    # フラッシュが表示されるか？ 表示されればGREEN
    assert_not flash.empty?
    # ユーザーページにリダイレクトされるか？
    assert_redirected_to @user
    # データベースを再読み込み
    @user.reload
    # 名前は正しく変更されているか？
    assert_equal name,  @user.name
    # emailは正しく変更されているか？
    assert_equal email, @user.email
  end
  
  # フレンドリーフォワーディングのテスト
  test "successful edit with friendly forwarding" do
    # 編集ページへアクセス
    get edit_user_path(@user)
    # リクエスト時点のページを保存できているか？
    assert_equal edit_user_url(@user), session[:forwarding_url]
    # @userとしてログイン
    log_in_as(@user)
    # session[:forwarding_url]は削除されているのか？
    assert_nil session[:forwarding_url]
    # 編集画面にリダイレクトされるか？
    assert_redirected_to edit_user_url(@user)
    # 名前を更新
    name  = "Foo Bar"
    # メールを更新
    email = "foo@bar.com"
    # 編集内容を送信
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    # フラッシュは出ているか？
    assert_not flash.empty?
    # ユーザーページにリダイレクトされるか？
    assert_redirected_to @user
    # DBからユーザー情報を取得
    @user.reload
    # 名前は変更されているか？
    assert_equal name,  @user.name
    # メールは変更されているか？
    assert_equal email, @user.email
  end
end