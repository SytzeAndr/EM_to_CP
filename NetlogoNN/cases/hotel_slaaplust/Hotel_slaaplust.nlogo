globals [
  new_guest_amount
  profits

  t1_failed
  t1_success

  t2_failed
  t2_success

  t3_failed
  t3_success

  incoming_reservations_now
  failing_reservations_now

  no_shows_processed
  no_shows_times

  unhappy_guests_out
  happy_guests_out

  s1_length
  s2_length

  t1_loss
  t2_loss
  t3_loss
  unsatisfied_rate

  mean_no_show_times
  var_no_show_times
]

breed [receptionists receptionist]
breed [customers customer]
breed [guests guest]

receptionists-own [
  time-until-invoice-made
  in-conversation
  costumer_making_invoice_for
]

customers-own [
  in-conversation
  time-until-end-conversation
  time-until-checkin
  communicating_receptionist
  has-reservation
  no_show
  needs-to-pay

  ; theoratically, fine-is-being-prepared shouldn't be here since it relates to beliefs owned by the receptionist
  ; however, it is stored per costumer for computational reasons
  fine-is-being-prepared

  in_que
  in_que_duration
]

guests-own [
  communicating_receptionist
  time-until-end-stay
  length_of_my_stay
  time-until-end-conversation
  in-conversation

  wants_to_checkin
  wants_to_checkout
  needs-to-pay

  satisfied
  in_que
  in_que_duration
]


to go
  tick

  process-ticks
  process_que

  process-incoming-reservations
  process-incoming-checkins
  process-incoming-checkouts
  process-no-shows

  process_metrics
end

to process-ticks
  ;; conversational ticks ;;
  ; decrement conversational ticks
  ask guests with [in-conversation and time-until-end-conversation > 0] [
    set time-until-end-conversation time-until-end-conversation - 1
  ]

  ask customers with [in-conversation and time-until-end-conversation > 0] [
    set time-until-end-conversation time-until-end-conversation - 1
  ]

  ;; process related ticks ;;
  ; decrement time-until-checkin
  ask customers with [has-reservation] [
    set time-until-checkin time-until-checkin - 1
  ]

  ; time until end stay
  ask guests with [time-until-end-stay > 0] [
    set time-until-end-stay time-until-end-stay - 1
  ]

  ; decrement time-until-invoice-made
  ; only decrement if the receptionist is not currently in conversation, as conversational tasks have priority
  ask receptionists with [costumer_making_invoice_for != false and not in-conversation] [
    set time-until-invoice-made time-until-invoice-made - 1
  ]

  ;; que ticks ;;
  ; process ticks corresponding to costumers and guests waiting due to lack of available receptionist
  ask customers with [in_que] [
    set in_que_duration in_que_duration + 1
  ]

  ; process ticks corresponding to costumers and guests waiting due to lack of available receptionist
  ask guests with [in_que] [
    set in_que_duration in_que_duration + 1
  ]
end

to process_metrics
  let idle_receptionists receptionists with [not in-conversation]
  ifelse any? idle_receptionists [
    set s1_length s1_length + 1
  ][
    set s2_length s2_length + 1
  ]

  if (t1_success + t1_failed) != 0 [
    set t1_loss (t1_failed / (t1_success + t1_failed))
  ]

  if (t2_success + t2_failed) != 0 [
    set t2_loss (t2_failed / (t2_success + t2_failed))
  ]

  if (t3_success + t3_failed) != 0 [
    set t3_loss (t3_failed / (t3_success + t3_failed))
  ]

  if (happy_guests_out + unhappy_guests_out) != 0 [
    set unsatisfied_rate (unhappy_guests_out / (happy_guests_out + unhappy_guests_out))
  ]
  if not empty? no_shows_times [
    set mean_no_show_times mean no_shows_times
    if (length no_shows_times >= 2) [
      set var_no_show_times variance no_shows_times
    ]
  ]

end

to enter_que
  set in_que true
  set in_que_duration 0
end

to exit_que
  set in_que false
end

to process_que
  set failing_reservations_now 0

  ; customers that stay too long in the que leave.
  ; they don't count as "unhappy" guests.
  ask customers with [in_que_duration >= reservation_max_quetime] [
    set t1_failed t1_failed + 1
    set failing_reservations_now failing_reservations_now + 1
    die
  ]

  ; guests become unhappy if they are too long in a que
  ask guests with [satisfied and in_que_duration >= satisfied_max_quetime] [
    set satisfied false
    set shape "face sad"
  ]

  ; guests leave when they wait too long for checkin
  ask guests with [in_que_duration >= checkin_max_quetime and wants_to_checkin] [
    set satisfied false
    set t3_failed t3_failed + 1
    kill_guest
  ]

  ; no shows for which we waited too long with making a call
  ask customers with [time-until-checkin * -1 >= noshow_max_time and not in-conversation] [
    set t2_failed t2_failed + 1
    ; todo: process corresponding receptionist
    ask receptionists with [costumer_making_invoice_for = myself] [
      set costumer_making_invoice_for false
    ]

    die
  ]

