# FastCTF
A tool for automating routine work during the passage of the CTF  
Need to run: Ruby on linux and (nmap,gobuster)  
This program helps to automate the basic process of collecting information.   
It uses nmap with automatically assigned flags to find open ports and if port 80 is open it uses GoBuster to find hidden directories. 
It also has the ability to search for subdomains by specifying the domain at the beginning
# Usage:
if you're have wordlists to scan you can input or using default wordlists, which in projects  
ruby Fast.rb 
