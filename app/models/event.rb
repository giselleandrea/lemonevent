class Event < ApplicationRecord
  belongs_to :user

  validates :name, :description, :event_date, :location, :capacity, presence: true

end
