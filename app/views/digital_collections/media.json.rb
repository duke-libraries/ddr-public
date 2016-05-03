response = {}

sources = image_item_tilesources(@document.multires_image_file_paths)
derivatives = derivative_urls({document: @document, derivative_url_prefixes: @derivative_url_prefixes})

response['tilesources'] = sources
response['derivatives'] = derivatives

response.to_json
