RSpec.describe AppleCertsInfo do
  it "has a version number" do
    expect(AppleCertsInfo::VERSION).not_to be nil
  end

  xit "Provisioning Profile info" do
    info = AppleCertsInfo.provisioning_profile_list_info
  end

  xit "Certificate info" do
    info = AppleCertsInfo.certificate_distribution_list
    info = AppleCertsInfo.certificate_development_list
  end

  xit "limit days" do
    list = AppleCertsInfo.provisioning_profile_list_limit_days_for(days: 55)
    list = AppleCertsInfo.certificate_development_list_limit_days_for(days: 255)
  end
end
