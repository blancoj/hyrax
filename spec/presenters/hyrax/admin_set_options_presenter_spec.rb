require 'spec_helper'

RSpec.describe Hyrax::AdminSetOptionsPresenter do
  let(:service) { instance_double(Hyrax::AdminSetService) }
  let(:presenter) { described_class.new(service) }

  describe "#select_options" do
    subject { presenter.select_options }
    before do
      allow(service).to receive(:search_results)
        .with(:deposit)
        .and_return(results)
    end

    context "with permission_template visibility" do
      let(:solr_doc1) { instance_double(SolrDocument, id: '123', to_s: 'Public Set') }
      let(:solr_doc2) { instance_double(SolrDocument, id: '345', to_s: 'Private Set') }
      before do
        allow(presenter).to receive(:workflow) { nil }
        create(:permission_template, admin_set_id: '123', visibility: 'open')
        create(:permission_template, admin_set_id: '345', visibility: 'restricted')
      end
      let(:results) { [solr_doc1, solr_doc2] }

      it do
        is_expected.to eq [['Public Set', '123', { 'data-sharing' => false, 'data-visibility' => 'open' }],
                           ['Private Set', '345', { 'data-sharing' => false, 'data-visibility' => 'restricted' }]]
      end
    end

    context "with permission_template release_date" do
      let(:today) { Time.zone.today }
      let(:solr_doc1) { instance_double(SolrDocument, id: '123', to_s: 'Fixed Release Date Set') }
      let(:solr_doc2) { instance_double(SolrDocument, id: '345', to_s: 'No Delay Set') }
      let(:solr_doc3) { instance_double(SolrDocument, id: '567', to_s: 'One Year Max Embargo Set') }
      let(:solr_doc4) { instance_double(SolrDocument, id: '789', to_s: 'Release Before Date Set') }
      let(:results) { [solr_doc1, solr_doc2, solr_doc3, solr_doc4] }

      before do
        allow(presenter).to receive(:workflow) { nil }
        create(:permission_template, admin_set_id: '123', release_period: Hyrax::PermissionTemplate::RELEASE_TEXT_VALUE_FIXED, release_date: today + 2.days)
        create(:permission_template, admin_set_id: '345', release_period: Hyrax::PermissionTemplate::RELEASE_TEXT_VALUE_NO_DELAY)
        create(:permission_template, admin_set_id: '567', release_period: Hyrax::PermissionTemplate::RELEASE_TEXT_VALUE_1_YEAR)
        create(:permission_template, admin_set_id: '789', release_period: Hyrax::PermissionTemplate::RELEASE_TEXT_VALUE_BEFORE_DATE, release_date: today + 1.month)
      end

      it do
        is_expected.to eq [['Fixed Release Date Set', '123', { 'data-sharing' => false, 'data-release-date' => today + 2.days }],
                           ['No Delay Set', '345', { 'data-sharing' => false, 'data-release-date' => today }],
                           ['One Year Max Embargo Set', '567', { 'data-sharing' => false, 'data-release-date' => today + 1.year, 'data-release-before-date' => true }],
                           ['Release Before Date Set', '789', { 'data-sharing' => false, 'data-release-date' => today + 1.month, 'data-release-before-date' => true }]]
      end
    end

    context "with empty permission_template" do
      let(:solr_doc1) { instance_double(SolrDocument, id: '123', to_s: 'Empty Template Set') }
      let(:results) { [solr_doc1] }

      before do
        create(:permission_template, admin_set_id: '567')
      end

      it { is_expected.to eq [['Empty Template Set', '123', {}]] }
    end

    context "with no permission_template" do
      let(:solr_doc1) { instance_double(SolrDocument, id: '123', to_s: 'No Template Set') }
      let(:results) { [solr_doc1] }

      it { is_expected.to eq [['No Template Set', '123', {}]] }
    end
  end
end