end

to kill_guest
  ; kill the turtle and some metric related stuff
  ifelse satisfied [
    set happy_guests_out happy_guests_out + 1
  ][
    set unhappy_guests_out unhappy_guests_out + 1
  ]
  die
end

to-report spread_scale
  ; linear scaling, s.t. E[A] = E[A*spread_scale]
  let ticks_horizon_scaled ((ticks mod spread_horizon) / spread_horizon)
  let ub (1 / spread_factor)
  let lb spread_factor

  if ticks_horizon_scaled <= 0.25 [
    report lb + ticks_horizon_scaled * 4 * (1 - lb)
  ]
  if ticks_horizon_scaled <= 0.5 [
    report 1 + (ticks_horizon_scaled - 0.25) * 4 * (ub - 1)
  ]
  if ticks_horizon_scaled <= 0.75 [
    report ub - (ticks_horizon_scaled - 0.5) * 4 * (ub - 1)
  ]
  ; else, ticks_horizon_scaled is between 0.75 and 1
  report 1 - (ticks_horizon_scaled - 0.75) * 4 * (1 - lb)
end

;to-report spread_scale_gaussian
;  ; 0 <= ticks_horizon_scaled <= 1
;  let ticks_horizon_scaled ((ticks mod spread_horizon) / spread_horizon)
;  ; variance = spread_variance
;
;  ; model pdf function
;  let pdf_out (1 / sqrt(2 * pi * spread_variance)) * exp(- ((ticks_horizon_scaled - 0.5) ^ 2 / (2 * spread_variance)))
;
;  report pdf_out
;  ; peak is at t=0.5
;  ; todo
;
;end

;to-report get_sin_scale
;  if sin_scale [
;    ; reports the first half of the sin over sin_scale_horizon. scaled between 0.0 and 2.0
;    ; todo: make sure that it averages to 1
;    let sin_scale_out (sin (((ticks mod sin_scale_horizon) * 180) / sin_scale_horizon) * 2) ^ sin_scale_factor
;    report sin_scale_out
;  ]
;  report 1.0
;end

to process-incoming-reservations
  ; generate customers that make a call based on a poisson distribution
  let reservation_in_count random-poisson (p_incoming_t1 * spread_scale)

  set incoming_reservations_now reservation_in_count

  create-customers reservation_in_count [
    set shape "triangle"
    set size 2
    set color red
    move_to_waiting_que
    set in-conversation false
    set has-reservation false
    set time-until-end-conversation -1
    set no_show false
    set needs-to-pay false
    set fine-is-being-prepared false
    set in_que_duration 0
    set in_que false
  ]

  ; assing unhandled customers with an available receptionist
  ask customers with [not in-conversation and not has-reservation] [
    if not in_que [enter_que]

    find_and_set_available_receptionist
    if communicating_receptionist != false [
      exit_que
      toggle_conversation
      set time-until-end-conversation t1_duration
    ]
  ]

  ; process reservation conversations that end
  ask customers with [time-until-end-conversation <= 0 and in-conversation and not has-reservation] [
    toggle_conversation
    set time-until-checkin time_between_t1_and_t3
    set has-reservation true
    set t1_success t1_success + 1

    set color green
  ]

end


to process-incoming-checkins
  set new_guest_amount 0

  ; the costumer either shows up and becomes a guest or becomes a no-show
  ask customers with [has-reservation and time-until-checkin <= 0 and not in-conversation and not no_show] [
    ifelse random-float 1.0 <= p_showup [
      set new_guest_amount new_guest_amount + 1
      die
    ][
      set no_show true
      set color blue
    ]
  ]

  ; guest can also come in without a reservation
  set new_guest_amount new_guest_amount + random-poisson (p_incoming_t3 * spread_scale)

  ; create new guests
  create-guests new_guest_amount [
    set shape "face happy"
    set size 2
    set color red
    set communicating_receptionist false
    set time-until-end-conversation -1
    set in-conversation false
    set wants_to_checkin true
    set wants_to_checkout false
    set needs-to-pay false
    set in_que false
    set satisfied true
    move_to_waiting_que
  ]

  ; process incoming guests that do not have a room yet
  ask guests with [not in-conversation and wants_to_checkin] [
    if not in_que [enter_que]
    find_and_set_available_receptionist
    if communicating_receptionist != false [
      ; exit que and enter conversation
      exit_que
      toggle_conversation
      set time-until-end-conversation t3_duration
    ]
  ]

  ; process guests that end their check-in conversation
  ask guests with [in-conversation and wants_to_checkin and time-until-end-conversation <= 0] [
    ; they get a room assigned and exit conversation
    set wants_to_checkin false
    set color green
    set length_of_my_stay random stay_duration
    set time-until-end-stay length_of_my_stay

    set t3_success t3_success + 1

    toggle_conversation
  ]

