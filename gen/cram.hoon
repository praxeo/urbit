::
::::  hoon/cram/gen
  ::
  ::  test generator for the cram markdown syntax
  ::
  ::  todo: integrate with ++sail and embed in hoon compiler
  ::
  ::  ++cram is a simple markdown-inspired parser that makes
  ::  common html tropes easy to type.  you can think of ++cram
  ::  as "rational markdown" or "markdown with syntax errors."
  ::  a document format should be easy to type and read, but
  ::  that doesn't mean it can't or have rigorous syntax.
  ::
  ::  tldr: ++cram is indent-oriented.  indent 2 spaces for
  ::  a dynamic interpolation, 4 spaces for example code, 6
  ::  spaces for a blockquote and 8 spaces for verse.  separate
  ::  every semantic block by a blank line.  use - for
  ::  unordered lists, + for ordered lists.
  ::
  ::  markdown link syntax works.  * means bold, _ means
  ::  italics, "" inserts smart quotes.  all enclosed
  ::  strings are reparsed; escape the terminator within
  ::  the string, eg, *star \* in bold text*.
  ::
  ::  markdown `literal` syntax is supported, but all hoon
  ::  constants are automatically marked as code.  also, any
  ::  hoon expression prefixed with # is a code literal.
  ::
  ::  (++cram is a valid hoon parsing rule, but it does a lot
  ::  of custom processing internally, since the language is
  ::  context-sensitive.  we use a context-sensitive parser
  ::  to cut the lines into blocks, then reparse flow blocks
  ::  with normal hoon rules.  multipass parsing is the tax
  ::  humans have to pay for simple but human-friendly syntax.)
  ::
=>
|%
++  dynamic
  |%
  ++  mane  $@(@tas {@tas @tas})                          ::  XML name+space
  ++  manx  {g/marx c/marl}                               ::  XML node
  ++  marl  (list $^(manx tuna))                          ::  XML node list
  ++  mart  (list {n/mane v/(list beer)})                 ::  XML attributes
  ++  marx  {n/mane a/mart}                               ::  XML tag
  ++  tuna  {?($tape $manx $marl $call) p/twig}
  --
::
++  freeze
  |=  manx:dynamic  ^-  manx
  :-  [n.g (turn a.g freeze-mart)]
  %+  turn  c
  |=(a/=>(dynamic $^(manx tuna)) ?@(-.a !! (freeze a)))
::
++  freeze-mart
  |=  {n/mane v/(list beer)}  ^-  {mane tape}
  [n (turn v |=(a/beer ?^(a !! a)))]
::
::+|
::
++  steam
  |=  manx:dynamic  ^-  twig:manx
  [[(steam-mane n.g) %conl (turn a.g steam-mart)] (steam-marl c)]
::
++  steam-marl
  !.
  |=  a/marl:dynamic  ^-  twig:marl
  ?~  a  [%conl ~]
  ?-  -.i.a
    ^      [(steam i.a) $(a t.a)]
    $manx  [p.i.a $(a t.a)]
    $tape  [[%nub p.i.a] $(a t.a)]
    $call  [%call p.i.a [$(a t.a)]~]
    $marl  [%lace [p.i.a $(a t.a)] cons-gate-twig]
  ==
::
++  cons-gate-twig
  ^-  twig
  :+  %new  [%base %cell]
  :-  %core
  ^-  (map term foot)
  :_  [~ ~]
  =+  sug=[[%& 12] ~]
  :+  %$  %elm
  :^  %ifno  sug
    [%make sug [[[[%& 1] ~] [%$ 13]] ~]]
  [%make sug [[[[%& 3] ~] [%make [%$ ~] [[sug [%$ 25]] ~]]] ~]]
::
++  steam-mane
  |=  a/mane  ^-  twig
  ?@(a [%rock %tas a] [[%rock %tas -.a] [%rock %tas +.a]])
::
++  steam-mart
  |=  {n/mane v/(list beer)}
  [(steam-mane n) %knit v]
