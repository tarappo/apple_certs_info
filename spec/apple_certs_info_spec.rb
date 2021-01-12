RSpec.describe AppleCertsInfo do
  it "has a version number" do
    expect(AppleCertsInfo::VERSION).not_to be nil
  end

  xit "provisioning profile info" do
    info = AppleCertsInfo.provisioning_profile_list_info
    puts(info)
  end

  it "sample" do
    info = AppleCertsInfo.certificate_distribution_list
    puts(info)

    info = AppleCertsInfo.certificate_development_list
    puts(info)
  end

  it "days" do
    list = AppleCertsInfo.provisioning_profile_list_limit_days_for(days: 55)
    puts(list)
    list = AppleCertsInfo.certificate_development_list_limit_days_for(days: 255)
    puts(list)
  end
end
