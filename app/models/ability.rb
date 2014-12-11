class Ability < Ddr::Auth::Ability

  def custom_permissions
    cannot [ :discover, :read, :edit, :download ], [ ActiveFedora::Base, SolrDocument ], :published? => false
  end

  def download_permissions
    can :download, ActiveFedora::Base do |obj|
      can? :read, obj
    end
    can :download, SolrDocument do |doc|
      can? :read, doc
    end
    can :download, ActiveFedora::Datastream do |ds|
      can? :read, ds.pid
    end
  end

end
