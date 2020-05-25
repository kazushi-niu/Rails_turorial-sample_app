require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    # 管理ユーザーとしてログイン
    log_in_as(@admin)
    # ユーザーindexページにアクセス
    get users_path
    # indexページが表示されるか？
    assert_template 'users/index'
    # ページネーションが表示されるか？
    assert_select 'div.pagination'
    # ページネーションUserに１ページ目を代入
    first_page_of_users = User.paginate(page: 1)
    # ページネーションの内容について確認
    first_page_of_users.each do |user|
      # ユーザー名のリンクボタンが表示されるか？
      assert_select 'a[href=?]', user_path(user), text: user.name
      # 非管理ユーザー出ない場合
      unless user == @admin
        # 削除ボタンが表示されるか？
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    # 削除リクエストを送信した後、user数が減っているか？
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    # 非管理ユーザーでログイン
    log_in_as(@non_admin)
    # ユーザーindexページにアクセス
    get users_path
    # 削除ボタンが表示されていないか？
    assert_select 'a', text: 'delete', count: 0
  end
end