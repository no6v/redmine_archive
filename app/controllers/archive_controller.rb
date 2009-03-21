class ArchiveController < ApplicationController
  before_filter :require_login, :except => :disclose
  before_filter :require_admin, :only => :disclose
  caches_action :show
  include ArchiveHelper
  unloadable

  def show
    @article, @mail = Article.mail(*article(params[:id]))
    if part = params[:part]
      if @article.hidden?
        render :nothing => true
        return true
      end
      data = @mail.parts[Integer(part)]
      send_data(data.body, :type => data.content_type,
        :filename => data.disposition_param("filename", "unknown#{part}").toutf8)
      return true
    end
  rescue
    render :inline => "<%= content_tag(:h2, l(:article_not_found)) %>", :layout => true
  end

  def enclose
    if @article = Article.enclose(*article(params[:id]))
      expire_fragment(%r!show/#{params[:id]}!)
      render :update do |page|
        page.replace_html :article, :partial => "disclose"
      end
    else
      render :nothing => true
    end
  end

  def disclose
    Article.disclose(*article(params[:id]))
    redirect_to :action => "show", :id => params[:id]
  end
end
