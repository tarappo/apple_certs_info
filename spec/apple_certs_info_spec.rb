RSpec.describe AppleCertsInfo do
  it "has a version number" do
    expect(AppleCertsInfo::VERSION).not_to be nil
  end

  xit "Provisioning Profile info" do
    info = AppleCertsInfo.provisioning_profile_list
    puts info
  end

  xit "Certificate Development info" do
    info = AppleCertsInfo.certificate_development_list
    puts info
  end

  xit "Certificate Distribution info" do
    info = AppleCertsInfo.certificate_distribution_list
    puts info
  end

  xit "limit days for Provisioning Profile" do
    info = AppleCertsInfo.provisioning_profile_list_limit_days_for(days: 56)
    puts info
  end

  xit "limit days for Certificate Development" do
    info = AppleCertsInfo.certificate_development_list_limit_days_for(days: 55)
    puts info
  end

  xit "limit days for Certificate Distribution" do
    info = AppleCertsInfo.certificate_distribution_list_limit_days_for(days: 21)
    puts info
  end
end