end

to process-incoming-checkouts
  ask guests with [time-until-end-stay <= 0 and not wants_to_checkout] [
    set wants_to_checkout true
  ]

  ask guests with [wants_to_checkout and not in-conversation] [
    ; find a receptionist to start check out procedure
    if not in_que [enter_que]

    find_and_set_available_receptionist
    if communicating_receptionist != false [
      ; start conversation and exit que
      exit_que
      toggle_conversation
      ; the checkout conversation includes both t4 and t5
      set time-until-end-conversation (t4_duration + t5_duration)
    ]
  ]

  ask guests with [wants_to_checkout and time-until-end-conversation <= 0 and in-conversation] [
    ; exit conversation
    set wants_to_checkout false
    toggle_conversation
    ; adjust profits
    set profits profits + room_price * length_of_my_stay
    ; guest leaves hotel
    kill_guest
  ]
end

to process-no-shows
  ; process any costumers that did not show up

  ; initiation of t6
  ; since t6 is the only process that does not require a conversation, we can search for any receptionist not in a conversation not currently making an invoice
  ask receptionists with [not in-conversation and costumer_making_invoice_for = false] [
    let no_show_customers customers with [no_show and not fine-is-being-prepared and not needs-to-pay]
    if any? no_show_customers [
      ; pick no show that is there for the longest
      ; time-until-checkin is negative so we do min-one-of
      set costumer_making_invoice_for min-one-of no_show_customers [time-until-checkin]
      set time-until-invoice-made t6_duration
      ask costumer_making_invoice_for [
        set fine-is-being-prepared true
        set color cyan
      ]
    ]
  ]

  ; t2 (sending invoice) starts when t6 (creating invoice) has finished
  ask receptionists with [not in-conversation and costumer_making_invoice_for != false and time-until-invoice-made <= 0] [
    ask costumer_making_invoice_for [
      ; start conversation
      set communicating_receptionist myself
      toggle_conversation
      set time-until-end-conversation t2_duration
      ; from preparing fine to stating that the costumer needs to pay
      ; clear costumer_making_invoice_for of receptionist
      ask communicating_receptionist [set costumer_making_invoice_for false]
      set fine-is-being-prepared false
      set needs-to-pay true
    ]
  ]

  ; finalize t2
  ask customers with [needs-to-pay and time-until-end-conversation <= 0 and in-conversation] [

    toggle_conversation
    set profits profits + no_show_fine
    set no_shows_processed no_shows_processed + 1
    set no_shows_times fput (time-until-checkin * -1) no_shows_times

    set t2_success t2_success + 1

    ; todo: for now we don't care whether a customer is happy or not when it is a no-show. Does this make sense?
    die
  ]
end

to find_and_set_available_receptionist
  set communicating_receptionist find_available_receptionist
end

to-report find_available_receptionist
  let available-receptionists receptionists with [not in-conversation]
  if any? available-receptionists [
    report one-of available-receptionists
  ]
  report false
end

to toggle_conversation
  let begins_conversation not in-conversation

  ; requires communicating_receptionist to be set
  ask communicating_receptionist [
    set in-conversation begins_conversation
  ]
  set in-conversation begins_conversation

  ifelse begins_conversation [
    move-to communicating_receptionist
  ][
    set communicating_receptionist false
    move_to_waiting_que
  ]
end

to move_to_waiting_que
  move-to one-of patches with [pxcor <= -5 and pycor >= -10 and pycor <= 10]
end

to setup-parameters
  ; global variable used in process-incoming-checkins
  set new_guest_amount 0
  set profits 0

  set t1_failed 0
  set t1_success 0

  set t2_failed 0
  set t2_success 0

  set t3_failed 0
  set t3_success 0

  set unhappy_guests_out 0
  set happy_guests_out 0
  set no_shows_processed 0
  set no_shows_times []

  set s1_length 0
  set s2_length 0

  set incoming_reservations_now 0
  set t1_loss 0
  set t1_loss 0
  set t3_loss 0
  set unsatisfied_rate 0

  set mean_no_show_times 0
  set var_no_show_times 0

