Au Geo
======

An application to provide 2 global and 1 Australian-specific API for use in client apps:
* /countries maps to a list of iso-3166-1 country code and names
* /subdivisions/:name maps to a list of iso-3166-2 subdivision (state/province/territory) code, name and country code's
* /localities/:name maps to a list of Australian localities

Contributing
============
Contributions are very welcome. We would love to see locality/post code database added

Acknowledgements/Sources
========================
Debian iso-codes package:
http://pkg-isocodes.alioth.debian.org/

Australian Bureau of Statistics: for Australian localities source
http://data.gov.au/4103 or http://data.gov.au/dataset/postal-areas-asgs-non-abs-structures-ed-2011/
http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.003July%202011?OpenDocument

AusPost: for Australian localities source
http://auspost.com.au/products-and-services/download-postcode-data.html

Josh.st:
http://josh.st/2012/02/11/auspost-suburb-postcode-free-license/

Usage
=====
Import the database schema and load the data via:
```ruby
rake db:schema:load db:seed
rails s
```

By default it will load Australian localities with the more free ABS data with
it's CC license. To use the AusPost data if you have permission simply run:
```ruby
rake db:seed AUS_POST_CSV=/path/to/pc-full_XXXXXXXX.csv
```

Requirements
============
You either need to iso-codes package installed in Debian/Ubuntu or it will download it from:

http://anonscm.debian.org/gitweb/?p=iso-codes/iso-codes.git;a=blob_plain;f=iso_3166/iso_3166.xml;hb=HEAD
http://anonscm.debian.org/gitweb/?p=iso-codes/iso-codes.git;a=blob_plain;f=iso_3166_2/iso_3166_2.xml;hb=HEAD

You will need to provide the Australian localties database and unzip it and place it in the db folder
before running the db:seed task

You can get this from:
http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.003July%202011?OpenDocument
* Download Postal Areas ASGS Non ABS Structures Edition 2011 in .csv Format 
* Download State Suburbs ASGS Non ABS Structures Edition 2011 in .csv Format 
http://auspost.com.au/products-and-services/download-postcode-data.html
* Download either basic or full zip file

Licence
=======
This project itself is just the standard MIT license, but for data has it own licenses.

The iso-3166 data comes from the debian iso-codes software packages and thus is
likely GPL or GPL compatible.

The Australian localities data has 2 options each with a difference license

Australian Bureau of Statistics:
License: Creative Commons license at http://creativecommons.org/licenses/by/2.5/au/

Australia Post:
License: http://auspost.com.au/products-and-services/download-postcode-data.html

Comparison of Data and License:
The ABS license is stringly recommended as it doesn't require permission.
The AusPost database has about twice as many localities, but these seem to be
mostly excessive detail of very small locations in regional areas.
