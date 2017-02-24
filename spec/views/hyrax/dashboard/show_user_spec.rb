RSpec.describe "hyrax/dashboard/show_user.html.erb", type: :view do
  let(:user) { create(:user, display_name: "Charles Francis Xavier") }
  let(:ability) { instance_double("Ability") }
  before do
    stub_template('hyrax/dashboard/_create_work_action.html.erb' => "Create Work Stub")
    allow(user).to receive(:title).and_return("Professor, Head")
    allow(user).to receive(:department).and_return("Xavier’s School for Gifted Youngsters")
    allow(user).to receive(:telephone).and_return("814.865.8399")
    allow(user).to receive(:email).and_return("chuck@xsgy.edu")
    allow(user).to receive(:login).and_return("chuck")
    allow(user).to receive(:can_receive_deposits_from).and_return([])
    allow(user).to receive(:total_file_views).and_return(1)
    allow(user).to receive(:total_file_downloads).and_return(3)
    allow(user).to receive(:avatar).and_return(nil)

    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_ability).and_return(ability)

    allow(ability).to receive(:can?).with(:create, Collection).and_return(can_create_collection)
    allow(ability).to receive(:can?).with(:edit, user).and_return(can_edit_user)
    allow(ability).to receive(:can_create_any_work?).and_return(true)
    allow(view).to receive(:number_of_works).and_return("15")
    allow(view).to receive(:number_of_collections).and_return("3")

    assign(:activity, [])
    assign(:notifications, [])
  end
  let(:can_create_work) { true }
  let(:can_create_collection) { true }
  let(:can_edit_user) { true }

  context "with activities and notifications" do
    let(:now) { Time.zone.now.to_i }
    before do
      assign(:activity, [
               { action: 'so and so edited their profile', timestamp: now },
               { action: 'so and so uploaded a file', timestamp: (now - 360) }
             ])
    end

    it "includes recent activities and notifications" do
      render
      expect(rendered).to include "so and so edited their profile"
      expect(rendered).to include "6 minutes ago"
    end
  end

  context "with notifications" do
    before do
      assign(:notifications, FactoryGirl.create(:user_with_mail).mailbox.inbox)
    end

    it "shows a link to all notifications" do
      render
      expect(rendered).to include "See all notifications"
    end

    it "defaults to a limited number of notifications" do
      render
      expect(rendered).to include "Single File 9"
      expect(rendered).not_to include "Single File 2"
    end

    it "allows showing more notifications" do
      Hyrax.config.max_notifications_for_dashboard = 6
      render
      expect(rendered).to include "Single File 1"
    end
  end

  context 'with transfers' do
    let(:another_user) { create(:user) }
    let(:title1) { 'foobar' }
    let(:title2) { 'bazquux' }
    let(:incoming) { stub_model(ProxyDepositRequest, sending_user: user, created_at: Time.current) }
    let(:outgoing) { stub_model(ProxyDepositRequest, receiving_user: user, created_at: Time.current) }

    before do
      allow(view).to receive(:show_transfer_request_title).and_return(title1, title2)
      assign(:incoming, [incoming])
      assign(:outgoing, [outgoing])
    end

    it 'renders received and sent transfer requests' do
      render
      expect(rendered).not_to include "You haven't received any work transfers requests"
      expect(rendered).not_to include "You haven't transferred any works"
      expect(rendered).to include title1
      expect(rendered).to include title2
    end
    it 'renders transfer works link correctly' do
      render
      expect(rendered).to include "Select works to transfer"
    end
  end

  context "without activities and notifications" do
    it "includes headings for activities and notifications" do
      render
      expect(rendered).to include "User Activity"
      expect(rendered).to include "User Notifications"
    end

    it "shows no activities or notifications" do
      render
      expect(rendered).to include "User has no notifications"
      expect(rendered).to include "User has no recent activity"
    end
  end
end