end

to setup
  clear-all
  setup-parameters

  create-receptionists receptionists_amount [
    set shape "person"
    set color blue
    set size 3
    set in-conversation false
    move-to one-of patches with [pxcor >= 5 and pycor >= -10 and pycor <= 10]
    set time-until-invoice-made 0
    set costumer_making_invoice_for false
  ]

  reset-ticks
end
@#$#@#$#@
GRAPHICS-WINDOW
7
10
448
452
-1
-1
13.121212121212123
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
457
11
520
44
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
533
11
596
44
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

MONITOR
456
62
541
107
NIL
profits / ticks
17
1
11

SLIDER
453
232
625
265
receptionists_amount
receptionists_amount
0
500
230.0
1
1
NIL
HORIZONTAL

SLIDER
13
488
185
521
t1_duration
t1_duration
0
100
68.0
1
1
NIL
HORIZONTAL

SLIDER
13
528
185
561
t2_duration
t2_duration
0
100
66.0
1
1
NIL
HORIZONTAL

SLIDER
12
570
184
603
t3_duration
t3_duration
0
100
70.0
1
1
NIL
HORIZONTAL

SLIDER
191
488
363
521
t4_duration
t4_duration
0
100
55.0
1
1
NIL
HORIZONTAL

SLIDER
192
528
364
561
t5_duration
t5_duration
0
100
42.0
1
1
NIL
HORIZONTAL

SLIDER
192
570
364
603
t6_duration
t6_duration
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
454
320
628
353
p_incoming_t1
p_incoming_t1
0
100
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
456
399
628
432
p_showup
p_showup
0
1
0.8
0.01
1
NIL
HORIZONTAL

SLIDER
412
530
626
563
stay_duration
stay_duration
0
1000
100.0
1
1
NIL
HORIZONTAL

SLIDER
412
568
623
601
time_between_t1_and_t3
time_between_t1_and_t3
0
1000
100.0
1
1
NIL
HORIZONTAL

SLIDER
651
530
823
563
room_price
room_price
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
651
569
823
602
no_show_fine
no_show_fine
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
456
358
629
391
p_incoming_t3
p_incoming_t3
0
6
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
653
403
826
436
reservation_max_quetime
reservation_max_quetime
0
100
10.0
1
1
NIL
HORIZONTAL

MONITOR
713
13
851
58
t1_loss
t1_loss
17
1
11

SLIDER
653
363
825
396
checkin_max_quetime
checkin_max_quetime
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
652
322
825
355
satisfied_max_quetime
satisfied_max_quetime
0
100
5.0
1
1
NIL
HORIZONTAL

MONITOR
558
54
700
99
NIL
mean_no_show_times
17
1
11

MONITOR
558
107
701
152
NIL
var_no_show_times
17
1
11

MONITOR
559
161
701
206
idle vs non-idle
s1_length / s2_length
17
1
11

SLIDER
842
361
1016
394
spread_horizon
spread_horizon
0
3600
2000.0
1
1
NIL
HORIZONTAL

SLIDER
842
319
1014
352
spread_factor
spread_factor
0.01
1.0
0.8
0.01
1
NIL
HORIZONTAL

MONITOR
459
114
545
159
NIL
spread_scale
17
1
11

PLOT
867
49
1155
204
incoming reservations
ticks
value
0.0
1000.0
0.0
10.0
true
true
"" ""
PENS
"reservations in" 1.0 0 -16777216 true "" "plot incoming_reservations_now"
"reservations fail" 1.0 0 -2674135 true "" "plot failing_reservations_now"

MONITOR
713
107
850
152
NIL
t3_loss
17
1
11

MONITOR
713
160
851
205
NIL
unsatisfied_rate
17
1
11

TEXTBOX
457
298
607
316
reservations in
11
0.0
1

TEXTBOX
653
289
803
317
max que time before negative result
11
0.0
1

TEXTBOX
845
284
995
312
spreadness of incoming t1 and t3
11
0.0
1

TEXTBOX
654
509
827
531
pricing of rooms and fines
11
0.0
1

TEXTBOX
416
508
566
526
lengths between transactions
11
0.0
1

TEXTBOX
15
469
230
497
durations of transactions (non-random)
11
0.0
1

TEXTBOX
453
207
603
225
receptionist capacity
11
0.0
1

SLIDER
654
443
826
476
noshow_max_time
noshow_max_time
0
10000
1000.0
1
1
NIL
HORIZONTAL

MONITOR
714
62
851
107
NIL
t2_loss
17
1
11

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
