response = {}

sources = image_item_tilesources(@document.multires_image_file_paths)
response['tilesources'] = sources

response.to_json
