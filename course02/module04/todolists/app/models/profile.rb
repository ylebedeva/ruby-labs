class Profile < ActiveRecord::Base
  belongs_to :user
  validates :gender, :inclusion => ['male', 'female']
  validate :validate_male_first_name_not_sue
  validates :first_name, :presence => true, unless: :last_name?
  validates :last_name, :presence => true, unless: :first_name?

  def validate_male_first_name_not_sue
  	errors.add(:first_name, 'cannot be Sue for a male') if gender == 'male' && first_name == 'Sue'
  end

  def self.get_all_profiles min_year, max_year
  	self.order(birth_year: :asc).where("birth_year between :min and :max", min: min_year, max: max_year).all.to_a
  end

end