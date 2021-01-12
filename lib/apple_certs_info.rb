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

  # Check Certificate file for iPhone/Apple Development in the KeyChain
  # @param days: limit days
  def self.certificate_development_list_limit_days_for(days:)
    raise "do not set days param" if days.nil?
    limit_days_for(days: days, type: "certificate_development")
  end

  # Check Certificate file for iPhone/Apple Distribution in the KeyChain
  def self.certificate_distribution_list_limit_days_for(days:)
    raise "do not set days param" if days.nil?
    limit_days_for(days: days, type: "certificate_distribution")
  end

  # Check Provisioning Profiles in the Directory that is ~/Library/MobileDevice/Provisioning Profiles/
  def self.provisioning_profile_list_limit_days_for(days:)
    raise "do not set days param" if days.nil?
    limit_days_for(days: days, type: "provisioning_profile")
  end

  def self.certificate_development_list
    certificate_list_for(name: "Development")
  end

  def self.certificate_distribution_list
    certificate_list_for(name: "Distribution")
  end

  def self.certificate_info_for(name:)
    raise "do not set name param" if name.nil?

    temp_pem_file = Tempfile.new(::File.basename("temp_pem"))

    begin
      `security find-certificate -a -c "#{name}" -p > #{temp_pem_file.path}`
      result = `openssl x509 -text -fingerprint -noout -in #{temp_pem_file.path}`
      puts(result) if @debug_log == true

      expire_datetime_match = result.match(/.*Not After :(.*)/)
      raise "not exits expire date" if expire_datetime_match.nil?

      expire_datetime = Time.parse(expire_datetime_match[1])

      cname_match = result.match(/Subject: .* CN=(.*), OU=.*/)
      raise "not exists cname" if cname_match.nil?
      cname = cname_match[1]

      limit_days = calc_limit_days(datetime: expire_datetime)

    rescue StandardError => e
      raise(e.message)
    ensure
      temp_pem_file.close && temp_pem_file.unlink
    end

    return {
        :expire_datetime => expire_datetime,
        :limit_days => limit_days,
        :cname => cname
    }
  end

  def self.provisioning_profile_list_info(dir: "~/Library/MobileDevice/Provisioning\\ Profiles/*.mobileprovision")
    info = []
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

      info << {
          :expire_datetime => expire_datetime,
          :limit_days => limit_days,
          :app_identifier => app_identifier,
          :app_id_name => app_id_name
      }
    end
    return info
  end

  private
  def self.limit_days_for(days:, type:)
    case type
    when "certificate_development" then
      list = certificate_development_list
    when "certificate_distribution" then
      list = certificate_distribution_list
    when "provisioning_profile" then
      list = provisioning_profile_list_info
    end
    puts(list) if @debug_log == true

    danger_list = []
    list.each do |info|
      danger_list << info if info[:limit_days] <= days
    end

    danger_list
  end

  def self.certificate_list_for(name:)
    result = `security find-certificate -a -c "#{name}"`
    name_match_list = result.scan(/.*alis".*=\"(.*)\".*/)
    puts(name_match_list) if @debug_log == true

    info = []
    name_match_list.each do|name_match|
      info << certificate_info_for(name:name_match[0])
    end

    info
  end

  def self.calc_limit_days(datetime:)
    ((datetime - Time.now)/(24*60*60)).ceil
  end
end
