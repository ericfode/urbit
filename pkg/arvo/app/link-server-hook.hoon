::  link-server: accessing link-store via eyre
::
/-  *link
::
|%
+$  state  ~
--
::
|_  [=bowl:gall state]
::
++  prep
  |=  old=(unit state)
  ^-  (quip move _this)
  ~&  [%prep dap.bowl]
  ?~  old  [~ this]
  [~ this(+<+ u.old)]
::
++  poke-noun
  |=  action=?(%connect %disconnect %debug)
  ^-  (quip move _this)
  ?>  =(src.bowl our.bowl)
  ?-  action
      %connect
    [[ost.bowl %connect / [~ /'~link'] dap.bowl]~ this]
  ::
      %disconnect
    [[ost.bowl %disconnect / `binding:eyre`[~ /'~link']]~ this]
  ::
      %debug
    [~ this]
  ==
::
++  do-action
  |=  =action
  ^-  move
  [ost.bowl %poke / [our.bowl %link] %link-action action]
::
++  do-add
  |=  [title=@t url=@t]
  ^-  move
  (do-action %add title url)
::  +poke-handle-http-request: received on a new connection established
::
++  poke-handle-http-request
  %-  (require-authorization:app:server ost.bowl move this)
  |=  =inbound-request:eyre
  ^-  (quip move _this)
  ~&  [%incoming dap.bowl src.bowl method.request.inbound-request]
  ?.  =(src.bowl our.bowl)
    [[ost.bowl %http-response not-found]~ this]
  ::  request-line: parsed url+params
  ::
  =/  request-line
    %-  parse-request-line:server
    url.request.inbound-request
  =*  req-head  header-list.request.inbound-request
  ?+  method.request.inbound-request  !!
    %'OPTIONS'  =-  [[- ~] this]
                :+  ost.bowl  %http-response
                (include-cors-headers req-head [%start [200 ~] ~ &])
    %'POST'     (handle-post req-head request-line body.request.inbound-request)
    %'GET'      (handle-get req-head request-line)
  ==
::
++  handle-post
  |=  [request-headers=header-list:http =request-line:server body=(unit octs)]
  ^-  (list move)
  =-  ::TODO  =;  [success=? moves=(list move) =_this]
    =;  response=move
      [response moves]
    :+  ost.bowl  %http-response
    %+  include-cors-headers  ::TODO  not required for post?
      request-headers
    ^-  http-event:http
    [%start [?:(success 200 400) ~] ~ &]
  ^-  [success=? moves=(list move) =_this]
  ?~  body  [| ~ this]
  ?+  request-line  [| ~ this]
      [[~ [%'~link' %add ~]] ~]
    ^-  [? (list move) _this]
    =/  jon=(unit json)  (de-json:html q.u.body)
    ~&  [%attempted-add q.u.body jon]
    =+  ((ot title+so url+so ~):dejs-soft:format jon)
    ?~  -  [| ~]
    ~&  %success
    [& [(do-add [title url]:u) ~]]
  ==
::
++  handle-get
  |=  [request-headers=header-list:http =request-line:server]
  ^-  (quip move _this)
  =;  response=move
    [[response ~] this]
  :+  ost.bowl  %http-response
  %+  include-cors-headers
    request-headers
  ^-  http-event:http
  ::  args: map of params
  ::  p: pagination index
  ::
  =/  args
    %-  ~(gas by *(map @t @t))
    args.request-line
  =/  p=(unit @ud)
    %+  biff  (~(get by args) 'p')
    (curr rush dim:ag)
  ?+  request-line  not-found:app:server
  ::  links by recency, ?p=0 for pagination
  ::
      [[~ [%'~link' ~]] *]
    ~&  [%request-line dap.bowl request-line]
    %-  manx-response:app:server
    (index (get-submissions p))
  ::  links by recency as json
  ::
      [[[~ %json] [%'~link' ~]] *]
    %-  json-response:app:server
    %-  json-to-octs:server  ::TODO  include in json-response
    (turn (get-submissions p) page:en-json)
  ==
::
++  include-cors-headers
  |=  [request-headers=header-list:http =http-event:http]
  ^+  http-event
  ?.  ?=(%start -.http-event)  http-event
  =-  http-event(headers.response-header -)
  %+  weld  headers.response-header.http-event
  =/  origin=@t
    =/  headers=(map @t @t)
      (~(gas by *(map @t @t)) request-headers)
    (~(gut by headers) 'origin' '*')
  :~  'Access-Control-Allow-Origin'^origin
      'Access-Control-Allow-Credentials'^'true'
      'Access-Control-Request-Method'^'OPTIONS, GET, POST'
      'Access-Control-Allow-Methods'^'OPTIONS, GET, POST'
      'Access-Control-Allow-Headers'^'content-type'
  ==
--