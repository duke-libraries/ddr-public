require 'spec_helper'

RSpec.describe Structure::Directory do

  let(:structure) do
    {"default"=>
      {"type"=>"default",
       "contents"=>
        [{"label"=>"test-nested",
          "order"=>"1",
          "type"=>"Directory",
          "contents"=>
           [{"label"=>"Youth",
             "order"=>"1",
             "type"=>"Directory",
             "contents"=>
              [{"label"=>"Americorps",
                "order"=>"1",
                "type"=>"Directory",
                "contents"=>
                 [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2080"}]},
                  {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:2081"}]},
                  {"order"=>"3", "contents"=>[{"repo_id"=>"changeme:2082"}]},
                  {"order"=>"4", "contents"=>[{"repo_id"=>"changeme:2083"}]},
                  {"label"=>"Kathryn AmeriCorps",
                   "order"=>"5",
                   "type"=>"Directory",
                   "contents"=>
                    [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2084"}]},
                     {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:2085"}]}]},
                  {"order"=>"6", "contents"=>[{"repo_id"=>"changeme:2086"}]},
                  {"order"=>"7", "contents"=>[{"repo_id"=>"changeme:2087"}]},
                  {"order"=>"8", "contents"=>[{"repo_id"=>"changeme:2088"}]}]},
               {"label"=>"Archivos temporales",
                "order"=>"2",
                "type"=>"Directory",
                "contents"=>
                 [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2089"}]},
                  {"order"=>"2",
                   "contents"=>[{"repo_id"=>"changeme:2090"}]}]}]}]}]}}
  end

  subject { described_class.new({structure: structure}) }

  its(:item_pid_lookup) { is_expected.to eq(
    {"changeme:2080"=>
      {:files=>
        ["changeme:2080",
         "changeme:2081",
         "changeme:2082",
         "changeme:2083",
         "changeme:2086",
         "changeme:2087",
         "changeme:2088"],
       :parent_directories=>["test-nested", "Youth", "Americorps"]},
     "changeme:2081"=>
      {:files=>
        ["changeme:2080",
         "changeme:2081",
         "changeme:2082",
         "changeme:2083",
         "changeme:2086",
         "changeme:2087",
         "changeme:2088"],
       :parent_directories=>["test-nested", "Youth", "Americorps"]},
     "changeme:2082"=>
      {:files=>
        ["changeme:2080",
         "changeme:2081",
         "changeme:2082",
         "changeme:2083",
         "changeme:2086",
         "changeme:2087",
         "changeme:2088"],
       :parent_directories=>["test-nested", "Youth", "Americorps"]},
     "changeme:2083"=>
      {:files=>
        ["changeme:2080",
         "changeme:2081",
         "changeme:2082",
         "changeme:2083",
         "changeme:2086",
         "changeme:2087",
         "changeme:2088"],
       :parent_directories=>["test-nested", "Youth", "Americorps"]},
     "changeme:2084"=>
      {:files=>["changeme:2084", "changeme:2085"],
       :parent_directories=>
        ["test-nested", "Youth", "Americorps", "Kathryn AmeriCorps"]},
     "changeme:2085"=>
      {:files=>["changeme:2084", "changeme:2085"],
       :parent_directories=>
        ["test-nested", "Youth", "Americorps", "Kathryn AmeriCorps"]},
     "changeme:2086"=>
      {:files=>
        ["changeme:2080",
         "changeme:2081",
         "changeme:2082",
         "changeme:2083",
         "changeme:2086",
         "changeme:2087",
         "changeme:2088"],
       :parent_directories=>["test-nested", "Youth", "Americorps"]},
     "changeme:2087"=>
      {:files=>
        ["changeme:2080",
         "changeme:2081",
         "changeme:2082",
         "changeme:2083",
         "changeme:2086",
         "changeme:2087",
         "changeme:2088"],
       :parent_directories=>["test-nested", "Youth", "Americorps"]},
     "changeme:2088"=>
      {:files=>
        ["changeme:2080",
         "changeme:2081",
         "changeme:2082",
         "changeme:2083",
         "changeme:2086",
         "changeme:2087",
         "changeme:2088"],
       :parent_directories=>["test-nested", "Youth", "Americorps"]},
     "changeme:2089"=>
      {:files=>["changeme:2089", "changeme:2090"],
       :parent_directories=>["test-nested", "Youth", "Archivos temporales"]},
     "changeme:2090"=>
      {:files=>["changeme:2089", "changeme:2090"],
       :parent_directories=>["test-nested", "Youth", "Archivos temporales"]}}
   ) }

  its(:directory_id_lookup) { is_expected.to eq(
    {"root"=>
      [{:text=>"test-nested",
        :id=>"32f601eccbb33b653153b4f88e78d564a686a75e",
        :icon=>"fa fa-folder",
        :children=>true,
        :a_attr=>{:href=>"javascript:void(0);"},
        :state=>{:opened=>true}}],
     "32f601eccbb33b653153b4f88e78d564a686a75e"=>
      [{:text=>"Youth",
        :id=>"827452399161b8927e87268b4b7c1acb2cd4abd3",
        :icon=>"fa fa-folder",
        :children=>true,
        :a_attr=>{:href=>"javascript:void(0);"},
        :state=>{:opened=>false}}],
     "827452399161b8927e87268b4b7c1acb2cd4abd3"=>
      [{:text=>"Americorps",
        :id=>"aa866017432c4cac9edc5036c59b055222dda112",
        :icon=>"fa fa-folder",
        :children=>true,
        :a_attr=>{:href=>"javascript:void(0);"},
        :state=>{:opened=>false}},
       {:text=>"Archivos temporales",
        :id=>"28747967357faf1c55b9a6ff9f3ae11352c85adc",
        :icon=>"fa fa-folder",
        :children=>true,
        :a_attr=>{:href=>"javascript:void(0);"},
        :state=>{:opened=>false}}],
     "aa866017432c4cac9edc5036c59b055222dda112"=>
      [{:repo_id=>"changeme:2080"},
       {:repo_id=>"changeme:2081"},
       {:repo_id=>"changeme:2082"},
       {:repo_id=>"changeme:2083"},
       {:text=>"Kathryn AmeriCorps",
        :id=>"abcc4e8f18b20e81070ffaccda8acd5d403be880",
        :icon=>"fa fa-folder",
        :children=>true,
        :a_attr=>{:href=>"javascript:void(0);"},
        :state=>{:opened=>false}},
       {:repo_id=>"changeme:2086"},
       {:repo_id=>"changeme:2087"},
       {:repo_id=>"changeme:2088"}],
     "abcc4e8f18b20e81070ffaccda8acd5d403be880"=>
      [{:repo_id=>"changeme:2084"}, {:repo_id=>"changeme:2085"}],
     "28747967357faf1c55b9a6ff9f3ae11352c85adc"=>
      [{:repo_id=>"changeme:2089"}, {:repo_id=>"changeme:2090"}]}
  ) }

end
