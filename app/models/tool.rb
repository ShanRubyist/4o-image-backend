class Tool < ApplicationRecord
  has_many :tool_tags, dependent: :destroy
  has_many :tags, through: :tool_tags
  has_many :scraped_infos, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  
  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  
  def self.search(query)
    where("name ILIKE ? OR description ILIKE ?", "%#{query}%", "%#{query}%")
  end
end 