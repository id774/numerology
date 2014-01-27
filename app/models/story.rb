# -*- coding: utf-8 -*-
class Story < ActiveRecord::Base
  paginates_per 10

  validates :name, :presence => true,
                   :length => {:minimum => 1, :maximum => 100}
  validates :birthday, :presence => true,
                   :length => {:minimum => 8, :maximum => 8},
                   :numericality => true
end
