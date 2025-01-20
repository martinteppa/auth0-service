# == Schema Information
#
# Table name: companies
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  database_name :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Company < ApplicationRecord
  has_many :users, dependent: :destroy  # Relación uno a muchos

  validates :name, presence: true
  validates :database_name, presence: true
end
