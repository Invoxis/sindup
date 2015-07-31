describe Sindup::Folder do


  it "must instantiate with given parameters" do

    assert Sindup::Folder.new

    fo = Sindup::Folder.new folder_id: 42
    assert fo.folder_id == 42
    assert fo.name.nil?
    assert fo.description.nil?

    fo = Sindup::Folder.new name: "folderName"
    assert fo.folder_id.nil?
    assert_match fo.name, "folderName"
    assert fo.description.nil? 

    fo = Sindup::Folder.new description: "folderDesc"
    assert fo.folder_id.nil?
    assert fo.name.nil?
    assert_match fo.description, "folderDesc" 

    fo = Sindup::Folder.new folder_id: 42, name: "folderName", description: "folderDesc"
    assert fo.folder_id == 42
    assert_match fo.name, "folderName"
    assert_match fo.description, "folderDesc" 

  end # !"must instantiate"


end


# Tests fail because there is no Sindup::Collection::Folder until a sindup client is instantiate.
describe "Folder Collection" do


  before do
    @s = get_client
  end


  # describe "Sindup::Collection::Folder" do


  #   it "should be accessible here" do
  #     assert Sindup::Collection::Folder
  #   end


  #   it "should be accessible from sindup client" do
  #     assert @s.folders
  #   end


  #   it "could take criterias" do

  #     assert @s.folders.where()
  #     assert @s.folders.where(->(f) {})

  #     it "must clone existing collection" do
  #       c1 = @s.folders.where()
  #       c2 = @s.folders.where()
  #       assert_instance_of c1.class c2
  #       refute_equal c1, c2
  #     end

  #   end # !"could take criterias"


  #   it "could take an endpoint" do

  #     assert @s.folders.until(42)
  #     assert @s.folders.until(->(f) {})

  #     it "must clone existing collection" do
  #       c1 = @s.folders.until(42)
  #       c2 = @s.folders.until(42)
  #       assert_instance_of c1.class c2
  #       refute_equal c1, c2
  #     end

  #   end # !"could take an endpoint"


  # end


end

