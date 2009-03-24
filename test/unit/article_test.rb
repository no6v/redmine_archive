require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < ActiveSupport::TestCase
  fixtures :articles

  def test_mail
    article, mail = Article.mail("test", 1)
    assert_instance_of ::TMail::Mail, mail
  end
end
