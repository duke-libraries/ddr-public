namespace :ddr_public do
  
  namespace :config do
    desc "Copy sample config files"
    task :samples do
      Dir.glob("config/**/*.sample") do |sample|
        actual = sample.gsub(/\.sample/, "")
        FileUtils.cp sample, actual, verbose: true unless File.exists?(actual)
      end
    end
  end

  namespace :ci do
    desc "Prepare for CI build"
    task :prepare => ['ddr_public:config:samples', 'db:test:prepare', 'jetty:clean', 'jetty:config'] do
    end

    desc "CI build"
    task :build => :prepare do
      ENV['environment'] = "test"
      jetty_params = Jettywrapper.load_config
      jetty_params[:startup_wait] = 60
      Jettywrapper.wrap(jetty_params) do
          Rake::Task['spec'].invoke
      end
    end
  end

  namespace :sitemap do
    desc "Generate an XML sitemap index"
    task :index do
      files = []
      sitemap_file_paths = Dir.glob(File.join(Rails.root, 'public', 'sitemaps', "{[!repository]}*.xml"))
      
      sitemap_file_paths.each do |sitemap_file_path|
        files << File.basename(sitemap_file_path)
      end

      sitemap_builder = Nokogiri::XML::Builder.new do |xml|
        xml.sitemapindex "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
          files.each do |file|
            xml.sitemap do
              xml.loc "#{ENV['ROOT_URL']}/sitemaps/" + file
              xml.lastmod File.mtime(File.join(Rails.root, 'public', 'sitemaps', file)).strftime("%Y-%m-%dT%H:%M:%S%:z")
            end
          end
        end
      end

      write_sitemap_to_file(File.join(Rails.root, 'public', 'sitemaps', "repository.xml"), sitemap_builder)

    end


    desc "Generate an XML sitemap for a collection. Takes a collection pid as an argument."
    task :generate, [:collection_pid] => :environment do |t, args|

      collection = Collection.find(args.collection_pid)

      sitemap_filename = collection.local_id
      
      urls = []
      urls << full_document_url(collection.pid)

      collection.items(response_format: :solr).each do |item_doc|
        item = Item.find(item_doc["id"])
        urls << full_document_url(item.pid)
      end

      sitemap_builder = Nokogiri::XML::Builder.new do |xml|
        xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
          urls.each do |url|
            xml.url do
              xml.loc url
            end
          end
        end
      end

      write_sitemap_to_file(File.join(Rails.root, 'public', 'sitemaps', "#{sitemap_filename}.xml"), sitemap_builder)

    end

    def full_document_url pid
      solr_doc = SolrDocument.find(pid)
      "#{ENV['ROOT_URL']}" + document_url(solr_doc)
    end

    def write_sitemap_to_file(filepath, builder)
      File.open(filepath, 'w') do |fh|
        fh.puts builder.to_xml
      end
      if File.size(filepath) > 10485760
        puts 'WARNING sitemap is over 10MB limit: ' + filepath
      end
      puts "Sitemap generated: " + filepath
    end

  end


  namespace :document_urls do
    desc "Given a collection pid, generates a list of pids and corresponding URLs"
    task :list, [:collection_pid] => :environment do |t, args|

      collection = Collection.find(args.collection_pid)
      pid_to_url_mapping(collection.pid)

      collection.items(response_format: :solr).each do |item_doc|
        item = Item.find(item_doc["id"])
        pid_to_url_mapping(item.pid)

        item.components(response_format: :solr).each do |component_doc|
          component = Component.find(component_doc["id"])
          pid_to_url_mapping(component.pid)
        end

      end

    end

    def pid_to_url_mapping pid
      solr_doc = SolrDocument.find(pid)
      puts pid + "," + document_url(solr_doc)
    end

  end


  def document_url(solr_doc)
    include ApplicationHelper
    include CatalogHelper
    include BlacklightHelper

    include Rails.application.routes.url_helpers

    document_or_object_url(solr_doc)
  end

  Rake::Task["ddr_public:sitemap:generate"].enhance do
    Rake::Task["ddr_public:sitemap:index"].invoke
  end

end