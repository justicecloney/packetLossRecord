#!/usr/bin/perl

#use strict;
#use warnings;

my $packetCount = 4;

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
push(@rows, "timeStarted,timeTaken,ip,lossPct,bounceData,bounceNumber,failureSection,packetsSent,packetsReceived\n" );

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

sub main (){
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

    print "Beginning program\n";
    print "pinging various sites\n";
    
    foreach my $site (@sites){
        my $log = "";
        my $timeStarted     = time();
        my $timeTaken       = ();
        my $ip              = ();
        my $lossPct         = ();
        my $bounceData      = ();
        my $bounceNumber    = ();
        my $failureSection  = ();
        my $packetsSent     = ();
        my $packetsReceived = ();

        open( my $CH, "ping " . $site . " -c ".$packetCount."|");
        while (  my $line = <$CH> ){
            $log .= $line;
        }
        close($CH);
        $timeTaken = time() - $timeStarted;
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
        $bounceData     = "TODO";
        $bounceNumber   = "TODO";
        $failureSection = "TODO";
        $packetsSent    = $packetCount;
        if ( $log =~ /(\d{1,$packetCount}) received/ ){
            $packetsReceived = $1;
        }
        # print "pushing the following: $timeStarted :: $timeTaken :: $ip :: $lossPct :: $bounceData :: $bounceNumber :: $failureSection :: $packetsSent :: $packetsReceived\n";
        push(@rows, "$timeStarted,$timeTaken,$ip,$lossPct,$bounceData,$bounceNumber,$failureSection,$packetsSent,$packetsReceived\n" );
        # push( @{$data{"timeStarted"}}, $timeStarted );
        # push( @{$data{"timeTaken"}}, $timeTaken );
        # push( @{$data{"ip"}}, $ip );
        # push( @{$data{"lossPct"}}, $lossPct );
        # push( @{$data{"bounceData"}}, $bounceData );
        # push( @{$data{"bounceNumber"}}, $bounceNumber );
        # push( @{$data{"failureSection"}}, $failureSection );
        # push( @{$data{"packetsSent"}}, $packetsSent );
        # push( @{$data{"packetsReceived"}}, $packetsReceived );
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



main();
