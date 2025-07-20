
Will download the content from the first 200 pages (50 per page) of "Today's Most Popular" on the "Explore chords and tabs" page.

Only tested on Ubuntu.

Will store text files as content/[artist name]/[song_name].{type}.txt where type is Tabs or Cords.


### Will need to have Perl installed with the following modules:
```
 LWP::UserAgent
 HTTP::Request
 URI::Heuristic
 HTML::Entities
 JSON
```

### To execute at the command line:
```
perl crawl.ultimate-guitar.com.pl Tabs
perl crawl.ultimate-guitar.com.pl Cords
```

Wrote this based on a reddit posting and I was bored today and wanted to see if I could pull the data.
