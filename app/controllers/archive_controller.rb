class ArchiveController < ApplicationController
  before_filter :require_login
  caches_action :show
  include ArchiveHelper
  unloadable

  def show
    @mail = Article.mail(*article(params[:id]))
    if part = params[:part]
      data = @mail.parts[Integer(part)]
      send_data(data.body, :type => data.content_type, :filename => data.disposition_param("filename"))
      return true
    end
  rescue
    render :inline => "<%= content_tag(:h2, l(:article_not_found)) %>", :layout => true
  end
end
