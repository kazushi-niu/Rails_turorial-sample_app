require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase

  # relationshipを作成
  def setup
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end

  # バリデーションが実行されるか
  test "should be valid" do
    assert @relationship.valid?
  end

  # follower_idがnilでバッシュされるか
  test "should require a follower_id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  # followed_idがnilでバッシュされるか
  test "should require a followed_id" do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end