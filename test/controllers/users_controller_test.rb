require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "should get new" do
    get signup_path
    assert_response :success
  end
  
  # ログインしていない状況で編集ページにアクセスする
  test "should redirect edit when not logged in" do
    # 編集ページにアクセス
    get edit_user_path(@user)
    # フラッシュが発生しているか？
    assert_not flash.empty?
    # ルートページにリダイレクトされるか？
    assert_redirected_to login_url
  end

  # ログインしていない状況でユーザー情報を編集する
  test "should redirect update when not logged in" do
    # 編集内容を送信
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    # フラッシュが発生しているか？
    assert_not flash.empty?
    # ルートページにリダイレクトされるか？
    assert_redirected_to login_url
  end
  
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
                                    user: { password:              @other_user.password,
                                            password_confirmation: @other_user.password_confirmation,
                                            admin: true } }
    assert_not @other_user.reload.admin?
  end
  
  # 間違ったユーザーの編集画面を表示しようとする
  test "should redirect edit when logged in as wrong user" do
    # @other_userでログイン
    log_in_as(@other_user)
    # @userの編集画面にアクセス
    get edit_user_path(@user)
    # flashは表示されるか？
    assert flash.empty?
    # ルートページにリダイレクトされるか？
    assert_redirected_to root_url
  end
  
  # 間違ったユーザー情報を編集しようとする
  test "should redirect update when logged in as wrong user" do
    # @other_userでログイン
    log_in_as(@other_user)
    # 間違ったユーザーの編集内容を送信する
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    # flashは表示されるか？
    assert flash.empty?
    # ルートページにリダイレクトされるか？
    assert_redirected_to root_url
  end
  
  test "should redirect index when not logged in" do
    # ログインしていない状態でindexページにアクセス
    get users_path
    assert_redirected_to login_url
  end
  
  # ログインしていない状態で削除リクエストを送信
  test "should redirect destroy when not logged in" do
    # DELETEリクエストを送信前後でユーザー数が変わらないか？
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    # login画面にリダイレクトされるか？
    assert_redirected_to login_url
  end

  # 管理ユーザーとは違うユーザーで削除リクエストを送信
  test "should redirect destroy when logged in as a non-admin" do
    # 非管理ユーザーとしてログイン
    log_in_as(@other_user)
    # DELETEリクエストを送信前後でユーザー数が変わらないか？
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    # login画面にリダイレクトされるか？
    assert_redirected_to root_url
  end
  
  # ログインしていない状態ではfollowingページにアクセスできない
  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  # ログインしていない状態ではfollowerページにアクセスできない
  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
