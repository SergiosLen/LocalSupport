require 'spec_helper'
 
describe User do

  let (:model) { mock_model("Organization") }
  
  it 'must find an admin in find_by_admin with true argument' do
    FactoryGirl.create(:user, admin: true)
    result = User.find_by_admin(true)
    result.admin?.should be_true
  end

  it 'must find a non-admin in find_by_admin with false argument' do
    FactoryGirl.create(:user, admin: false ) 
    result = User.find_by_admin(false)
    result.admin?.should be_false
  end

  it 'does not allow mass assignment of admin for security' do
    user = FactoryGirl.create(:user, admin: false)
    user.update_attributes(:admin=> true)
    user.save!
    user.admin.should be_false
  end

  context 'is admin' do
    subject(:user) { create(:user, admin: true) }  
    
    it 'can edit organizations' do
      user.can_edit?(model).should be_true 
    end

  end
  
  context 'is not admin' do 
    
    let( :non_associated_model ) { mock_model("Organization") }
    
    subject(:user) { create(:user, admin: false, organization: model ) } 
    
    it 'can edit associated organization' do
      user.organization.should eq model
      user.can_edit?(model).should be_true 
    end
    
    it 'can not edit non-associated organization' do
      user.organization.should eq model
      user.can_edit?(non_associated_model).should be_false
    end
    
    it 'can not edit when associated with no org' do
      user.organization = nil
      user.organization.should eq nil
      user.can_edit?(non_associated_model).should be_false
    end

    it 'can not edit when associated with no org and attempting to access non-existent org' do
      user.can_edit?(nil).should be_false
    end
   
  end

  # http://stackoverflow.com/questions/12125038/where-do-i-confirm-user-created-with-factorygirl
  describe '#promote_new_user' do
    before do
      Gmaps4rails.stub(:geocode => nil)
    end
    let(:user) { FactoryGirl.create(:user, email: 'bert@charity.org') }
    let(:admin_user) { FactoryGirl.create(:user, email: 'admin@charity.org') }
    let(:mismatch_org) { FactoryGirl.create(:organization, email: 'admin@other_charity.org') }
    let(:match_org) { FactoryGirl.create(:organization, email: 'admin@charity.org') }


    #it 'does confirm! work?' do
    #  original_status = usr.confirmed_at
    #  usr.confirm!
    #  expect(original_status).not_to eq(usr.confirmed_at)
    #end

    it 'should call promote_new_user after confirmation' do
      user.should_receive(:promote_new_user)
      user.confirm!
    end

    it 'should not promote the user if org email does not match' do
      user.promote_new_user
      user.organization.should_not eq mismatch_org
      user.organization.should_not eq match_org
    end

    it 'should not promote the admin user if org email does not match' do
      admin_user.promote_new_user
      admin_user.organization.should_not eq mismatch_org
    end

    it 'should promote the admin user if org email matches' do
      admin_user.promote_new_user
      admin_user.organization.should eq match_org
    end


   # let(:match_org) { FactoryGirl.create(:organization, email: 'info@friendly.org') }

   # it 'promotion if mail match' do
   #   expect(usr.organization_id).to eq(match_org.id)
   # end

  end

end
