class Article < ActiveRecord::Base
  class << self
    def mail(list, count)
      article = find_by_hidden_and_list_and_count(false, list, count)
      TMail::Mail.load(article.path)
    end
  end
end
