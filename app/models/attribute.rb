class Attribute < ActiveRecord::Base
  set_inheritance_column :something_other_than_type

  belongs_to :action
end
