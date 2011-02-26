class VolumePrice < ActiveRecord::Base
  belongs_to :variant

  validates :variant,
    :presence => true
  validates :starting_quantity,
    :presence => true,
    :uniqueness => {:scope => :variant_id},
    :numericality => {:greater_than => 1, :only_integer => true,
                      :allow_blank => true}
  validates :price,
    :presence => true,
    :numericality => {:greater_than => 0.0, :allow_blank => true}
end
