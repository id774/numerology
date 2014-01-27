# -*- encoding: utf-8 -*-

require 'fluent-logger'
require 'json'
require 'singleton'

class SingletonFluentd
  include Singleton

  def initialize
    @fluentd = Fluent::Logger::FluentLogger.open('numerology',
      host = 'localhost', port = 9999)
  end

  def fluentd
    @fluentd
  end
end

class StoriesController < ApplicationController
  def new
    @story = Story.new

    respond_to do |format|
      format.html
      format.json { render json: @story }
    end
  end

  def show
    @story = Story.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @story }
    end
  end

  def create
    @story = Story.new(story_params)
    @story.classify = kabbala_calc(@story.birthday).to_s

    if @story.classify.to_i == 0
      result = "入力された生年月日が不正です"
    else
      result = @story.name + 'さんの誕生数は ' + @story.classify + ' です'
    end

    respond_to do |format|
      session[:result]   = result
      session[:name]     = @story.name
      session[:classify] = @story.classify

      if Rails.env.production?
        @fluentd = SingletonFluentd.instance.fluentd
        @fluentd.post('record', {
          :name          => @story.name,
          :classify      => @story.classify,
          :birthday      => @story.birthday
        })
      end

      notice = "#{result}"
      unless @story.classify.to_i == 0
        if @story.save
          format.html { redirect_to stories_path,
            notice: notice }
          format.json { render json: @story, status: :created, location: @story }
        else
          format.html { render action: "new" }
          format.json { render json: @story.errors, status: :unprocessable_entity }
        end
      else
        format.html { render action: "new", notice: notice }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    if params[:classify]
      begin
        @stories = Story.where(classify: params[:classify]).page(params[:page]).order(id: :desc)
      rescue ArgumentError
        @stories = Story.all.page(params[:page]).order(id: :desc)
      end
    else
      @stories = Story.all.page(params[:page]).order(id: :desc)
    end


    respond_to do |format|
      format.html
      format.json { render json: @stories }
    end
  end

  private

  def set_story
    @story = Story.find(params[:id])
  end

  def story_params
    params.require(:story).permit(:name, :birthday)
  end

  def nonary(i)
    return i if i.modulo(11) == 0
    r = i.modulo(9)
    r = 9 if r == 0
    r
  end

  def kabbala_calc(string)
    unless string.blank?
      if string.length == 8
        a = string.split("")
        year = a[0] + a[1] + a[2] + a[3]
        month = a[4] + a[5]
        day = a[6] + a[7]
        result = nonary(year.to_i) + nonary(month.to_i) + nonary(day.to_i)
        nonary(result)
      end
    end
  end
end
