class Ability < Ddr::Auth::Ability

  def custom_permissions
    super
    cannot [ :discover, :read, :edit, :download ], [ ActiveFedora::Base, SolrDocument ], :published? => false
  end

end
