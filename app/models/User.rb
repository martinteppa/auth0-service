# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  email      :string           not null
#  auth0_id   :string           not null
#  status     :integer          not null
#  company_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < ApplicationRecord
  belongs_to :company

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  enum status: {
    active: 0,
    disabled: 1,
    deleted: 2,
  }

  def self.status_keys_without_deleted
    statuses = self.statuses.transform_keys(&:to_sym)
    statuses.delete(:deleted)
    statuses.keys.map(&:to_sym)
  end
end
