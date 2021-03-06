module Ddr
  module Public
    module Controller
      module DownloadBehavior

        def send_file_contents
          self.status = 200
          prepare_file_headers
          # XXX Work around https://github.com/projecthydra/hydra-head/issues/199
          self.response_body = datastream.content
        end

        def prepare_file_headers
          super
          unless response.headers.include?("Content-Length")
            if datastream.external? 
              if content_length = datastream.file_size 
                response.headers["Content-Length"] = content_length.to_s
              end
            else
              response.headers["Content-Length"] = datastream.dsSize.to_s
            end
          end
        end

      end
    end
  end
end