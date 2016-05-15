#!/bin/bash
### BEGIN INIT INFO
# Provides:          PersonalFirewall
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Personal Firewall
# Description: This can by use for personal computer or web server. It is subject to change, and can be enhanced.
### END INIT INFO

# iptables IPV4 and IPV6
IPT=/sbin/iptables
IP6T=/sbin/ip6tables

# This function starts firewall
do_start() {

    # Erase all current rules. -F all. -X users
    $IPT -t filter -F
    $IPT -t filter -X
    $IPT -t nat -F
    $IPT -t nat -X
    $IPT -t mangle -F
    $IPT -t mangle -X
    #
    $IP6T -t filter -F
    $IP6T -t filter -X
    # no NAT for IPv6
    #$IP6T -t nat -F
    #$IP6T -t nat -X
    $IP6T -t mangle -F
    $IP6T -t mangle -X

    # default strategy (-P): drop all trafic (input, output and forward)
    $IPT -t filter -P INPUT DROP
    $IPT -t filter -P FORWARD DROP
    $IPT -t filter -P OUTPUT DROP
    #
    $IP6T -t filter -P INPUT DROP
    $IP6T -t filter -P FORWARD DROP
    $IP6T -t filter -P OUTPUT DROP

    # Loopback
    $IPT -t filter -A INPUT -i lo -j ACCEPT
    $IPT -t filter -A OUTPUT -o lo -j ACCEPT
    #
    $IP6T -t filter -A INPUT -i lo -j ACCEPT
    $IP6T -t filter -A OUTPUT -o lo -j ACCEPT

    # Allow all established connection to receive trafic
    $IPT -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IPT -t filter -A OUTPUT -m state ! --state INVALID -j ACCEPT
    #
    $IP6T -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    $IP6T -t filter -A OUTPUT -m state ! --state INVALID -j ACCEPT

  	## Drop XMAS scans and NULL scans.
  	$IPT -t filter -A INPUT -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP
  	$IPT -t filter -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
  	$IPT -t filter -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
  	$IPT -t filter -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
   	#
  	$IP6T -t filter -A INPUT -p tcp --tcp-flags FIN,URG,PSH FIN,URG,PSH -j DROP
  	$IP6T -t filter -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
  	$IP6T -t filter -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
  	$IP6T -t filter -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
   
  	## Drop all broadcasted packets
  	$IPT -t filter -A INPUT -m pkttype --pkt-type broadcast -j DROP
  	#
  	$IP6T -t filter -A INPUT -m pkttype --pkt-type broadcast -j DROP
  
   	## ICMP
    $IPT -t filter -A INPUT -p icmp -j ACCEPT
    #
    #$IP6T -t filter -A INPUT -p icmp -j ACCEPT
    #$IP6T -t filter -A OUTPUT -p icmp -j ACCEPT
  
  	## Log all packet
  	$IPT -t filter -A INPUT -j LOG
  	$IPT -t filter -A FORWARD -j LOG 
  	$IPT -t filter -A OUTPUT -j LOG 
  	#
  	$IP6T -t filter -A INPUT -j LOG
  	$IP6T -t filter -A FORWARD -j LOG 
  	$IP6T -t filter -A OUTPUT -j LOG 
  
    ## DNS
    $IPT -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
    $IPT -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
    #
    $IP6T -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
    $IP6T -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT    
  
  	## INTPUT
  	$IPT -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
    $IPT -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
  
    ## OUTPUT
    $IPT -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
  
  	#
  	echo "firewall started [OK]"
}

# This function stops firewall
do_stop() {

    # Erase all rules
    $IPT -t filter -F
    $IPT -t filter -X
    $IPT -t nat -F
    $IPT -t nat -X
    $IPT -t mangle -F
    $IPT -t mangle -X
    #
    $IP6T -t filter -F
    $IP6T -t filter -X
    #$IP6T -t nat -F
    #$IP6T -t nat -X
    $IP6T -t mangle -F
    $IP6T -t mangle -X

    # delete stategy
    $IPT -t filter -P INPUT ACCEPT
    $IPT -t filter -P OUTPUT ACCEPT
    $IPT -t filter -P FORWARD ACCEPT
    #
    $IP6T -t filter -P INPUT ACCEPT
    $IP6T -t filter -P OUTPUT ACCEPT
    $IP6T -t filter -P FORWARD ACCEPT

    #
    echo "firewall stopped [OK]"
}

# This function show firewall status
do_status() {

    # Show current rules
    clear
    echo Status IPV4
    echo -----------------------------------------------
    $IPT -L -n -v
    echo
    echo -----------------------------------------------
    echo
    echo status IPV6
    echo -----------------------------------------------
    $IP6T -L -n -v
    echo
}

case "$1" in
    start)
        do_start
        # exit without errors
        exit 0
    ;;

    stop)
        do_stop
        # exit without errors
        exit 0
    ;;

    restart)
        do_stop
        do_start
        # exit without errors
        exit 0
    ;;

    status)
        do_status
        # exit without errors
        exit 0
    ;;

    *)
        echo "Usage: firewall.sh {start|stop|restart|status}"
        # exit with error
        exit 1
    ;;

esac

exit 0
