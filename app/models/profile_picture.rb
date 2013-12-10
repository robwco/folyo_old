class ProfilePicture

  def self.styles
    {
      original:         { geometry: '5000x5000>', processors: [:auto_orient, :thumbnail] },
      large:            { geometry: '1000x1000#', processors: [:auto_orient, :cropper] },
      medium:           { geometry: '500x500#',   processors: [:auto_orient, :cropper] },
      small:            { geometry: '300x300#',   processors: [:auto_orient, :cropper] },
      thumbnail:        { geometry: '100x100#',   processors: [:auto_orient, :cropper] },
      small_edit_cover: { geometry: '400',        processors: [:auto_orient, :thumbnail] }
    }
  end

  include Mongoid::Document
  include Mongoid::Timestamps
  include Paperclipable::Model
  include Mongoid::EmbeddedFindable

  embedded_in :profile, polymorphic: true

  def self.find(id)
    find_by(Designer, :profile_picture, id)
  end

  def crop_ratio
    1
  end

end