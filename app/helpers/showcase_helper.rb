module ShowcaseHelper

  def home_showcase_locals options={}
    locals = {
      index: options[:index],
      image: options[:image],
      size_class: showcase_size_class(options[:showcase_layout])
    }
    if options[:image].respond_to? :multires_image_file_paths
      locals.merge!({
        size: showcase_size(options[:showcase_layout]),
        region: 'pct:5,5,90,90',
        caption_length: showcase_caption_length(options[:showcase_layout])
      })
    end
    locals
  end

  def showcase_samples options={}
    options[:showcase_layout] == 'landscape' ? 1 : 2
  end

  def showcase_image_path options={}
    if options[:locals][:image].respond_to? :multires_image_file_paths
      iiif_image_path(options[:locals][:image].multires_image_file_paths.first, {:size => options[:locals][:size], :region => options[:locals][:region] })
    else
      image_path("ddr-portals/#{options[:params][:collection] || options[:controller_name]}/#{options[:locals][:image]}")
    end
  end


  private

  def showcase_caption_length layout
    layout == 'landscape' ? 100 : 50
  end

  def showcase_size layout
    layout == 'landscape' ? '1200,' : '600,'
  end

  def showcase_size_class layout
    layout == 'landscape' ? 'col-md-8 col-sm-12' : 'col-md-4 col-sm-6'
  end

end
