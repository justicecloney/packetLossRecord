#!/usr/bin/perl

#use strict;
#use warnings;

my $totalRuns = 1; # if zero, runs indefinably, otherwise this many times
my $packetCount = 50; # how many packets each ping command runs
my $delayInterval = 1800; # time in seconds between bouts of pings
my @sites = (
    "www.google.com",
    "www.youtube.com",
    "www.facebook.com",
    "www.crunchyroll.com",
    "www.twitch.tv",
    "www.twitter.com",
    "www.stackoverflow.com",
    "www.regexr.com",
    "www.na.finalfantasyxiv.com",
    "www.wikipedia.org",
    "www.mozilla.org",
    "www.netflix.com",

);
#
# my %data = {
#     "timeStarted"     => [],
#     "timeTaken"       => [],
#     "ip"              => [],
#     "lossPct"         => [],
#     "bounceData"      => [],
#     "bounceNumber"    => [],
#     "failureSection"  => [],
#     "packetsSent"     => [],
#     "packetsReceived" => [],
# };
my @rows = ();
push(@rows, "timeStarted,timeTaken,site,ip,lossPct,bounceData,bounceNumber,failureSection,packetsSent,packetsReceived\n" );

sub dealWithSetting {
    my ($settings) = @_;
    return 0;
}

sub writeFile {
    my ($text, $file) = @_;
    my $err = eval {
        open(my $fh, '>', $file);
        print $fh $text;
        close $fh;
    }; $store = $@;
    if (length($store)){
        print "could not write file. error returned: " . $store;
        die;
    }
}

sub doPing (){
    my $settings = "settings.txt";
    my $err;
    if ( -f $settings){
        print "found settings file\n";
        $err = eval{
            open (my $fh, '<:encoding(UTF-8)', $settings);
        }; $store = $@;
        if (length($store)){
            print "error reading in settings. Error returned: \n" . $store . "\n";
            die;
        }
        while (my $setting = <$fh>){
            chomp $setting;
            dealWithSetting($setting);
        }
    }
    else {
        print "no settings file found, making new one.\n";
        $err = eval {
            open(my $fh, '>', $settings);
            print $fh "test=test";
            close $fh;
        }; $store = $@;
        if (length($store)){
            print "could not make a new file. error returned: " . $store;
            die;
        }
    }
    foreach my $site (@sites){
        print "beginning ping on " . $site . "\n";
        my $log = "";
        my $timeTaken       = ();
        my $ip              = ();
        my $lossPct         = ();
        my $bounceData      = ();
        my $bounceNumber    = ();
        my $failureSection  = ();
        my $packetsSent     = ();
        my $packetsReceived = ();
        my $timeStarted     = time();
        open( my $CH, "ping " . $site . " -c ".$packetCount."|");
        while (  my $line = <$CH> ){
            $log .= $line;
        }
        close($CH);
        $timeTaken = time() - $timeStarted;
        # TODO: Account for "unknown host" failure
        ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timeStarted);
        $timeStarted = sprintf("%04d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec);
        ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($timeTaken);
        $timeTaken = "";
        if ($year){
            #holy shit your ping took years?
        }
        if ($hour){
            $timeTaken = $hour ." hours,"; # seriously what the fuck
        }
        if ($min){
            $timeTaken = $min ." minutes,";
        }
        if ($sec){
            $timeTaken = $sec ." seconds,";
        }
        chop($timeTaken);
        if ( $log =~ /(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})/ &&(($1<=255  && $2<=255 && $3<=255  &&$4<=255 ))){
            $ip = $1 . "." . $2 . "." . $3 . "." . $4
        }
        if ( $log =~ /(\d{1,3})\% packet loss/ ){
            $lossPct = $1;
        }
        print "ping complete, packet loss is " . $lossPct . "\n";
        if ($lossPct > 0){
            print "packet loss detected.\n";
            $bounceData     = "TODO";
            $bounceNumber   = "TODO";
            $failureSection = "TODO";
        }
        $packetsSent    = $packetCount;
        if ( $log =~ /(\d{1,$packetCount}) received/ ){
            $packetsReceived = $1;
        }
        # print "pushing the following: $timeStarted :: $timeTaken :: $ip :: $lossPct :: $bounceData :: $bounceNumber :: $failureSection :: $packetsSent :: $packetsReceived\n";
        push(@rows, "$timeStarted,$timeTaken,$site,$ip,$lossPct,$bounceData,$bounceNumber,$failureSection,$packetsSent,$packetsReceived\n" );
        # traceroute 
    }
    print "done pinging\n";

    print "\n\n";

    # my $pingLog = `ping www.google.com -c 4`;
    # print "done pinging goggle \n";
    # writeFile(@rows, "pingLog_" . time() . ".txt");
    my $err = eval {
        open(my $fh, '>', "pingLog_" . time() . ".csv");
        foreach my $line (@rows){
            print $fh $line;
        }
        close $fh;
    }; $store = $@;
    if (length($store)){
        print "could not write file. error returned: " . $store;
        die;
    }
}

sub main(){
    print "beginning program.\n";
    print "total runs = " . $totalRuns ."\n";
    if ($totalRuns > 0){
        for (my $i = 0; $i < $totalRuns; $i++){
            doPing();
            unless ($i == $totalRuns){
                sleep($delayInterval);
            }
        }
    }
    else{
        while (true){
            doPing();
            sleep($delayInterval);
        }
    }
    print "all done\n";
}

main();
