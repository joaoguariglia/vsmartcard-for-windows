# vsmartcard-for-windows
Version 1.0

This project is an extension of Frank's work.
https://github.com/frankmorgner/vsmartcard

This project is a windows client that makes a connection to a linux server running vpicc, and through this linux server running vpicc makes a reverse call to windows vpcd. Here is a very simple flow chart below for understanding

# Step A
Windows (VPCD) ---- Request via LAN (ssh) ---> Linux (vpicc)

Information Request via ssh for Linux:
* Windows ip
* Linux ssh user
* Linux ssh password
* Command for linux vpicc ready (vicc -vvvvv --type relay --hostname (WINDOWS IP)

# Step B
Smartcard -> Linux (vpicc) ---> request accepted --- >> Windows (VPCD)

# Step C
Windows (VPCD) ---> start driver (BixVirtualReader) ---> and emulates the connected smartcard in Linux

Note: The project is in Portuguese Brazil since I am Brazilian and it is still in version 1.0

Watch the sample video:
https://www.youtube.com/watch?v=D3eTqS0w6oc