::
::+|
::
++  beet  $@  @                                         ::  advanced embed
          $%  {$tape p/twig}                            ::  take tape
              {$manx p/twig}                            ::  take manx
              {$marl p/twig}                            ::  take marl
              {$call p/twig}                            ::  take $-(marl marl)
              {$elem p/twig q/(list tuna)}              ::  element literal
          ==                                            ::
::
++  tuna                                                ::  tagflow
          $%  {$tape p/twig}                            ::  plain text
              {$manx p/twig}                            ::  single tag
              {$marl p/twig}                            ::  simple list
              {$call p/twig}                            ::  dynamic list
              {$elem p/twig q/(list tuna)}              ::  element
              {$many p/(list tuna)}                     ::  subflow
          ==                                            ::
::
++  sail                                              ::  xml template
  =>  dynamic
  |=  in-tall-form/?  =|  lin/?
  |%
  ++  apex                                              ::  entry point
    ;~(pfix sem ?:(in-tall-form tall-top wide-top))
  ::
  ++  single  !.  |*(a/rule (cook |=(b/$^(manx tuna) [b]~) a))
  ++  tall-top                                             ::  tall top
    %+  knee  *marl  |.  ~+
    ;~  pose
      ;~(pfix (plus ace) (cook collapse-chars quote-innards))
      (single ;~(plug script-or-style script-style-tail))
      (single tall-elem)
      wide-quote
      ;~(pfix tis tall-tail)
      (single ;~((glue gap) tuna-mode tall:vast))
      (easy [;/("\0a")]~)
    ==
  ::
  ++  tuna-mode
    ;~  pose
      (cold %tape hep)
      (cold %manx lus)
      (cold %marl tar)
      (cold %call cen)
    ==
  ++  wide-top                                             ::  wide outer top
    %+  knee  *marl  |.  ~+
    ;~  pose
      wide-quote
      wide-paren-elems
      (single ;~(plug tag-head wide-tail))
    ==
  ::
  ++  wide-inner-top                                             ::  wide inner top
    %+  knee  *marl  |.  ~+
    ;~  pose
      wide-top
      (single ;~(plug tuna-mode wide:vast))
    ==
  ::
  ++  a-mane                                             ::  mane as twig
    %+  cook
      |=  {a/@tas b/(unit @tas)}
      ?~(b a [a u.b])
    ;~(plug sym ;~(pose (stag ~ ;~(pfix cab sym)) (easy ~)))
  ::
  ++  script-or-style                                             ::  script or style
    %+  cook  |=(a/marx a)
    ;~  plug
      ;~(pose (jest %script) (jest %style))
      wide-attrs
    ==
  ::
  ++  en-class
    |=  a/(list {$class p/term})  ^-  (unit {$class tape})
    ?~  a  ~
    %-  some
    :-  %class
    |-
    %+  welp  (trip p.i.a)
    ?~  t.a  ~
    [' ' $(a t.a)]
  ::
  ++  tag-head                                             ::  tag head
    %+  cook
      |=  {a/mane b/mart c/mart}
      ^-  marx
      [a (weld b c)]
    ;~  plug
      a-mane
    ::
      %+  cook
        |=  a/(list (unit {term (list beer)}))
        ^-  (list {term (list beer)})
        :: discard nulls
        (murn a same)
      ::
      ;~  plug
        (punt ;~(plug (cold %id hax) (cook trip sym)))
        (cook en-class (star ;~(plug (cold %class dot) sym)))
        (punt ;~(plug ;~(pose (cold %href fas) (cold %src pat)) soil:vast))
        (easy ~)
      ==
    ::
      wide-attrs
    ==
  ::
  ++  tall-attrs                                             ::  tall attributes
    %-  star
    ;~  pfix  ;~(plug gap tis)
      ;~((glue gap) a-mane hopefully-quote)
    ==
  ::
  ++  tall-elem                                             ::  tall preface
    %+  cook
      |=  {a/{p/mane q/mart} b/mart c/marl}
      ^-  manx
      [[p.a (weld q.a b)] c]
    ;~(plug tag-head tall-attrs tall-tail)
  ::
  ::REVIEW is there a better way to do this?
  ++  hopefully-quote
    %+  cook  |=(a/(list beer) a)
    %+  cook  |=(a/twig ?:(?=($knit -.a) p.a [~ a]~))
    wide:vast
  ::
  ++  wide-attrs                                             ::  wide attributes
    %+  cook  |=(a/(unit mart) (fall a ~))
    %-  punt
    %+  ifix  [pel per]
    %+  more  (jest ', ')
    ;~((glue ace) a-mane hopefully-quote)
  ::
  ++  wide-tail                                             ::  wide elements
    %+  cook  |=(a/marl a)
    ;~(pose ;~(pfix col wrapped-elems) (cold ~ sem) (easy ~))
  ::
  ++  wide-elems                                             ::  wide elements
    %+  cook  |=(a/marl a)
    %+  cook  zing
    (star ;~(pfix ace wide-inner-top))
  ::
  ++  script-style-tail                                             ::  unescaped tall tail
    %+  cook  |=(a/marl a)
    %+  ifix  [gap ;~(plug gap duz)]
    %+  most  gap
    ;~  pfix  sem
      %+  cook  |=(a/tape ;/(a))
      ;~  pose
        ;~(pfix ace (star prn))
        (easy "\0a")
      ==
    ==
  ::
  ++  tall-tail                                             ::  tall tail
    ?>  in-tall-form
    %+  cook  |=(a/marl a)
    ;~  pose
      (cold ~ sem)
      ;~(pfix col wrapped-elems(in-tall-form |))
      ;~(pfix col ace (cook collapse-chars(in-tall-form |) quote-innards))
      (cook zing (ifix [gap ;~(plug gap duz)] (most gap apex)))
    ==
  ::
  ++  wide-quote                                             ::  wide quote
    %+  cook  |=(a/marl a)
    ;~  pose
      ;~(less (jest '"""') (ifix [doq doq] (cook collapse-chars quote-innards)))
      (inde (ifix [(jest '"""\0a') (jest '\0a"""')] (cook collapse-chars quote-innards(lin |))))
    ==
  ::
  ++  bracketed-elem  (ifix [kel ker] ;~(plug tag-head wide-elems))          ::  bracketed element
  ++  wide-paren-elems                                             ::  wide flow
    %+  cook  |=(a/marl a)
    %+  cook  zing
    (ifix [pel per] (more ace wide-inner-top))
  ::
  ++  wrapped-elems                                             ::  wrapped tuna
    %+  cook  |=(a/marl a)
    ;~  pose
      wide-paren-elems
      (cook |=(@t `marl`[;/((trip +<))]~) qut)
      wide-top
    ==
  ::
  ::++  wide-quote-innards  (cook collapse-chars(in-tall-form |) quote-innards)
  ++  quote-innards                                             ::  wide+tall flow
    %+  cook  |=(a/(list $@(@ $^(manx tuna))) a)
    %-  star
    ;~  pose
      ;~(pfix bas ;~(pose (mask "-+*%;\{") bas doq bix:ab))
      inline-embed
      ;~(less bas kel ?:(in-tall-form fail doq) prn)
      ?:(lin fail ;~(less (jest '\0a"""') (just '\0a')))
    ==
  ::
  ++  inline-embed
    %+  cook  |=(a/$^(manx tuna) a)
    ;~  pose
      ;~(pfix sem bracketed-elem(in-tall-form |))
      ;~(plug tuna-mode sump:vast)
      (stag %tape sump:vast)
    ==
  ::
  ++  collapse-chars                                             ::  beet to tuna
    |=  reb/(list $@(@ $^(manx tuna)))
    ^-  marl
    =|  {sim/(list @) tuz/marl}
    |-  ^-  marl
    ?~  reb
      =.  sim
        ?.  in-tall-form   sim
        [10 |-(?~(sim sim ?:(=(32 i.sim) $(sim t.sim) sim)))]
      ?~(sim tuz [;/((flop sim)) tuz])
    ?@  i.reb
      $(reb t.reb, sim [i.reb sim])
    ?~  sim  [i.reb $(reb t.reb, sim ~)]
    [;/((flop sim)) i.reb $(reb t.reb, sim ~)]
  --
