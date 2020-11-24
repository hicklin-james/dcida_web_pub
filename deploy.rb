require 'net/sftp'
require 'date'
require 'colorize'

module Exceptions
  class DeployFailed < StandardError; end
end

m_folder = "/var/www/dcida_web"
r_folder = "/var/www/dcida_web/releases"
max_folders = 10

def print_command(com)
  puts "Execute: #{com}".yellow
end

def success_command(com)
  puts "Success: #{com}".green
end

def clean_after_fail(ssh, curr_date_time)
  ssh.exec! "rm -r /var/www/dcida_web/releases/#{curr_date_time}"
  #ssh.close
end

def get_folder_count(ssh, r_folder)
  count_com = "find #{r_folder}/* -maxdepth 0 -type d | wc -l"
  print_command(count_com)
  i = ssh.exec!(count_com).to_i
  success_command(count_com)
  puts "Folder count: #{i}".green
  i
end

begin
  puts "-------------------------------------------------------"
  puts "Starting DCIDA web app deployment"
  puts "-------------------------------------------------------"
  puts "\n"

  #ssh = Net::SSH.start('159.203.30.238', 'jameshicklin')
  ssh = Net::SSH.start(ENV['DEPLOYMENT_HOST'], ENV['DEPLOYMENT_USER'])

  # first, check that the releases folder exists
  folder_exists_com = "[ -d #{r_folder} ] && echo 1 || echo 0"
  print_command(folder_exists_com)
  f_exists = ssh.exec!(folder_exists_com).to_i
  if f_exists != 1
    raise Exceptions::DeployFailed.new("releases folder doesn't exist")
  end
  success_command(folder_exists_com)
  puts "\n"

  # next, create a new folder on the remote server
  # using the current datetime
  curr_date_time = Time.now.strftime("%Y%m%d%H%M%S")
  
  com = "mkdir #{r_folder}/#{curr_date_time}"
  print_command(com)
  ssh.exec! com do |ch, stream, data|
    if stream == :stderr
      raise Exceptions::DeployFailed.new("#{data}")
    end
  end
  success_command(com)
  puts "\n"

  # copy the dist folder over to the newest release folder
  print_command("Starting file copy")
  puts "-------------------------------------------------------"
  Net::SFTP.start(ENV['DEPLOYMENT_HOST'], ENV['DEPLOYMENT_USER']) do |sftp|
    sftp.upload!(Dir.pwd + "/dist", "#{r_folder}/#{curr_date_time}", :mkdir => false) do |event, uploader, *args|
      case event
      when :open then
        puts "Starting upload: #{args[0].local} -> #{args[0].remote} (#{args[0].size} bytes}".yellow
      when :put then
        puts "Writing #{args[2].length} bytes to #{args[0].remote} starting at #{args[1]}".yellow
      when :close then
        puts "Finished with #{args[0].remote}".green
      when :mkdir then
        puts "Creating directory #{args[0]}".yellow
      when :finish then
        puts "All done!".green
      end
    end
  end
  success_command("Finished file copy")
  puts "\n"

  # remove old symlink
  remove_symlink_command = "rm -rf #{m_folder}/current"
  print_command(remove_symlink_command)
  ssh.exec! remove_symlink_command
  success_command(remove_symlink_command)
  puts "\n"

  # symlink the shared folder stuff into the new  folder
  shared_symlink_command = "ln -s #{m_folder}/shared/* #{r_folder}/#{curr_date_time}"
  print_command(shared_symlink_command)
  ssh.exec! shared_symlink_command
  success_command(shared_symlink_command)
  puts "\n"

  # symlink the current folder to the newest release folder
  new_symlink_command = "ln -s #{r_folder}/#{curr_date_time} #{m_folder}/current"
  print_command(new_symlink_command)
  ssh.exec! new_symlink_command
  success_command(new_symlink_command)
  puts "\n"

  # count the number of folders in the releases folder, and delete the oldest one if neccessary
  folder_count = get_folder_count(ssh, r_folder)
  oldest_file_command = 'IFS= read -r -d $' + '\'\0\'' +  ' line < <(find ' + "#{r_folder}" + ' -maxdepth 1 -type d -printf ' + '\'%T@ %p\0\'' + ' | sort -z -n); file=\"${line#* }\"; echo $file;'
  
  puts "Deleting oldest deployments".green if folder_count > max_folders
  while folder_count > max_folders
    print_command(oldest_file_command)
    oldest_file = ssh.exec!(oldest_file_command).strip
    success_command(oldest_file_command)
    success_command("Oldest File: " + oldest_file)
    remove_file_command = "rm -rf #{oldest_file}"
    print_command(remove_file_command)
    ssh.exec! remove_file_command
    success_command(remove_file_command)
    folder_count = get_folder_count(ssh, r_folder)
  end
  puts "\n"

  puts "Deploy complete".green

rescue Exceptions::DeployFailed => e
  puts "Error: #{e}".red
  clean_after_fail(ssh, curr_date_time)
rescue Net::SSH::Exception => e
  puts "Error: SSH Connection error".red
  clean_after_fail(ssh, curr_date_time)
end