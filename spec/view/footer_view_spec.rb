# frozen_string_literal: true

require 'rails_helper'
RSpec.describe '/shared/_footer', type: :view do
  before do
    render
  end
  it 'has the zizia version' do
    render
    expect(rendered).to match("v#{Zizia::VERSION}")
    expect(rendered).to match(t('zizia.product_name'))
  end
  it 'has the hyrax version' do
    expect(rendered).to match(Hyrax::VERSION)
    expect(rendered).to match(t('hyrax.product_name'))
  end
  it 'has the tenejo version/sha' do
    expect(rendered).to match(DEPLOYED_VERSION)
    expect(rendered).to match(LAST_DEPLOYED)
    expect(rendered).to match(GIT_SHA)
  end
  it 'has a copyright footer' do
    expect(rendered).to match "Copyright &copy; #{Time.zone.now.year} Data Curation Experts, LLC"
  end
end
