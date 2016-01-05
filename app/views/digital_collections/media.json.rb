json_response = {}

sources = image_item_tilesources(@document.multires_image_file_paths)
json_response['tilesources'] = sources

json_response.to_json
