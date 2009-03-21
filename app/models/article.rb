class Article < ActiveRecord::Base
  belongs_to :user

  class << self
    def mail(list, count)
      article = find_by_list_and_count(list, count)
      return article, TMail::Mail.load(article.path)
    end

    def enclose(list, count)
      find_by_list_and_count(list, count).tap do |article|
        return unless article
        article.hidden = true
        article.user = User.current
        article.save!
      end
    end

    def disclose(list, count)
      if article = find_by_list_and_count(list, count)
        article.hidden = false
        article.user = nil
        article.save!
      end
    end
  end
end
