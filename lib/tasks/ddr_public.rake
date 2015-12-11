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
      sitemap_file_paths = []

      sitemap_dir = File.join(Rails.root, 'public', 'sitemaps')
      Dir.glob(File.join(sitemap_dir, "*.xml")).reject{|f| f[File.join(sitemap_dir, "repository.xml")] }.each do |filepath|
        sitemap_file_paths << filepath
      end
      
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

      write_sitemap_to_file(File.join(sitemaps_dir_path, "repository.xml"), sitemap_builder)

    end


    desc "Generate an XML sitemap for a collection. Takes a collection pid as an argument."
    task :generate, [:collection_pid] => :environment do |t, args|
      
      create_sitemaps_public_dir
      
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

      write_sitemap_to_file(File.join(sitemaps_dir_path, "#{sitemap_filename}.xml"), sitemap_builder)

    end

    def create_sitemaps_public_dir
      dirname = File.dirname(sitemaps_dir_path)
      unless File.directory?(sitemaps_dir_path)
        FileUtils.mkdir_p(sitemaps_dir_path)
      end
    end

    def sitemaps_dir_path
      File.join(Rails.root, 'public', 'sitemaps')
    end

    def full_document_url pid
      solr_doc = SolrDocument.find(pid)
      url_for_sitemap = "#{ENV['ROOT_URL']}" + document_url(solr_doc)
      puts url_for_sitemap
      url_for_sitemap
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

  # Borrowed some ideas from here:
  # https://github.com/OregonDigital/oregondigital/blob/master/lib/tasks/pull_content.rake
  # http://www.apache.org/licenses/LICENSE-2.0
  namespace :ddr_portals do
    
    DDR_PORTALS_REPO = "git@github.com:duke-libraries/ddr-portals.git"
    DDR_PORTALS_PATH = Rails.root.join('ddr-portals')
    GITFILE = "#{DDR_PORTALS_PATH}/.git"
    PORTAL_VIEW_PATH = Rails.root.join('app','views','ddr-portals')

    file GITFILE do
      sh "git clone #{DDR_PORTALS_REPO} #{DDR_PORTALS_PATH}"
    end

    desc "Pull portal content into #{DDR_PORTALS_PATH}. Use BRANCH=xxx to check out something other than 'master'"
    task :pull => [:environment, GITFILE] do
      branch = ENV["BRANCH"]
      branch ||= "master"

      sh "cd #{DDR_PORTALS_PATH} && git fetch && git checkout #{branch} && git pull origin #{branch}"
    end

    desc 'Sync to the latest version of set-specific content and assets'
    task :sync => [:pull, :clean_links] do
      Dir["#{DDR_PORTALS_PATH}/*"].each do |set_repo_path|

        next unless File.directory?(set_repo_path)
        next if set_repo_path =~ /^\./

        setname = File.basename(set_repo_path)
        
        dir = set_repo_path + "/views"
        sh "ln -s #{dir} #{PORTAL_VIEW_PATH}/#{setname}" if File.directory?(dir)

      end
    end

    desc "Clean all view symlinks without removing the git repository"
    task :clean_links => [PORTAL_VIEW_PATH] do
      sh "find #{PORTAL_VIEW_PATH} -type l -exec rm {} \\;"
    end

    desc "Clean all portal-specific views, including the repository"
    task :clean => [:environment, :clean_links] do
      sh "rm -rf #{DDR_PORTALS_PATH}"
    end
      
  end

  Rake::Task["ddr_public:sitemap:generate"].enhance do
    Rake::Task["ddr_public:sitemap:index"].invoke
  end

end
