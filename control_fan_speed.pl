#!/usr/bin/perl

use strict;
use warnings;

sub get_cpu_temp {
    my $cmd = "ipmitool sensor";
    open FIN, "$cmd|" or die "Can't run: $cmd\n";
    my $temp = undef;
    while(<FIN>) {
        my @fields = split /\|/;
        if ( $fields[0] =~ /CPU/ ) {
            $temp = $fields[1];
            $temp =~ s/^\s+//;
            $temp =~ s/\s+$//;
        }
    }
    close FIN;
    die "Could not parse CPU temperature!\n" unless (defined $temp);
    return $temp;
}

sub set_cpu_fan_speed {
    my($speed) = @_;
    my $speed_h = sprintf("0x%0x", $speed);
    my $cmd = "ipmitool raw 0x30 0x70 0x66 0x01 0x00 $speed_h";
    print "Executing: $cmd (speed=$speed, speed_h=$speed_h)\n";
    system($cmd);
    # TODO check rc
}

while(1) {
    my $temp = get_cpu_temp();
    print "temp='$temp'\n";
    if ($temp < 50) {
        set_cpu_fan_speed(0x30);
    } else {
        set_cpu_fan_speed(0x60);
    }
    sleep 5;
}
