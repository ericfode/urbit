::  link: social bookmarking
::
/-  *link
::
|%
++  site-from-url
  |=  =url
  ^-  site
  =/  murl=(unit purl:eyre)
    (de-purl:html url)
  ?~  murl  'http://example.com'
  %^  cat  3
    ::  render protocol
    ::
    =*  sec  p.p.u.murl
    ?:(sec 'https://' 'http://')
  ::  render host
  ::
  =*  host  r.p.u.murl
  ?-  -.host
    %&  (roll (join '.' p.host) (cury cat 3))
    %|  (rsh 3 1 (scot %if p.host))
  ==
::NOTE  assumes pages are pre-sorted by timestamp
++  merge-pages
  |=  [a=pages b=pages]
  ^-  pages
  ?~  b  a
  ?~  a  b
  ?:  (gte time.i.a time.i.b)
    [i.a $(a t.a)]
  [i.b $(b t.b)]
::
++  en-json
  =,  enjs:format
  |%
  ++  page
    |=  =^page
    ^-  json
    %-  pairs
    :~  'title'^s+title.page
        'url'^s+url.page
        'timestamp'^(time time.page)
    ==
  --
::
++  de-json
  =,  dejs:format
  |%
  ++  page
    ^-  $-(json ^page)
    %-  ot
    :~  'title'^so
        'url'^so
        'timestamp'^di
    ==
  --
--