# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  title      :string
#  body       :text
#  company_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Article < ApplicationRecord
  belongs_to :company
end
