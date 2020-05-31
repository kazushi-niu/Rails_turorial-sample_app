require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end

  # マイクロポストのUIテスト
  test "micropost interface" do
    # テストユーザーでログイン
    log_in_as(@user)
    # ルートパスにアクセス
    get root_path
    # ページネーションが表示されるか
    assert_select 'div.pagination'
    # 画像投稿用フォームが表示されるか
    assert_select 'input[type=file]'
    
    
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    # エラーメッセージが表示されるか
    assert_select 'div#error_explanation'
    
    
    # 有効な送信
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, picture: picture } }
    end
    # 画像は投稿されたか
    assert assigns(:micropost).picture?
    # ルートページにリダイレクトされるか
    assert_redirected_to root_url
    # 指定されたリダイレクト先に移動
    follow_redirect!
    # HTML本文の中にcontentが含まれている
    assert_match content, response.body
    
    
    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    
    # 違うユーザーのプロフィールにアクセス (削除リンクがないことを確認)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
  
  
  # サイドバーにあるマイクロポストの合計投稿数をテスト
  test "micropost sidebar count" do
    # テストユーザーとしてログイン
    log_in_as(@user)
    # ルートページにアクセス
    get root_path
    # HTML本文にmicropostsが表示される
    assert_match "#{@user.microposts.count} microposts", response.body
    
    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    # 他のテストユーザーでログイン
    log_in_as(other_user)
    # ルートページにアクセス
    get root_path
    # HTML本文に「0 microposts」が表示されるか
    assert_match "0 microposts", response.body
    # 有効なマイクロポストを投稿
    other_user.microposts.create!(content: "A micropost")
    # ルートページにアクセス
    get root_path
    # HTML本文に「1 micropost」が表示されるか
    assert_match "1 micropost", response.body
  end
end
