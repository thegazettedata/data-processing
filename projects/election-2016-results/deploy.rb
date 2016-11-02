require 'net/ftp'

# Our FTP server
servdom = "sh2-d-ftp.newscyclecloud.com"

# Hide password in another file
# And open it
file = File.open(".ftppass", "r")
pass = file.read

servlog = pass.split(",")[0]
servpass = pass.split(",")[1]

# Login and drop off file
ftp = Net::FTP.new(servdom)
ftp.passive = true
ftp.login(servlog, servpass)
ftp.chdir("CDR-GA-Assets/static/feeds")
ftp.put("output/election-2016-results.json", "election-2016-results.json")
ftp.put("output/election-2016-results-simplified.json", "election-2016-results-simplified.json")
ftp.close