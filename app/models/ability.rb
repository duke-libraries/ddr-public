class Ability < Ddr::Auth::Ability

  def custom_permissions
    cannot [ :discover, :read, :edit, :download ], [ ActiveFedora::Base, SolrDocument ], :published? => false
  end

end
