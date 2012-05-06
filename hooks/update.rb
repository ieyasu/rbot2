def check_reload
  if Dir['run/*.pid'].any? { |pid|
      service = pid.gsub(/run\/(.*)\.pid/, "services/\\1.rb")
      File.exist?(service) && File.mtime(service) > File.mtime(pid)
    }
    Process.kill('HUP', File.read('run/rubybot.pid').to_i)
    reply "\002*** Reloaded services\002"
  end
end

git = `git pull origin HEAD`
git.each_line { |line| reply line.strip }
check_reload
