class DesignerProjectArtwork

  def self.styles
    {
      original:         { geometry: '5000x5000>', processors: [:auto_orient, :thumbnail] }, # adding an original size prevents arbitrary large files to be stored
      large:            { geometry: '1200x900#',  processors: [:auto_orient, :cropper] },   # large, medium & small are center-cropped by default at 4/3
      medium:           { geometry: '800x600#',   processors: [:auto_orient, :cropper] },
      small:            { geometry: '400x300#',   processors: [:auto_orient, :cropper] },
      thumbnail:        { geometry: '200x150#',   processors: [:auto_orient, :cropper] },
      small_edit_cover: { geometry: '400',        processors: [:auto_orient, :thumbnail] }  # this one keeps original ratio. It will be used to edit cropping
    }
  end

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip
  include Paperclipable::Model

  belongs_to :project, class_name: 'DesignerProject', inverse_of: :artworks

  # for now, enforcing that there is only one artwork per project
  after_create do
    project.artworks.where(:_id.ne => self.id).destroy_all
  end

  def crop_ratio
    4.fdiv(3)
  end

end