# -*- coding: utf-8 -*-

require File.dirname(__FILE__) + '/../spec_helper'

describe StoriesController, 'Stories' do
  fixtures :all

  context 'にアクセスする場合' do

    def create_post(name, birthday)
      post 'create' , :story => {
        "name" => name,
        "birthday" => birthday
      }
    end

    describe '一覧表示' do
      it "一覧画面が表示される" do
        get 'index'
        response.should be_success
      end
    end

    describe '新規作成' do
      it "新規作成画面が表示される" do
        get 'new'
        response.should be_success
      end
    end

    describe '誕生数診断' do
      it "処理が正常終了する" do
        create_post("まはる", "19930929")
        response.redirect_url.should == 'http://test.host/stories'
        response.header.should have_at_least(1).items
        response.body.should have_at_least(1).items
        flash[:notice].should_not be_nil
        flash[:notice].should eq 'まはるさんの誕生数は 6 です'
        session[:result].should eq 'まはるさんの誕生数は 6 です'
        session[:name].should eq "まはる"
        session[:classify].should eq "6"
      end

      it "生成された誕生数が正しい" do
        create_post("まはる", "19930929")
        content = Story.find(2)
        content.name.should eq "まはる"
        content.classify.should eq "6"
        Story.count.should eq 2
      end
    end

  end
end
