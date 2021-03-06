module Serverspec
  module Commands
    class Base
      class NotImplementedError < Exception; end

      def check_enabled service
        raise NotImplementedError.new
      end

      def check_mounted path
        "mount | grep -w 'on #{path}'"
      end

      def check_reachable host, port, proto, timeout
        if port.nil?
          "ping -n #{host} -w #{timeout} -c 2"
        else
          "nc -vvvvz#{proto[0].chr} #{host} #{port} -w #{timeout}"
        end
      end

      def check_resolvable name, type
        if type == "dns"
          "nslookup -timeout=1 #{name}"
        elsif type == "hosts"
          "grep -w #{name} /etc/hosts"
        else
          "getent hosts #{name}"
        end
      end

      def check_file file
        "test -f #{file}"
      end

      def check_directory directory
        "test -d #{directory}"
      end

      def check_user user
        "id #{user}"
      end

      def check_group group
        "getent group | grep -wq #{group}"
      end

      def check_installed package
        raise NotImplementedError.new
      end

      def check_listening port
        "netstat -tunl | grep ':#{port} '"
      end

      def check_running service
        "service #{service} status"
      end

      def check_running_under_supervisor service
        "supervisorctl status #{service}"
      end

      def check_process process
        "ps aux | grep -w #{process} | grep -qv grep"
      end

      def check_file_contain file, expected_pattern
        "grep -q '#{expected_pattern}' #{file}"
      end

      def check_file_contain_within file, expected_pattern, from=nil, to=nil
        from ||= '1'
        to ||= '$'
        checker = check_file_contain("-", expected_pattern)
        "sed -n '#{from},#{to}p' #{file} | #{checker}"
      end

      def check_mode file, mode
        "stat -c %a #{file} | grep '^#{mode}$'"
      end

      def check_owner file, owner
        "stat -c %U #{file} | grep '^#{owner}$'"
      end

      def check_grouped file, group
        "stat -c %G #{file} | grep '^#{group}$'"
      end

      def check_cron_entry user, entry
        entry_escaped = entry.gsub(/\*/, '\\*')
        "crontab -u #{user} -l | grep \"#{entry_escaped}\""
      end

      def check_link link, target
        "stat -c %N #{link} | grep #{target}"
      end

      def check_installed_by_gem name
        "gem list --local | grep '^#{name} '"
      end

      def check_belonging_group user, group
        "id #{user} | awk '{print $3}' | grep #{group}"
      end

      def check_gid group, gid
        "getent group | grep -w ^#{group} | cut -f 3 -d ':' | grep -w #{gid}"
      end

      def check_uid user, uid
        "id #{user} | grep '^uid=#{uid}('"
      end

      def check_login_shell user, path_to_shell
        "getent passwd #{user} | cut -f 7 -d ':' | grep -w #{path_to_shell}"
      end

      def check_home_directory user, path_to_home
        "getent passwd #{user} | cut -f 6 -d ':' | grep -w #{path_to_home}"
      end

      def check_authorized_key user, key
        key.sub!(/\s+\S*$/, '') if key.match(/^\S+\s+\S+\s+\S*$/)
        "grep -w '#{key}' ~#{user}/.ssh/authorized_keys"
      end

      def check_iptables_rule rule, table=nil, chain=nil
        cmd = "iptables"
        cmd += " -t #{table}" if table
        cmd += " -S"
        cmd += " #{chain}" if chain
        rule.gsub!(/\-/, '\\-')
        cmd += " | grep '#{rule}'"
        cmd
      end

      def check_zfs zfs, property=nil, value=nil
        raise NotImplementedError.new
      end

      def get_mode(file)
        "stat -c %a #{file}"
      end

      def check_ipfilter_rule rule
        raise NotImplementedError.new
      end

      def check_ipnat_rule rule
        raise NotImplementedError.new
      end

      def check_svcprop svc, property, value
        raise NotImplementedError.new
      end

      def check_svcprops svc, property
        raise NotImplementedError.new
      end

      def check_selinux mode
        "/usr/sbin/getenforce | grep -i '#{mode}'"
      end
    end
  end
end
