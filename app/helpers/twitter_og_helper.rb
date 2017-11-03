module TwitterOgHelper

  # See documentation for supplying Twitter Card & Open Graph meta tags:
  # https://developer.twitter.com/en/docs/tweets/optimize-with-cards/guides/getting-started
  # http://ogp.me/

  def og_site_name
    controller_name == 'digital_collections' ? 'Duke Digital Collections' : application_name
  end

  def twitter_handle
    controller_name == 'digital_collections' ? '@dukedigitalcoll' : '@DukeLibraries'
  end

  def og_absolute_url path
    case
      when path.start_with?('https://')
        path
      when path.start_with?('//')
        File.join('https:',path)
      when path.start_with?('/')
        File.join(root_url,path)
      else
        path
    end
  end

end
