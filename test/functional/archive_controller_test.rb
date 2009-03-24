require File.dirname(__FILE__) + '/../test_helper'
require "archive_controller"

# Re-raise errors caught by the controller.
class ArchiveController; def rescue_action(e) raise e end; end

class ArchiveControllerTest < ActionController::TestCase
  include ArchiveHelper
  fixtures :articles, :users

  def setup
    @controller = ArchiveController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_routing
    assert_routing({:method => :get, :path => "/archive/show/foo"},
      :controller => "archive", :action => "show", :id => "foo")
    assert_routing({:method => :get, :path => "/archive/show/bar/2"},
      :controller => "archive", :action => "show", :id => "bar", :part => "2")
  end

  def test_to_html
    with_settings(:plugin_redmine_archive => {"archive_key" => ""}) do
      assert_equal "<p>[test:1234]</p>", Redmine::WikiFormatting.to_html(Setting.text_formatting, "[test:1234]")
    end
    with_settings(:plugin_redmine_archive => {"archive_key" => "hogefuga-foo-bar"}) do
      assert_equal('<p><a href="/archive/show/bQKq_vjzFjz7MBFxi7CdOw==">[test:1234]</a></p>',
        Redmine::WikiFormatting.to_html(Setting.text_formatting, "[test:1234]"))
    end
  end

  def test_not_logged_in
    @request.session[:user_id] = nil
    get :show, :id => "foo"
    assert_response :redirect
    assert_nil assigns(:mail)
  end

  def test_show
    @request.session[:user_id] = 1
    with_settings(:plugin_redmine_archive => {"archive_key" => "hogefuga-foo-bar"}) do
      params = archive("[test:1]")
      get params[:action], :id => params[:id]
      assert_response :success
      assert_not_nil assigns(:mail)
      assert_template "show"
    end
  end

  def test_show_coverpage
    @request.session[:user_id] = 1
    with_settings(:plugin_redmine_archive => {"archive_key" => "hogefuga-foo-bar"}) do
      params = archive("[test:2]")
      get params[:action], :id => params[:id]
      assert_response :success
      assert_not_nil assigns(:mail)
      assert_template "show"
      assert_tag(:tag => "ul", :attributes => {:class => "properties"},
        :child => {:tag => "li",
          :descendant => {
            :tag => "a", :content => /sample.patch/, :attributes => {:href => "/archive/show/#{params[:id]}/1"},
            :tag => "a", :content => /unknown2/, :attributes => {:href => "/archive/show/#{params[:id]}/2"},
          }})
    end
  end

  def test_show_part
    @request.session[:user_id] = 1
    with_settings(:plugin_redmine_archive => {"archive_key" => "hogefuga-foo-bar"}) do
      params = archive("[test:2]")
      get params[:action], :id => params[:id], :part => 1
      assert_response :success
      assert_not_nil assigns(:mail)
      assert_equal "text/x-patch", @response.content_type.downcase
      get params[:action], :id => params[:id], :part => 2
      assert_response :success
      assert_not_nil assigns(:mail)
      assert_equal "text/plain", @response.content_type.downcase
      assert_equal 'attachment; filename="unknown2"', @response.headers["Content-Disposition"]
    end
  end

  def test_enclose
    @request.session[:user_id] = 1
    with_settings(:plugin_redmine_archive => {"archive_key" => "hogefuga-foo-bar"}) do
      params = archive("[test:1]")
      xhr :post, :enclose, :id => params[:id]
      assert_response :success
      assert_select_rjs :replace_html, "article" do
        assert_select "a", "Disclose this mail"
      end
      test1 = Article.find_by_list_and_count("test", 1)
      assert_equal true, test1.hidden?
    end
  end

  def test_disclose
    @request.session[:user_id] = 2
    with_settings(:plugin_redmine_archive => {"archive_key" => "hogefuga-foo-bar"}) do
      params = archive("[test:1]")
      get :disclose, :id => params[:id]
      assert_response 403
    end
    @request.session[:user_id] = 1
    with_settings(:plugin_redmine_archive => {"archive_key" => "hogefuga-foo-bar"}) do
      params = archive("[test:1]")
      get :disclose, :id => params[:id]
      assert_response :redirect
      assert_redirected_to :action => "show", :id => params[:id]
      test1 = Article.find_by_list_and_count("test", 1)
      assert_equal false, test1.hidden?
    end
  end
end
