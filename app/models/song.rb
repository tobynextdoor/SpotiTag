class Song < ActiveRecord::Base
  belongs_to :user

  def tags
    tags_string.split ";"
  end

  def add_tag(tag_name)
    tags_string = (tags << tag_name).join ";"
  end
end
