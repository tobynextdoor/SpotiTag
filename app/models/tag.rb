class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :songs, :through => :taggings
  has_many :users, :through => :taggings

  @@system_prefixes = {
    :name => "name:",
    :album => "album:",
    :artist => "artist:"
  }

  def self.by_name(tag_name)
    tag_name = "__#{tag_name}" if Tag.is_system_tag_name? tag_name
    Tag.raw_by_name tag_name
  end

  def self.raw_by_name(tag_name)
    tag = Tag.where(:name => tag_name).first_or_create
  end

  def self.is_system_tag_name?(tag_name)
    @@system_prefixes.values.any? {|prefix| tag_name.start_with?(prefix)}
  end

  def self.prefix(prefix_key)
    @@system_prefixes[prefix_key]
  end

  def self.name_tag(tag_name)
    Tag.raw_by_name "#{@@system_prefixes[:name]}#{tag_name}"
  end

  def self.album_tag(tag_name)
    Tag.raw_by_name "#{@@system_prefixes[:album]}#{tag_name}"
  end

  def self.artist_tag(tag_name)
    Tag.raw_by_name "#{@@system_prefixes[:artist]}#{tag_name}"
  end

  def is_system_tag?
    Tag.is_system_tag_name? name
  end
end
