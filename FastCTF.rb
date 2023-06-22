require 'socket'
require 'net/http'

class FastCTF
  def initialize(ip:, domain: '', subdomains_wordlist: '', directories_wordlist: '')
    @ip = ip
    @domain = domain
    @subdomains_wordlist = subdomains_wordlist
    @directories_wordlist = directories_wordlist
    @path_to_default_wordlist_for_dircheck = Dir.pwd + "/default_wordlists/directory-list-2.3-medium.txt"
    @path_to_default_wordlist_for_subdomains = Dir.pwd + "/default_wordlists/subdomains-top1million-110000.txt"
  end

  def run
    scan_with_nmap_and_gobuster
    scanning_directory
    scan_subdomains if want_to_scan_subdomains?
  end

  private

  def scanning_directory
    puts "[+] Input url(default will be use:ip)"
    url = gets.chomp
    if url.nil? || url.empty?
      File.open(@path_to_default_wordlist_for_dircheck, "r").each_line do |line|
        url_to_check = URI.parse("http://#{@ip}/#{line.chomp}")
        puts url_to_check
        http = Net::HTTP.new(url_to_check.host, url_to_check.port)
        request = Net::HTTP::Head.new(url_to_check)
        response = http.request(request)
        puts "[+] Scan will start"
        if response.code == '200'
          puts "[+] Directory found. #{line}"
          puts "|--> code: #{response.code}"
          puts "|--> Url #{url}"
        end
      end
    else
      File.open(@path_to_default_wordlist_for_dircheck, "r").each_line do |line|
        url_to_check = URI.parse(url + "/" + line.chomp)
        http = Net::HTTP.new(url_to_check.host, url_to_check.port)
        request = Net::HTTP::Head.new(url_to_check)
        response = http.request(request)
        puts "[+] Scan will start. "
        if response.code == '200'
          puts "[+] Directory found. #{line}"
          puts "|--> code: #{response.code}"
          puts "|--> Url #{url}"
        end
      end
    end
  end

  def scan_with_nmap_and_gobuster
    puts "[+] Scanning #{@ip}..."
    nmap = system("sudo nmap -vv -sS -sV -Pn #{@ip}")
    begin
      TCPSocket.new(@ip, 80)
      puts "[+] Port 80 open on #{@ip}"
      puts '[+] Starting directory checking'
      scanning_directory
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
      puts "[-] Port 80 closed on #{@ip}"
    end
  end

  def want_to_scan_subdomains?
    print 'Do you want to scan subdomains? (y/n): '
    response = gets.chomp
    if response.downcase == 'y'
      scan_subdomains
    end
  end

  def scan_subdomains
    if @domain.empty?
      puts '[-] You\'re not set domain - closing program'
    else
      run_gobuster_on_subdomains_wordlist
    end
  end

  def run_gobuster_on_subdomains_wordlist
    system("sudo gobuster dns -w #{@subdomains_wordlist} --domain #{@domain}")
  end
end

puts "
█▀▀ ▄▀█ █▀ ▀█▀ █ █▀▀ ▀█▀ █▀▀
█▀░ █▀█ ▄█ ░█░ ▄ █▄▄ ░█░ █▀░"
puts "Cʀᴇᴀᴛᴇᴅ ʙʏ ᴄ0ᴍʀᴀᴅᴇ"
sleep(1.5)

puts '[+] Input IP: '
ip = gets.chomp

puts '[+] Input domain name (you can skip this): '
domain = gets.chomp

puts '[+] Input path to wordlist for subdomains check (default: subdomains-top1million-110000.txt):'
subdomains_wordlist = gets.chomp

puts '[+] Input path to wordlist for directory check(default: directory-list-2.3-medium.txt): '
directories_wordlist = gets.chomp

FastCTF.new(
  ip: ip,
  domain: domain,
  subdomains_wordlist: subdomains_wordlist,
  directories_wordlist: directories_wordlist
).run
