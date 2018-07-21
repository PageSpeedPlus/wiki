[ClamAV](https://camo.githubusercontent.com/6981ba6e06eba6bd6de034992ab16b9f7782bba7/687474703a2f2f7777772e636c616d61762e6e65742f6173736574732f636c616d61762d74726164656d61726b2e706e67

There aren't many viruses made for Linux distributions and as such, most people who use such systems don't even bother using an antivirus software. Those however who do want to be able to scan their system or other Windows-based systems that are connected to a Linux PC through a network, they can use ClamAV. ClamAV is an open source anti-virus engine that is built to detect viruses, trojans, malware and other threats. It supports multiple file formats (documents, executables or archives), utilizes multi-thread scanner features and receives updates for its signature database at least 3-4 times a day.

The first step is to install and get the latest signature updates. To do this on Ubuntu, you can open a terminal and insert “sudo apt-get install clamav” and press enter.

**> sudo apt-get install clamav**

You may also build ClamAV from sources to benefit from better scanning performance. To update the signatures, you type “sudo freshclam” on a terminal session and press enter.

**> sudo freshclam**

Now we are ready to scan our system. To do this, you can use the “clamscan” command. This is a rich command that can work with many different parameters so you'd better insert “clamscan –-help” on the terminal first and see the various things that what you can do with it.

`**clamscan –-help**`

**Clamscan help**

So, I will demonstrate a scan on my “Downloads” folder located under the home directory and I will choose to output only infected files and ring a bell when (and if) they are found. This translates to the following command on the terminal: “clamscan -r --bell -i /home/bill/Downloads”.

`**clamscan -r --bell -i /home/bill/Downloads**`

### Scan a directory for viruses with clamscan

To scan the whole system (it may take a while) and remove all infected files in the process, you can use the command in the following form: “clamscan -r --remove /”.

**> clamscan -r --remove /**

Sometimes, simply removing infected files can cause even more problems or breakages. I suggest that you should always check the output first and then take manual action. Alternatively, you may also use the “move” command integrated as a parameter in the form of” “--move=/home/bill/my_virus_collection” (example directory).

