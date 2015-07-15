class PublishedAbilityDefinitions < Ddr::Auth::AbilityDefinitions

  def call
    cannot [ :discover, :read, :edit, :download ], [ ActiveFedora::Base, SolrDocument ], :published? => false
  end

end