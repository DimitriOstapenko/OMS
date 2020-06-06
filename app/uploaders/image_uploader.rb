class ImageUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
   include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "#{IMAGE_BASE}/fullsize"
  end

  # Create different versions of your uploaded files:
   version :thumb250 do
     process resize_and_pad: [250, 167]

     def full_filename(for_file = model)
       '../' + "#{model.ref_code}.jpg"
     end
   end
   
   version :thumb400 do
     process resize_and_pad: [400, 267]
     
     def full_filename(for_file = model)
       '../400/' + "#{model.ref_code}.jpg"
     end
   end

   def extension_whitelist
     %w(jpg)
   end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
   def filename
     "#{model.ref_code}.jpg" if original_filename.present?
  end
end
