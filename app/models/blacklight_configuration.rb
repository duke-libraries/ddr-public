class BlacklightConfiguration

  attr_accessor :local_id, :controller_name

  def initialize(args={})
    @local_id        = args.fetch(:local_id, nil)
    @controller_name = args.fetch(:controller_name, nil)
  end


  def configuration
    portal_config = Rails.application.config.try(:portal).try(:[], 'controllers').try(:[], local_id).try(:[], 'configure_blacklight')
    portal_config ||= Rails.application.config.try(:portal).try(:[], 'controllers').try(:[], controller_name).try(:[], 'configure_blacklight')
  end

end
