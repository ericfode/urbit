::  link-proxy-hook: make local pages available to foreign ships
::
::TODO  we can probably write a proxy-hook lib! none of this is very interesting
::
/-  *link
::
|%
+$  state-0
  $:  %0
      active=(map path (set ship))
  ==
::
+$  card  card:agent:mall
--
::
=|  state-0
=*  state  -
::
^-  agent:mall
=<
  |_  =bowl:mall
  +*  this  .
      do    ~(. +> bowl)
      def   ~(. (default-agent this %|) bowl)
  ::
  ++  on-init  on-init:def
  ++  on-save  !>(state)
  ++  on-load
    |=  old=vase
    ^-  (quip card _this)
    ~&  [%load dap.bowl]  ::TMP
    [~ this(state !<(state-0 old))]
  ::
  ++  on-watch
    |=  =path
    ^-  (quip card _this)
    ::  the local ship should just use link-store directly
    ::TODO  do we want to allow this anyway, to avoid client-side target checks?
    ::
    ?<  (team:title [our src]:bowl)
    :_  this
    ?.  ?=([%local-pages ^] path)
      (on-watch:def path)
    =;  permitted=?
      ?.  permitted  (on-watch:def path)
      =^  cards  state
        (start-proxy:do src.bowl t.path)
      [cards this]
    ::TODO  alternatively, just see if ship is in group.
    ::      maybe need to do that while there's no group->perms mirror hook
    .^  ?
        %gx
        (scot %p our.bowl)
        %permission-store
        (scot %da now.bowl)
        (scot %p src.bowl)
        (snoc t.path %noun)
    ==
  ::
  ++  on-leave
    |=  =path
    ^-  (quip card _this)
    =^  cards  state
      (stop-proxy:do src.bowl t.path)
    [cards this]
  ::
  ++  on-agent
    |=  [=wire =sign:agent:mall]
    ?>  ?=([@ ^] wire)
    =/  =ship  (slav %p i.wire)
    ?-  -.sign
      %poke-ack   ~|([dap.bowl %unexpected-poke-ack ship t.wire] !!)
      %kick       ::TODO  forward kick
    ::
        %watch-ack
      ?~  p.sign
        =-  [[- ~] state]
        ::TODO  forward watch-ack
      =/  =tank
        :-  %leaf
        "{(trip dap.bowl)} failed subscribe to groups. very wrong!"
      %-  (slog tank u.p.sign)
      [~ state]
    ==
  ::
  ++  on-poke  on-poke:def
  ++  on-peek  on-peek:def
  ++  on-arvo  on-arvo:def
  ++  on-fail  on-fail:def
  --
::
|%
++  start-proxy
  |=  [who=ship =path]
  ^-  (quip card _state)
  !!  ::TODO
  ::TODO  use /inside/who/path wire ?
::
++  stop-proxy
  |=  [who=ship =path]
  ^-  (quip card _state)
  !!  ::TODO
--