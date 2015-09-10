require 'spec_helper'

describe 'Add an attached file' do
  let(:user) { create(:user) }
  let!(:work) { create(:work, user: user) }

  before do
    sign_in user
    # stub out characterization. Travis doesn't have fits installed, and it's not relevant to the test.
    expect(CharacterizeJob).to receive(:perform_later)
  end

  it 'updates the file' do
    visit "/concern/generic_works/#{work.id}"
    click_link 'Attach a File'

    within('form.new_generic_file') do
      fill_in('Title', with: 'image.png')
      attach_file('Upload a file', fixture_file_path('files/image.png'))
      click_on('Attach to Generic Work')
    end

    visit "/concern/generic_works/#{work.id}"
    within '.related_files' do
      expect(page).to have_link 'image.png'
    end
  end
end