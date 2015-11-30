response, document_list = find_children(@document, :is_part_of, params)
sources = image_item_tilesources(@document, document_list)
sources.to_json
