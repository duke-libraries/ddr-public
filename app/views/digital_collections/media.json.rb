json_response = {}

response, document_list = find_children(@document, :is_part_of, params)
sources = image_item_tilesources(@document, document_list)
json_response['tilesources'] = sources

json_response.to_json
