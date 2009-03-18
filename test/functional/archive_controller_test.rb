require File.dirname(__FILE__) + '/../test_helper'
require "archive_controller"

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

  def test_not_logged_in
    @request.session[:user_id] = nil
    get :show, :id => "foo"
    assert_response :redirect
    assert_nil assigns(:mail)
  end

  def test_show
    @request.session[:user_id] = 1
    with_settings(:mail_handler_api_key => "hogefuga-foo-bar") do
      params = archive("[test:1]")
      get params[:action], :id => params[:id]
      assert_response :success
      assert_not_nil assigns(:mail)
      assert_template "show"
    end
  end

  def test_show_coverpage
    @request.session[:user_id] = 1
    with_settings(:mail_handler_api_key => "hogefuga-foo-bar") do
      params = archive("[test:2]")
      get params[:action], :id => params[:id]
      assert_response :success
      assert_not_nil assigns(:mail)
      assert_template "show"
      assert_tag(:tag => "ul", :attributes => {:class => "properties"},
        :child => {:tag => "li",
        :descendant => {:tag => "a", :content => /sample.patch/}})
    end
  end

  def test_show_part
    @request.session[:user_id] = 1
    with_settings(:mail_handler_api_key => "hogefuga-foo-bar") do
      params = archive("[test:2]")
      get params[:action], :id => params[:id], :part => 1
      assert_response :success
      assert_not_nil assigns(:mail)
      assert_equal "text/x-patch", @response.content_type.downcase
    end
  end
end
