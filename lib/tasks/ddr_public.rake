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

  namespace :document_urls do
    desc "Given a collection pid, generates a list of pids and corresponding URLs"
    task :list, [:collection_pid] => :environment do |t, args|
      include ApplicationHelper
      include CatalogHelper
      include BlacklightHelper

      include Rails.application.routes.url_helpers

      collection = Collection.find(args.collection_pid)
      url_for_document_from_pid(collection.pid)

      collection.items(response_format: :solr).each do |item_doc|
        item = Item.find(item_doc["id"])
        url_for_document_from_pid(i=item.pid)

        item.components(response_format: :solr).each do |component_doc|
          component = Component.find(component_doc["id"])
          url_for_document_from_pid(component.pid)
        end

      end

    end

    def url_for_document_from_pid pid
      solr_doc = SolrDocument.find(pid)
      puts pid + "," + document_or_object_url(solr_doc)
    end

  end

end