--
::|=  inp/cord
::=<  (steam-marl (rash inp apex:(sail &)))
|=  pax/path
=<  (test pax)
=>  |%
    ++  item  (pair mite marl:dynamic)                  ::  xml node generator
    ++  colm  @ud                                       ::  column
    ++  flow  manx:dynamic                              ::  node or generator
    ++  mite                                            ::  context
      $?  $down                                         ::  outer embed
          $list                                         ::  unordered list
          $lime                                         ::  list item
          $lord                                         ::  ordered list
          $poem                                         ::  verse
          $bloc                                         ::  blockquote
          $code                                         ::  preformatted code
          $head                                         ::  heading
          $expr                                         ::  dynamic expression
      ==                                                ::
    ++  trig                                            ::  line style
      $:  col/@ud                                       ::  start column
          $=  sty                                       ::  style
          $?  $fini                                     ::   terminator
              $done                                     ::  end of input
              $lint                                     ::  + line item
              $lite                                     ::  - line item
              $head                                     ::  # heading
              $text                                     ::  anything else
      ==  ==                                            ::
    ++  graf                                            ::  input fragment
      $%  {$bold p/(list graf)}                         ::  *bold*
          {$talc p/(list graf)}                         ::  _italics_
          {$quod p/(list graf)}                         ::  "double quote"
          {$code p/tape}                                ::  code literal
          {$text p/tape}                                ::  text symbol
          {$link p/(list graf) q/tape}                  ::  URL
          {$expr p/=<($^(tuna manx) dynamic)}
      ==
    --
