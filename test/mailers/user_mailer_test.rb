require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    # テスト用ユーザーを代入
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    # アカウント認証メールとmail.subjectが等しいか？
    assert_equal "Account activation", mail.subject
    # user.mailとmail.toが等しいか？
    assert_equal [user.email], mail.to
    # noreply@example.comとmail.formが正しいか？
    assert_equal ["noreply@example.com"], mail.from
    # user.nameが本文に含まれているか？
    assert_match user.name,               mail.body.encoded
    # user.actication_tokenが本文に含まれているか？
    assert_match user.activation_token,   mail.body.encoded
    # 特殊文字をエスケープしたuser.mailが本文に含まれているか？
    assert_match CGI.escape(user.email),  mail.body.encoded
  end
end