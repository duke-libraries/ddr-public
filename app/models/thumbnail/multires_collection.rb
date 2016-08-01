class Thumbnail::MultiresCollection

  include Blacklight::Configurable
  include Blacklight::SolrHelper
  include Ddr::Public::Controller::SolrQueryConstructor
  include Ddr::Public::Controller::IiifImagePaths


  attr_accessor :document, :size, :region


  def initialize(args)
    @document = args.fetch(:document, nil)
    @size     = args.fetch(:size, '!350,350')
    @region   = args.fetch(:region, 'full')
  end


  def has_thumbnail?
    collection_multires_image_file_path?
  end

  def thumbnail_path
    if collection_multires_image_file_path?
      iiif_image_path(collection_multires_image_file_path, { size: size, region: region })
    end
  end


  private

  def collection_multires_image_file_path?
    collection_multires_image_file_path ? true : false
  end

  def collection_multires_image_file_path
    item_document.first_multires_image_file_path if item_document
  end

  def item_query
    "(#{local_ids_query([configured_local_id])}) AND (#{active_fedora_model_query(['Item'])})"
  end

  def item_document
    puts "@@@@@ MultiresCollection item_document @@@@@"
    if configured_local_id
      response, documents = get_search_results({ :q => item_query })
      documents.first
    else
      document.items.first if document.items
    end
  end

  def configured_local_id
    document.thumbnail.try(:[], 'local_id')
  end

end