|%                                                      ::
++  test                                                ::  test text parsing
  |=  pax/path
  ^-  tape
  ::  src: text file as (list cord)
  ::  txt: source as tape with newlines
  ::  vex: parsing result
  ::
  =/  src  .^(wain %cx pax)
  =*  txt  (zing (turn src |=(@t (weld (rip 3 +<) `tape`~[`@`10]))))
  =/  vex  (cram [1 1] txt)
  ::  print result as error or xml text
  ::
  ?~  q.vex
    "syntax error: line {(scow %ud p.p.vex)}, column {(scow %ud q.p.vex)}"
  ?:  [freeze=|]  (poxo (freeze p.u.q.vex))
  (poxo ;;(manx q:(slap !>(..zuse) (steam p.u.q.vex))))
::                                                      ::
++  cram                                                ::  parse unmark
  |=  {naz/hair los/tape}
  ^-  (like flow)
  ::
  ::  state of the parsing loop.  we maintain a construction
  ::  stack for elements and a line stack for lines in the
  ::  current block.  a blank line causes the current block
  ::  to be parsed and thrown in the current element.  when
  ::  the indent column retreats, the element stack rolls up.
  ::
  ::  err: error position
  ::  col: current control column
  ::  hac: stack of items under construction
  ::  cur: current item under construction
  ::  lub: current block being read in
  ::
  =|  err/(unit hair)
  =/  col  q.naz
  =|  hac/(list item)
  =/  cur/item  [%down ~]
  =|  lub/(unit (pair hair (list tape)))
  =<  $:line
  |%
  ::                                                    ::
  ++  $                                                 ::  resolve
    ^-  (like flow)
    ::  if error position is set, produce error
    ::
    ?.  =(~ err)  [+.err ~]
    ::  all data was consumed
    ::
    =-  [naz `[- [naz los]]]
    |-  ^-  flow
    ::  fold all the way to top
    ::
    ?~  hac  fine
    $(..^$ fold)
  ::                                                    ::
  ++  back                                              ::  column retreat
    |=  luc/@ud
    ^+  +>
    ?:  =(luc col)  +>
    ::  nex: next backward step that terminates this context
    ::
    =/  nex/@ud
      ?-  p.cur
        $down  2
        $head  0
        $expr  2
        $list  0
        $lime  2
        $lord  0
        $poem  8
        $code  4
        $bloc  6
      ==
    ?:  (gth nex (sub col luc))
      ::  indenting pattern violation
      ::
      ..^$(col luc, err `[p.naz luc])
    =.  ..^$  fold
    $(col (sub col nex))
  ::                                                    ::
  ++  fine                                              ::  item to flow
    ^-  flow
    ?:  ?=(?($head $expr) p.cur) ::XX deal with ;= expr?
      ?>  ?=({* $~} q.cur)
      ?@  -.i.q.cur  !!  ::REVIEW over-strict?
      i.q.cur
    =-  [[- ~] (flop q.cur)]
    ?-  p.cur
      $down  %div
      $list  %ul
      $lord  %ol
      $lime  %li
      $bloc  %bq
      $code  %pre
      $poem  !!  ::XX what does this even mean
    ==
  ::                                                    ::
  ++  fold  ^+  .                                       ::  complete and pop
    ?~  hac  .
    %=  .
      hac  t.hac
      cur  [p.i.hac [fine q.i.hac]]
    ==
  ::                                                    ::
  ++  snap                                              ::  capture raw line
    =|  nap/tape
    |-  ^+  [nap +>]
    ::  no unterminated lines
    ::
    ?~  los  [~ +>(err `naz)]
    ?:  =(`@`10 i.los)
      ::  consume newline
      ::
      :_  +>(los t.los, naz [+(p.naz) 1])
      ::  trim trailing spaces
      ::
      |-  ^-  tape
      ?:  ?=({$' ' *} nap)
        $(nap t.nap)
      (flop nap)
    ::  save byte and repeat
    ::
    $(los t.los, q.naz +(q.naz), nap [i.los nap])
  ::                                                    ::
  ++  skip  +:snap                                      ::  discard line
  ++  look                                              ::  inspect line
    ^-  (unit trig)
    ?~  los
      `[q.naz %done]
    ?:  =(`@`10 i.los)
      ~
    ?:  =(' ' i.los)
      look(los t.los, q.naz +(q.naz))
    :+  ~  q.naz
    ?:  =('\\' i.los)
      %fini
    ?:  ?&  =('#' i.los)
            |-  ^-  ?
            ?~  t.los  |
            ?:  =(' ' i.t.los)  &
            ?:  =('#' i.t.los)  $(t.los t.t.los)
            |
        ==
      %head
    ?:  ?=({$'-' $' ' *} los)
      %lite
    ?:  ?=({$'+' $' ' *} los)
      %lint
    %text
  ::                                                    ::
  ++  clue                                              ::  tape to xml
    |=  tex/tape
    ^-  manx:dynamic
    [[%$ [%$ tex] ~] ~]
  ::                                                    ::
  ++  cash                                              ::  escaped fence
    |*  tem/rule
    ;~  sfix
      %-  star
      =+  ;~(pose bas tem)
      ;~  pose
        (cold ' ' whit)
        ;~(pose ;~(less - prn) ;~(pfix bas -))
      ==
    ::
      tem
    ==
  ::                                                    ::
  ++  cool                                              ::  reparse
    |*  $:  ::  fex: primary parser
            ::  sab: secondary parser
            ::
            fex/rule
            sab/rule
        ==
    |=  {naz/hair los/tape}
    ^+  *sab
    ::
    ::  vex: fenced span
    ::
    =/  vex/(like tape)  (fex naz los)
    ?~  q.vex  vex
    ::
    ::  hav: reparse full fenced text
    ::
    =/  hav  ((full sab) [naz p.u.q.vex])
    ::
    ::  reparsed error position is always at start
    ::
    ?~  q.hav  [naz ~]
    ::
    ::  the complete span with the main product
    ::
    :-  p.vex
    `[p.u.q.hav q.u.q.vex]
  ::                                                    ::
  ++  echo                                              ::  hoon literal
    |*  sab/rule
    |=  {naz/hair los/tape}
    ^-  (like tape)
    ::  vex: result of parsing wide twig
    ::
    =/  vex  (sab naz los)
    ::  use result of expression parser
    ::
    ?~  q.vex  vex
    =-  [p.vex `[- q.u.q.vex]]
    ::  but replace payload with bytes consumed
    ::
    |-  ^-  tape
    ?:  =(q.q.u.q.vex los)  ~
    ?~  los  ~
    [i.los $(los +.los)]
  ::                                                    ::
  ++  word                                              ::  flow parser
    %+  knee  *graf  |.  ~+
    ;~  pose
    ::
    ::  whitespace
    ::
      (stag %text (cold " " whit))
    ::
    ::  ordinary word
    ::
      (stag %text ;~(plug ;~(pose low hig) (star ;~(pose nud low hig hep))))
    ::
    ::  naked \escape
    ::
      (stag %text ;~(pfix bas (cook trip ;~(less ace prn))))
    ::
    ::  *bold literal*
    ::
      (stag %bold ;~(pfix tar (cool (cash tar) work)))
    ::
    ::  _italic literal_
    ::
      (stag %talc ;~(pfix cab (cool (cash cab) work)))
    ::
    ::  "quoted text"
    ::
      (stag %quod ;~(pfix doq (cool (cash doq) work)))
    ::
    ::  `classic markdown quote`
    ::
      (stag %code ;~(pfix tec (cash tec)))
    ::
    ::  #twig
    ::
      (stag %code ;~(pfix hax (echo wide:vast)))
    ::
    ::  ++arm
    ::
      (stag %code ;~(plug lus lus low (star ;~(pose nud low hep))))
    ::
    ::  [arbitrary *content*](url)
    ::
      %+  stag  %link
      ;~  plug
        ;~(pfix sel (cool (cash ser) work))
        ;~(pfix gay ;~(pfix pel (cash per)))
      ==
    ::
    ::  direct hoon constant
    ::
      %+  stag  %code
      %-  echo
      ;~  pose
        bisk:so
        tash:so
        ;~(pfix dot perd:so)
        ;~(pfix sig ;~(pose twid:so (easy [%$ %n 0])))
        ;~(pfix cen ;~(pose sym buc pam bar qut nuck:so))
      ==
    ::
    ::  {interpolated} sail
    ::
      (stag %expr inline-embed:(sail |))
    ::
    ::  just a byte
    ::
      (stag %text (cook trip ;~(less ace prn)))
    ==
  ::                                                    ::
  ++  work  (star word)                                 ::  indefinite flow
  ::                                                    ::
  ++  down                                              ::  parse inline flow
    %+  knee  *marl:dynamic  |.  ~+
    =-  (cook - work)
    ::  collect raw flow into xml tags
    ::
    |=  gaf/(list graf)
    ^-  marl:dynamic
    ::  nap: collected words
    ::  max: collected tags
    ::
    =<  main
    |%
    ++  main
      ^-  marl:dynamic
      ?~  gaf  ~
      ?.  ?=($text -.i.gaf)
        (weld (item i.gaf) $(gaf t.gaf))
      ::
      ::  fip: accumulate text blocks
      =/  fip/(list tape)  [p.i.gaf]~
      |-  ^-  marl:dynamic
      ?~  t.gaf  [;/((zing (flop fip))) ~]
      ?.  ?=($text -.i.t.gaf)
        [;/((zing (flop fip))) ^$(gaf t.gaf)]
      $(gaf t.gaf, fip :_(fip p.i.t.gaf))
    ::
    ++  item
      |=  nex/graf
      ^-  marl:dynamic
      ?-  -.nex
        $text  !!  :: handled separately
        $expr  [p.nex]~
        $bold  [[%b ~] ^$(gaf p.nex)]~
        $talc  [[%i ~] ^$(gaf p.nex)]~
        $code  [[%code ~] ;/(p.nex) ~]~
        $quod  ::  smart quotes
               ::
               %=    ^$
                   gaf
                 :-  [%text (tufa ~-~201c. ~)]
                 %+  weld  p.nex
                 `(list graf)`[%text (tufa ~-~201d. ~)]~
               ==
        $link  [[%a [%href q.nex] ~] ^$(gaf p.nex)]~
      ==
    --
  ::                                                    ::
  ++  para                                              ::  paragraph
    %+  cook
      |=(marl:dynamic [[%p ~] +<]~)
    ;~(pfix gay down)  ::REVIEW does this mean comments work?
  ::                                                    ::
  ++  expr                                              ::  expression
    ;~(pfix gay apex:(sail &))
  ::                                                    ::
  ++  whit                                              ::  whitespace
    (cold ' ' (plus ;~(pose (just ' ') (just `@`10))))
  ::
  ++  head                                              ::  parse heading
    %+  cook
      |=  a/manx:dynamic  ^-  marl:dynamic
      =.  a.g.a  :_(a.g.a [%id (sanitize-to-id c.a)])
      [a]~
    ::
    ;~  plug
      ::
      :: # -> 1 -> %h1, ### -> 3 -> %h3, etc
      :(cook |=(a/@u /(crip "h{<a>}")) lent (stun [1 6] hax))
    ::
      ;~(pfix whit down)
    ==
  ::                                                    ::
  ++  sanitize-to-id
    |=  a/(list $^(tuna manx)):dynamic  ^-  tape
    =;  raw/tape
      %+  turn  raw
      |=  @tD
      ^-  @tD
      ?:  ?|  &((gte +< 'a') (lte +< 'z'))
              &((gte +< '0') (lte +< '9'))
          ==
        +<
      ?:  &((gte +< 'A') (lte +< 'Z'))
        (add 32 +<)
      '-'
    ::  collect all text in header flow
    ::
    |-  ^-  tape
    ?~  a  ~
    %+  weld
      ^-  tape
      ?-    i.a
        {{$$ {$$ *} $~} $~}  ::  text node contents
          (murn v.i.a.g.i.a |=(a/beer ?^(a ~ (some a))))
        {^ *}  $(a c.i.a)    ::  concatenate children
        {@ *}  ~             ::  ignore interpolation
      ==
    $(a t.a)
  ::                                                    ::
  ++  made                                              ::  compose block
    ^+  .
    ::  empty block, no action
    ::
    ?~  lub  .
    ::  if block is preformatted code
    ::
    ?:  ?=($code p.cur)
      ::  add blank line between blocks
      ::
      =.  q.cur
        ?~  q.cur  q.cur
        :_(q.cur ;/("\0a"))
      %=    .
          q.cur
        %+  weld
          %+  turn
            q.u.lub
          |=  tape  ^-  flow
          ::  each line is text data with its newline
          ::
          ;/((weld (slag (dec col) +<) "\0a"))
        q.cur
      ==
    ::  if block is verse
    ::
    ?:  ?=($poem p.cur)
      ::  add break between stanzas
      ::
      =.  q.cur  ?~(q.cur q.cur [[[%br ~] ~] q.cur])
      %=    .
          q.cur
        %+  weld
          %+  turn
            q.u.lub
          |=  tape  ^-  flow
          ::  each line is a paragraph
          ::
          :-  [%p ~]
          :_  ~
          ;/((weld (slag (dec col) +<) "\0a"))
        q.cur
      ==
    ::  yex: block recomposed, with newlines
    ::
    =/  yex/tape
      =/  hel  (flop q.u.lub)
      |-  ^-  tape
      ?~  hel  ~
      ?~  t.hel  i.hel
      (weld i.hel `tape`[`@`10 $(hel t.hel)])
    ::  vex: parse of paragraph
    ::
    =/  vex/(like marl:dynamic)
      ::  either a one-line header or a paragraph
      ::
      %.  [p.u.lub yex]
      ?:  ?=($expr p.cur)  expr
      ?:  ?=($head p.cur)  head
      para
    ::  if error, propagate correctly
    ::
    ?~  q.vex  ..$(err `p.vex)
    ::  finish tag if it's a header
    ::
    =<  ?:(=(%head p.cur) fold ..$)
    ::  save good result, clear buffer
    ::
    ..$(lub ~, q.cur (weld p.u.q.vex q.cur))
  ::                                                    ::
  ++  line  ^+  .                                       ::  body line loop
    ::  abort after first error
    ::
    ?:  !=(~ err)  .
    ::  pic: profile of this line
    ::
    =/  pic  look
    ::  if line is blank
    ::
    ?~  pic
      ::  break section
      ::
      line:made:skip
    ::  line is not blank
    ::
    =>  .(pic u.pic)
    ::  if end of input, complete
    ::
    ?:  ?=($done sty.pic)
      ..$(q.naz col.pic)
    ::  if end marker behind current column
    ::
    ?:  &(?=($fini sty.pic) (lth col.pic col))
      ::  retract and complete
      ::
      (back(q.naz (add 2 col.pic)) col.pic)
    ::  bal: inspection copy of lub, current section
    ::
    =/  bal  lub
    ::  if within section
    ::
    ?^  bal
      ::  detect bad block structure
      ::
      ?:  ?|  ::  only one line in a heading
              ::
              =(%head p.cur)
              ?:  ?=(?($code $poem $expr) p.cur)
                ::  literals need to end with a blank line
                ::
                (lth col.pic col)
              ::  text flows must continue aligned
              ::
              |(!=(%text sty.pic) !=(col.pic col))
          ==
        ..$(err `[p.naz col.pic])
      ::  accept line and continue
      ::
      =^  nap  ..$  snap
      line(lub bal(q.u [nap q.u.bal]))
    ::  if column has retreated, adjust stack
    ::
    =.  ..$  ?.  (lth col.pic col)  ..$  (back col.pic)
    ::  dif: columns advanced
    ::  erp: error position
    ::
    =/  dif  (sub col.pic col)
    =/  erp  [p.naz col.pic]
    =.  col  col.pic
    ::  nap: take first line
    ::
    =^  nap  ..$  snap
    ::  execute appropriate paragraph form
    ::
    =<  line:abet:apex
    |%
    ::                                                  ::
    ++  abet                                            ::  accept line
      ..$(lub `[naz nap ~])
    ::                                                  ::
    ++  apex  ^+  .                                     ::  by column offset
      ?+  dif  fail
        $0  apse
        $2  expr
        $4  code
        $6  bloc
        $8  poem
      ==
    ::                                                  ::
    ++  apse  ^+  .                                     ::  by prefix style
      ?-  sty.pic
        $fini  !!
        $head  head
        $lite  lite
        $lint  lint
        $text  text
      ==
    ::                                                  ::
    ++  bloc  apse:(push %bloc)                         ::  blockquote line
    ++  fail  .(err `erp)                               ::  set error position
    ++  push  |=(mite %_(+> hac [cur hac], cur [+< ~])) ::  push context
    ++  expr  (push %expr)                              ::  hoon expression
    ++  code  (push %code)                              ::  code literal
    ++  poem  (push %poem)                              ::  verse literal
    ++  head  (push %head)                              ::  heading
    ++  lent                                            ::  list entry
      |=  ord/?
      ^+  +>
      ::  erase list marker
      ::
      =.  nap  =+(+(col) (runt [- ' '] (slag - nap)))
      ::  indent by 2
      ::
      =.  col  (add 2 col)
      ::  can't switch list types
      ::
      ?:  =(?:(ord %list %lord) p.cur)  fail
      ::  push list item
      ::
      %.  %lime
      =<  push
      ::  push list context, unless we're in list
      ::
      =+  ?:(ord %lord %list)
      ?:  =(- p.cur)  ..push  (push -)
    ::
    ++  lint  (lent &)                                  ::  numbered list
    ++  lite  (lent |)                                  ::  unnumbered list
    ++  text                                            ::  plain text
      ^+  .
      ::  only in lists, fold
      ::
      ?.  ?=(?($list $lord) p.cur)  .
      .($ fold)
    --
  --
--
