require "apple_certs_info/version"
require "time"
require "tempfile"

module AppleCertsInfo
  @debug_log = false
  class Error < StandardError; end

  def self.set_debug_log(flag)
    @debug_log = flag
  end
  def self.debug_log
    @debug_log
  end

  # Check Certificate file for iPhone Developer /Apple Development in the KeyChain
  # @param days: limit days
  # @return:
  #   expire_datetime: deadline
  #   limit_days: limit days
  #   cname: CN
  def self.certificate_development_list_limit_days_for(days:)
    raise "do not set days param" if days.nil?
    filtering_limit_days_for(list: certificate_development_list.uniq, days: days)
  end

  # Check Certificate file for iPhone/Apple Distribution in the KeyChain
  # @param days: limit days
  # @return:
  #   expire_datetime: deadline
  #   limit_days: limit days
  #   cname: CN
  def self.certificate_distribution_list_limit_days_for(days:)
    raise "do not set days param" if days.nil?
    filtering_limit_days_for(list: certificate_distribution_list.uniq, days: days)
  end

  # Check Provisioning Profiles in the Directory that is ~/Library/MobileDevice/Provisioning Profiles/
  # @param days: limit days
  # @return:
  #   expire_datetime: deadline
  #   limit_days: limit days
  #   app_identifier: Bundle Identifier
  #   app_id_name => App ID Name
  def self.provisioning_profile_list_limit_days_for(days:)
    raise "do not set days param" if days.nil?
    filtering_limit_days_for(list: provisioning_profile_list.uniq, days: days)
  end

  # All iPhone Developer and Apple Development List
  def self.certificate_development_list
    list = []
    iphone_list = certificate_list_for(name: "iPhone Developer")
    apple_list = certificate_list_for(name: "Apple Development")
    list.concat(iphone_list) unless iphone_list.nil?
    list.concat(apple_list) unless apple_list.nil?
    return list
  end

  # All iPhone Distribution and Apple Distribution List
  def self.certificate_distribution_list
    list = []
    iphone_list = certificate_list_for(name: "iPhone Distribution")
    apple_list = certificate_list_for(name: "Apple Distribution")
    list.concat(iphone_list) unless iphone_list.nil?
    list.concat(apple_list) unless apple_list.nil?
    return list
  end

  # Provisioning Profile List
  def self.provisioning_profile_list(dir: "~/Library/MobileDevice/Provisioning\\ Profiles/*.mobileprovision")
    list = []
    Dir.glob("#{File.expand_path(dir)}") do |file|
      file_name_match =  file.match(/.*\/(.*)\.mobileprovision/)
      raise "not exists Provisioning Profile" if file_name_match.nil?

      file_name = file_name_match[1]
      temp_plist_file = Tempfile.new(::File.basename(file_name))
      plist_file = temp_plist_file.path

      begin
        # exchange plist file
        system("security cms -D -i '#{file}' > #{plist_file}")

        # checking plist file
        expire_datetime = Time.parse(`/usr/libexec/PlistBuddy -c 'Print ExpirationDate' #{plist_file}`)
        app_identifier = `/usr/libexec/PlistBuddy -c 'Print Entitlements:application-identifier' #{plist_file}`.chomp
        app_id_name = `/usr/libexec/PlistBuddy -c 'Print AppIDName' #{plist_file}`.chomp

        limit_days = calc_limit_days(datetime: expire_datetime)

      rescue StandardError => e
        raise(e.message)
      ensure
        temp_plist_file.close && temp_plist_file.unlink
      end

      list << {
          :expire_datetime => expire_datetime,
          :limit_days => limit_days,
          :app_identifier => app_identifier,
          :app_id_name => app_id_name,
          :file_path => file_name_match[0]
      }
    end
    return list
  end

  # Certificate Information for target name
  # @return
  #   expire_datetime: deadline
  #   limit_days: limit days
  #   cname: CN
  def self.certificate_info_for(name:)
    raise "do not set name param" if name.nil?

    info = []
    begin
      temp_pem_file = certificate_exchange_pem_file_for(name: name)
      result = `openssl crl2pkcs7 -nocrl -certfile #{temp_pem_file.path} | openssl pkcs7 -print_certs -text -noout`

      expire_datetime_match = result.scan(/.*Not After :(.*)/)
      raise "not exits expire date" if expire_datetime_match.nil?

      cname_match = result.match(/Subject: .* CN=(.*), OU=.*/)
      raise "not exists cname：#{result}" if cname_match.nil?

      expire_datetime_match.each do |original_datetime|
        expire_datetime = Time.parse(original_datetime.first)
        limit_days = calc_limit_days(datetime: expire_datetime)
        cname = cname_match[1] # cname is same

        info << {
            :expire_datetime => expire_datetime,
            :limit_days => limit_days,
            :cname => cname,
        }
      end
    rescue StandardError => e
      raise(e.message)
    ensure
      temp_pem_file.close && temp_pem_file.unlink
    end

    return info
  end


  private
  def self.certificate_list_for(name:)
    result = `security find-certificate -a -c "#{name}" -Z`
    name_match_list = result.scan(/.*alis".*=\"(.*)\".*/)
    puts(name_match_list) if @debug_log == true

    info = []
    name_match_list.uniq.each do|name_match|
      info << certificate_info_for(name:name_match[0])
    end

    info.flatten!
  end

  # filtering list
  def self.filtering_limit_days_for(list:, days:)
    danger_list = []
    list.each do |info|
      danger_list << info if info[:limit_days].to_i <= days.to_i
    end

    danger_list
  end

  # exchange pem file
  # @param name: unique name
  def self.certificate_exchange_pem_file_for(name:)
    temp_pem_file = Tempfile.new(::File.basename("temp_pem"))
    `security find-certificate -a -c "#{name}" -p > #{temp_pem_file.path}`

    temp_pem_file
  end

  def self.calc_limit_days(datetime:)
    ((datetime - Time.now)/(24*60*60)).ceil
  end
end
