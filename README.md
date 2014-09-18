graylog2_ubuntu
===============

Installation script of Graylog2 packages on Ubuntu

This installation script will perform an automated install of Graylog2 (Server & Web), ElasticSearch and MongoDB on Ubuntu 12.04/12.10 and higher, based on Debian packages of Graylog2.
The script allows to set the Email Transport config.


It is based on @mrlesmithjr 's script https://github.com/mrlesmithjr

----------------------
| Installation steps |
----------------------

1. Install Git
--------------
```bash
sudo apt-get -y install git
```

2. Clone the Rep
----------------
```bash
cd ~
git clone https://github.com/tontonjulien/graylog2_ubuntu.git
```

3. Make the script executable
-----------------------------
```bash
cd graylog2_ubuntu
chmod +x install_graylog2_ubuntu.sh
sudo ./install_graylog2_ubuntu.sh
```
4. Answer to the questions
--------------------------
Password, email config etc...

5. Test the Interface
---------------------
In your browser: localhost:9000
You should see the login page

Enjoy!!
