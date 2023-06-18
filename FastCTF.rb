require 'socket'

class FastCTF
  def initialize(ip:, domain: '', subdomains_wordlist: '', directories_wordlist: '')
    @ip = ip
    @domain = domain
    @subdomains_wordlist = subdomains_wordlist
    @directories_wordlist = directories_wordlist
  end

  def run
    scan_with_nmap_and_gobuster
    scan_subdomains if want_to_scan_subdomains?
  end

  private

  def scan_with_nmap_and_gobuster
    puts "[+] Scanning #{@ip}..."
    nmap = system("sudo nmap -vv -sS -sV -Pn #{@ip}")
    begin
      TCPSocket.new(@ip, 80)
      puts "[+] Port 80 open on #{@ip}"
      puts '[+] Starting gobuster'
      run_gobuster_on_directory_wordlist
    rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
      puts "[-] Port 80 closed on #{@ip}"
    end
  end

  def run_gobuster_on_directory_wordlist
    system("sudo gobuster dir -w #{@directories_wordlist} --url #{@ip} -x txt,php,js,css")
  end

  def want_to_scan_subdomains?
    print 'Do you want to scan subdomains? (y/n): '
    gets.chomp.downcase == 'y'
  end

  def scan_subdomains
    if @domain.empty?
      puts '[-] You\'re not set domain - closing program'
    else
      run_gobuster_on_subdomains_wordlist
    end
  end

  def run_gobuster_on_subdomains_wordlist
    system("gobuster dns -w #{@subdomains_wordlist} --domain #{@domain}")
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
puts '[+] Input path to wordlist for subdomains check (you can skip this): '
subdomains_wordlist = gets.chomp
puts '[+] Input path to wordlist for directory check: '
directories_wordlist = gets.chomp

FastCTF.new(
  ip: ip,
  domain: domain,
  subdomains_wordlist: subdomains_wordlist,
  directories_wordlist: directories_wordlist
).run
