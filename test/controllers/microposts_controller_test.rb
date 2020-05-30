require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  # ログインしない状態で投稿失敗するか
  test "should redirect create when not logged in" do
    # 前後でマイクロポストの数は変化しないか
    assert_no_difference 'Micropost.count' do
      # マイクロポストを投稿
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    # ルートページにリダイレクトされるか
    assert_redirected_to login_url
  end

  # ログインしない状態でマイクロポストの削除に失敗するか
  test "should redirect destroy when not logged in" do
    # 前後でマイクロポストの数は変化しないか
    assert_no_difference 'Micropost.count' do
      # 投稿を削除
      delete micropost_path(@micropost)
    end
    # ルートページにリダイレクトされるか
    assert_redirected_to login_url
  end
  
  # 間違ったユーザーによるマイクロポスト削除
  test "should redirect destroy for wrong micropost" do
    # テストユーザーでログイン
    log_in_as(users(:michael))
    # マイクロポストは別ユーザーのもの
    micropost = microposts(:ants)
    # マイクロポストの数が変化しないか
    assert_no_difference 'Micropost.count' do
      # マイクロポストを削除する →　失敗する
      delete micropost_path(micropost)
    end
    # ルートぺージにリダイレクトされるか
    assert_redirected_to root_url
  end
end