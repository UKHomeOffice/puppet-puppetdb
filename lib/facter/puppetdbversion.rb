# puppetdbversion.rb
# Supply the PuppetDB version as a fact
# 
Facter.add("puppetdbversion") do
  confine :kernel => %w{Linux FreeBSD OpenBSD SunOS HP-UX GNU/kFreeBSD}
  setcode do
    versionfile = '/var/lib/puppet/puppetdbversion'
    val = ''
    if File.exists?(versionfile) and ((File.stat(versionfile).mtime.to_i + (12*60*60) >= Time.now().to_i) or File.size(versionfile) > 0)
      %x{cat #{versionfile}}.chomp.to_f
    else
      output = Facter::Util::Resolution.exec("/usr/bin/java -jar /usr/share/puppetdb/puppetdb.jar version 2>/dev/null | grep '^version'")
      output.chomp!
      if output.length >0
        val = output.split('=')[-1]
      elsif Facter.value(:osfamily) == 'RedHat'
        output = Facter::Util::Resolution.exec("/bin/rpm -q puppetdb --qf '%{VERSION}' 2>/dev/null")
        if output
          match = /^[\d.]+\d$/.match(output)
          if match 
            val = output.to_f
          end
        end
      else
        nil
      end
      unless val.nil?
        File.open(versionfile,'w') {|x| x.write(val)}
        val
      end
    end
  end
end
