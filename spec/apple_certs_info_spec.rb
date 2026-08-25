RSpec.describe AppleCertsInfo do
  it "has a version number" do
    expect(AppleCertsInfo::VERSION).not_to be nil
  end

  describe ".calc_limit_days" do
    def calc_limit_days(datetime)
      AppleCertsInfo.send(:calc_limit_days, datetime: datetime)
    end

    it "returns the number of days until the expiration date" do
      expect(calc_limit_days(Time.now + (60 * 60 * 24 * 10))).to eq 10
    end

    it "returns 0 on the expiration date" do
      expect(calc_limit_days(Time.now)).to eq 0
    end

    it "returns a negative number when already expired" do
      expect(calc_limit_days(Time.now - (60 * 60 * 24 * 3))).to eq(-3)
    end
  end

  describe ".filtering_limit_days_for" do
    let(:list) do
      [
        { :cname => "expired", :limit_days => -1 },
        { :cname => "today", :limit_days => 0 },
        { :cname => "boundary", :limit_days => 10 },
        { :cname => "safe", :limit_days => 11 },
      ]
    end

    def filtering(days)
      AppleCertsInfo.send(:filtering_limit_days_for, list: list, days: days)
    end

    it "keeps entries whose limit_days is less than or equal to days" do
      expect(filtering(10).map { |info| info[:cname] }).to eq %w[expired today boundary]
    end

    it "excludes entries beyond the boundary" do
      expect(filtering(10)).not_to include(a_hash_including(:cname => "safe"))
    end

    it "returns an empty list when nothing is close to expiring" do
      expect(filtering(-10)).to be_empty
    end
  end

  describe "limit days for certificates" do
    let(:development_list) do
      [
        { :cname => "Apple Development: soon", :limit_days => 5 },
        { :cname => "Apple Development: later", :limit_days => 100 },
      ]
    end

    it "returns only certificates close to expiring" do
      allow(AppleCertsInfo).to receive(:certificate_development_list).and_return(development_list)

      result = AppleCertsInfo.certificate_development_list_limit_days_for(days: 10)
      expect(result.map { |info| info[:cname] }).to eq ["Apple Development: soon"]
    end

    it "removes duplicated entries" do
      allow(AppleCertsInfo).to receive(:certificate_distribution_list)
        .and_return(development_list + development_list)

      result = AppleCertsInfo.certificate_distribution_list_limit_days_for(days: 10)
      expect(result.size).to eq 1
    end

    it "raises when days is not given" do
      expect { AppleCertsInfo.certificate_development_list_limit_days_for(days: nil) }
        .to raise_error("do not set days param")
      expect { AppleCertsInfo.certificate_distribution_list_limit_days_for(days: nil) }
        .to raise_error("do not set days param")
      expect { AppleCertsInfo.provisioning_profile_list_limit_days_for(days: nil) }
        .to raise_error("do not set days param")
    end
  end

  describe "internal methods" do
    it "is not exposed as a public API" do
      expect(AppleCertsInfo).not_to respond_to(:calc_limit_days)
      expect(AppleCertsInfo).not_to respond_to(:filtering_limit_days_for)
      expect(AppleCertsInfo).not_to respond_to(:certificate_list_for)
      expect(AppleCertsInfo).not_to respond_to(:certificate_exchange_pem_file_for)
    end
  end

  describe "debug log flag" do
    after { AppleCertsInfo.set_debug_log(false) }

    it "holds the given flag" do
      expect { AppleCertsInfo.set_debug_log(true) }
        .to change { AppleCertsInfo.debug_log }.from(false).to(true)
    end
  end

  # The following need the macOS keychain / provisioning profiles, so they stay opt-in.
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
