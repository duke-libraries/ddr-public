module Ddr
  module Public
    module Controller
      module IiifImagePaths


        def iiif_image_path(filepath,options)
          size = options[:size] ? options[:size] : 'full'
          region = options[:region] ? options[:region] : 'full'
          url = "#{Ddr::Models.image_server_url}?IIIF=#{filepath}/#{region}/#{size}/0/default.jpg"
        end

        def iiif_image_info_path(filepath)
          url = "#{Ddr::Models.image_server_url}?IIIF=#{filepath}/info.json"
        end

        def iiif_image_size_maxpx pixels
          px = pixels.to_s || ''
          px.present? ? '!' + px + ',' + px : 'full'
        end

      end
    end
  end
end
