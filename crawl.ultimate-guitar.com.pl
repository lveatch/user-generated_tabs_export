#!/usr/bin/perl

use LWP::UserAgent;
use HTTP::Request;
use URI::Heuristic;
use HTML::Entities;
use JSON;

my $type = shift || die "enter type (Chords, Tabs) for input.\n";
$type = ucfirst($type);

my $userAgent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Safari/605.1.15';

for my $pageNumber ( 1 .. 200) {
   my $pageText = ($pageNumber > 1) ? "page=$pageNumber&" : '';

   #my $raw_url = "https://www.ultimate-guitar.com/explore?order=songname_asc&${pageText}type[]=$type"; 
   my $raw_url = "https://www.ultimate-guitar.com/explore?${pageText}type[]=$type"; 
   print "getting page $pageNumber ... $raw_url \n";

   my $url = URI::Heuristic::uf_urlstr($raw_url);
   
   my $ua = LWP::UserAgent->new();
   $ua->agent($userAgent);
   
   $request = HTTP::Request->new(GET => $url);
   $request->referer('https://www.ultimate-guitar.com/');
   #print "request = $request\n";
   
   my $webRequest = $ua->request($request);
   #print "web request = $webRequest\n";
   
   if ($webRequest->is_success) {
       $webHtml =  $webRequest->decoded_content;  # or whatever
   }
   else {
       die $webRequest->status_line;
   }
   
    
   my @html = split(/\n/, $webHtml);

   my @sheet;
   
   foreach my $htmlLine (@html) {
      chomp $htmlLine;
   
      if ($htmlLine =~ m#<div class="js-store" data-content="(.+)"></div>#) {
         my $rawJson = $1;
         $rawJson =~ s/&quot;/"/g;
         #print "--> $rawJson\n";
   
         my @matches = ( $rawJson =~ m#(https://tabs.ultimate-guitar.com/tab/.+?)",#g );
   
         my $json = JSON->new->allow_nonref;
   
         my $jsonText = $json->decode( $rawJson );
   
         push @sheet,  @{ $jsonText->{'store'}->{'page'}->{'data'}->{'data'}->{'tabs'} };
   
   
         foreach my $tabHash (@sheet) {
            print "processing $tabHash->{'artist_name'} / $tabHash->{'song_name'} ....\n";
            getTab($tabHash);
   
         }
   
      }
   
   }
   
}


exit 0;



sub getTab
{
   my ($song_ref) = @_;

   my $raw_url = $song_ref->{'tab_url'};

   my $urlTab = URI::Heuristic::uf_urlstr($raw_url);
   
   my $uaTab = LWP::UserAgent->new();
   $uaTab->agent($userAgent);
   
   my $requestTab = HTTP::Request->new(GET => $urlTab);
   $requestTab->referer('https://www.ultimate-guitar.com/explore?type[]=Tabs');
   #print "request = $request\n";
   
   my $webRequest = $uaTab->request($requestTab);
   #print "web request = $webRequest\n";
   
   if ($webRequest->is_success) {
       $webHtml =  $webRequest->decoded_content;  # or whatever
   }
   else {
       die $webRequest->status_line;
   }
   
    
   my @html = split(/\n/, $webHtml);

   foreach my $htmlLine (@html) {
      chomp $htmlLine;
   
      if ($htmlLine =~ m#<div class="js-store" data-content="(.+)"></div>#) {
         my $rawJson = $1;
         $rawJson =~ s/&quot;/"/g;
         #print "--> $rawJson\n";

         my $json = JSON->new->allow_nonref;
   
         my $jsonText = $json->decode( $rawJson );
         #print "$jsonText->{'store'}->{'page'}->{'data'}->{'tab_view'}->{'wiki_tab'}->{'content'}\n";

         my $artist = $song_ref->{'artist_name'};
         $artist =~ s#/# #g;
         decode_entities($artist);
         my $song = $song_ref->{'song_name'};
         decode_entities($song);
         my $outName = "${artist}/${song}_v$song_ref->{'version'}_$song_ref->{'type_name'}.txt";

         mkdir "content/" unless (-e "content");
         mkdir "content/$artist" unless (-e "content/$artist");

         open (OUT, '>', "content/$outName") or warn "cannot write output (content/$outName) for write. $E\n";
         (my $content = $jsonText->{'store'}->{'page'}->{'data'}->{'tab_view'}->{'wiki_tab'}->{'content'}) =~ s#\r##gm;
         $content =~ s/\[.*tab\]//igm;
         $content =~ s/^amp;/&/igm;
         decode_entities($content);
         print OUT "$content\n";
         close OUT;

         return;
      }

   }

   return;
   
}


