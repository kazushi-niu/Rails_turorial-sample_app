require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    # プロフィールページにアクセス
    get user_path(@user)
    # users/showページが表示されるか
    assert_template 'users/show'
    # タイトルは正しいか
    assert_select 'title', full_title(@user.name)
    # h1タグに@user.nameが挟まれているか
    assert_select 'h1', text: @user.name
    # h1タグの内側にあるimgタグにgravatarが存在するのか
    assert_select 'h1>img.gravatar'
    # ユーザーのマイクロポスト数がHTML本文に入っているか
    assert_match @user.microposts.count.to_s, response.body
    # ページネーションクラスが存在するか
    assert_select 'div.pagination', count: 1
    # マイクロポストの１ページ目の内容
    @user.microposts.paginate(page: 1).each do |micropost|
      # マイクロポストの内容がHTML本文に入っているのか
      assert_match micropost.content, response.body
    end
  end
end