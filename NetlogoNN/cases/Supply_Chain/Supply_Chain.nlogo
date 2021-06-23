extensions [
  matrix
  table]

globals [
  safety_values
  watching
  promotion
  stocks_h
  costs_h
  ret_list

  ; stock level
  stock_customer_MA
  stock_retailer_MA
  stock_distributor_MA
  stock_factory_MA
  stock_customer_MA_mean
  stock_retailer_MA_mean
  stock_distributor_MA_mean
  stock_factory_MA_mean

  stock_customer_MA_mean_relative
  stock_retailer_MA_mean_relative
  stock_distributor_MA_mean_relative
  stock_factory_MA_mean_relative

  ; lost and daily sales total
  lost_sales_ret
  lost_sales_dis
  lost_sales_fac

  daily_sales_ret
  daily_sales_dis
  daily_sales_fac

  ; daily lost ratio
  lost_ratio_sales_ret
  lost_ratio_sales_dis
  lost_ratio_sales_fac
]

breed [factories factory]
breed [distributors distributor]
breed [retailers retailer]
breed [customers customer]

turtles-own [demand stock strategy]

Factories-own [
  production_rate
  reorder_point
  orders
  available_stock
  clients
  daily_sales
  sales
  lost_sales
  forecast
  holding_cost
  order_cost
  total_cost
]

distributors-own [
  EOQ
  next_review
  reorder_point
  orders
  available_stock
  suppliers
  supplier_score
  supplier0
  clients
  daily_sales
  sales
  lost_sales
  forecast
  placed_orders
  holding_cost
  order_cost
  total_cost
]

retailers-own [
  EOQ
  next_review
  reorder_point
  suppliers
  supplier_score
  supplier0
  clients
  daily_sales
  sales
  lost_sales
  forecast
  placed_orders
  holding_cost
  order_cost
  total_cost
]

customers-own [
  next_review
  daily
  suppliers
  supplier_score
  supplier0
]

to setup
  ;; (for this model to work with NetLogo's new plotting features,
  ;; __clear-all-and-reset-ticks should be replaced with clear-all at
  ;; the beginning of your setup procedure and reset-ticks at the end
  ;; of the procedure.)
  __clear-all-and-reset-ticks
  ask patches [set pcolor white]
  set promotion [0 0 0]          ;Retailer 1, Impact 2, Until 3
  set stocks_h [] ;Customer, Retailer, Distributor, Factory
  set costs_h []  ;Retailer, Distributor, Factory
  set safety_values table:make
  table:put safety_values 0.50 0
  table:put safety_values 0.55 0.125661347
  table:put safety_values 0.60 0.253347103
  table:put safety_values 0.65 0.385320466
  table:put safety_values 0.70 0.524400513
  table:put safety_values 0.75 0.67448975
  table:put safety_values 0.80 0.841621234
  table:put safety_values 0.85 1.036433389
  table:put safety_values 0.90 1.281551566
  table:put safety_values 0.95 1.644853627

  set stock_customer_MA []
  set stock_retailer_MA []
  set stock_distributor_MA []
  set stock_factory_MA []

  ; lost and daily sales total
  set lost_sales_ret 0
  set lost_sales_dis 0
  set lost_sales_fac 0

  set daily_sales_ret 0
  set daily_sales_dis 0
  set daily_sales_fac 0

  ; daily lost ratio
  set lost_ratio_sales_ret 0
  set lost_ratio_sales_dis 0
  set lost_ratio_sales_fac 0


  set stock_customer_MA_mean_relative 0.25
  set stock_retailer_MA_mean_relative 0.25
  set stock_distributor_MA_mean_relative 0.25
  set stock_factory_MA_mean_relative 0.25

  create-Factories Fact [
   set size 6
   set color red
   set label (word "Factory " [who] of self "     ")
   set orders []
   let s read-from-string first(Inventory_Policy)
   ifelse s = 4
   [set strategy (random 3) + 1]
   [set strategy s]
  ]

  create-distributors Distr1 [
   set size 5
   set color blue
   set suppliers []
   set supplier_score []
   set orders []
   set placed_orders []
   set label (word "Distr." [who] of self "     ")
   let s read-from-string first(Inventory_Policy)
   ifelse s = 4
   [set strategy (random 3) + 1]
   [set strategy s]
  ]

  create-retailers Distr2 [
   set size 4
   set color green
   set suppliers []
   set supplier_score []
   set placed_orders []
   set label (word "Ret. " [who] of self "   ")
   let s read-from-string first(Inventory_Policy)
   ifelse s = 4
   [set strategy (random 3) + 1]
   [set strategy s]
  ]

  ask turtles with [breed != customers][
    set daily_sales []
    set clients []
    set sales []
    set lost_sales []
    set forecast []
    set holding_cost []
    set order_cost []
    set total_cost []]

  create-customers Clients_N [
   set size 1
   set color 3
   set suppliers []
   set supplier_score []
   set demand round(random-normal Demand_W DS_D)
   set daily round(demand / 7)
   let s read-from-string first(Customers_Strategy)
   ifelse s = 3
   [set strategy (random 2) + 1]
   [set strategy s]
  ]

  set-default-shape Factories "dist0"
  set-default-shape distributors "dist1"
  set-default-shape retailers "dist2"
  set-default-shape customers "person"
  ask turtles [find_patch]
  find_nearest
  update_clients 0
  update_market
  update_clients 0
  setup_parameters
  create_network
  update_plots
end

to go
  send_products
  buy_products
  main_sequence
  update_clients 1
  create_network
  update_plots
  purge
  evaluate_results
  print_watch
  tick                 ;Next Day
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; SETUP SUBROUTINES ;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to find_patch
  setxy random-xcor random-ycor
  while [any? other turtles-here]
      [find_patch]                 ; keeps running until each patron is alone on patch
end

to find_nearest
  ask turtles with [breed != factories]
  [let d []
   if breed = customers [set d sort([who] of retailers)]
   if breed = retailers [set d sort([who] of distributors) ]
   if breed = distributors [set d sort([who] of factories) ]
   foreach d
     [ ?1 -> let temp2 []
       set temp2 lput(?1) temp2
       set temp2 lput(distance turtle ?1) temp2
       set suppliers lput temp2 suppliers ]
   set suppliers sort-by [ [?1 ?2] -> last ?1 < last ?2 ] suppliers
   set supplier_score map [ ?1 -> int(last ?1) + int(((last ?1) - int(last ?1)) * 10) / 10 ] suppliers]
end

to update_clients [flag]
  ifelse flag = 0
  [ask turtles with [breed != factories] [
    let m min(supplier_score)
    let p position m supplier_score
    set supplier0 first(item p suppliers)]
  ask turtles with [breed != customers] [
    let n [who] of self
    set clients sort([who] of turtles with [(breed = retailers or breed = distributors or breed = customers) and supplier0 = n])]
  ask turtles with [breed = distributors or breed = factories] [
    foreach clients [set orders lput [0 0] orders]]]
  [ask customers [
    let m min(supplier_score)
    let p position m supplier_score
    set supplier0 first(item p suppliers)]
  ask retailers [
    let n [who] of self
    set clients sort([who] of turtles with [(breed = retailers or breed = distributors or breed = customers) and supplier0 = n])]]
end

to create_promotion
  ;Simple method: Increase de demand in some specific retailer choose for the user
  let list1 read-from-string user-input "Create a promotion [a b c] (retailer a, impact b (1 to 10), during c periods"
  ifelse is-list? list1 and length(list1) = 3
  [let p item 0 list1
  let i item 1 list1
  let c (item 2 list1) + ticks
  let l []
  set l lput(p) l
  set l lput(i) l
  set l lput(c) l
  set promotion l
  user-message (word "Today a promotion will occur at store " p)
  if Score_Retailers? = true
  [ask customers [let list2 map [ ?1 -> first ?1 ] suppliers
    let m position p list2
    set supplier_score (replace-item m supplier_score (item m supplier_score - (random-float item 1 list1)))]]
  ]
  [user-message (word "The array doen't have a valid format, pleas try again")]
end

to create_network
  ask links [die]
  ifelse Show_Network = true [
    ask customers [
      if supplier0 != nobody
      [create-link-to retailer supplier0
      [set color gray + 3]]]
    ask retailers [
      create-link-to distributor supplier0
      [set color green]]
    ask distributors [
      create-link-to factory supplier0
      [set color blue]]
    set ret_list sort([who] of retailers)
    let dd []
    ;let ddd sort(retailers)
    foreach ret_list
    [ ?1 -> set dd lput(count(links with [end2 = retailer ?1])) dd ]
    set-current-plot "Clients per Retailer"
    clear-plot
    foreach dd
    [ ?1 -> plot ?1 ]]
  [ask links [die]
    set-current-plot "Clients per Retailer"
    clear-plot]
end

to setup_parameters
  ask customers [
    set stock random demand
  ]
  ask retailers [
    set stock round(sum([demand] of customers) / count(retailers)) * 5      ;All agents of the same type starts with the same stock
    set demand mean([daily] of customers) * length(clients) * 1
  ]
  ask distributors [
    set stock round(sum([stock] of retailers)) * .5    ;All agents of the same type starts with the same stock
    set demand mean([demand] of retailers) * length(clients) * 1
  ]
  ask Factories [
    set stock round(sum([stock] of distributors))
    set production_rate round(sum([demand] of customers) * 10)
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;; GO SUBROUTINES ;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update_market
  ask turtles with [breed != customers and clients = []] [die]
end

to send_products
  ask turtles with [breed = distributors or breed = factories]
  [let list1 map [ ?1 -> last ?1 ] orders
   let list2 filter [ ?1 -> ?1 = ticks ] list1
   if length(list2) > 0 and max(list2) > 0
   [let attending filter [ ?1 -> last ?1 = ticks ] orders
     set list2 []
     let list3 []
     foreach attending [ ?1 ->
       set list2 lput(item (position ?1 orders) clients) list2
       set list3 lput(first(item(position ?1 orders) orders)) list3 ]
     let i 0
     while [i < length(list2)] [
     ask turtle (item i list2) [
       set stock (stock + item i list3)]
     set i i + 1]
     set i 0
     while [i < length(orders)]
     [if last(item i orders) = ticks
       [set orders replace-item i orders [0 0]]
       set i i + 1]]
  ]

end

to buy_products
  ;Customers go shopping according to their demand and their stock
  let list1 []
  ask turtles with [breed = retailers or breed = distributors or breed = factories ][
    set daily_sales []
    set lost_sales []]
  ask customers [
    let dem 0
    ifelse strategy = 1
    [set dem daily]
    [set dem round(daily * 4)]
    if promotion != [0 0 0] and member? who [clients] of retailer supplier0
    [set dem round(dem * random-float (item 1 promotion))]
    ifelse stock < dem and next_review = ticks [
        let agent [who] of self
        let d (dem + (dem - stock))
        ifelse [stock] of retailer (supplier0) >= d
        [ask retailer (supplier0) [
          set stock stock - d
          set daily_sales lput d daily_sales
          set lost_sales lput 0 lost_sales]
        let dd []
        set dd lput agent dd
        set dd lput d dd
        set list1 lput dd list1
        set stock stock - daily + d
        if Score_Retailers? = true
        [score_supplier who -0.01]]
        [ask retailer (supplier0) [set lost_sales lput dem lost_sales]
         if Score_Retailers? = true
         [score_supplier who 2 ]]
        ifelse strategy = 2
        [set next_review ticks + 3]
        [set next_review ticks + 1]]
      [ifelse stock - dem >= 0
        [set stock stock - dem]
        [set stock 0]
       set next_review ticks + 1 ]]
  ask retailers [
    update_sales
    if strategy != 3
    [set next_review ticks + 1]]
end

to update_sales
  let es sum(daily_sales)
  let ls sum(lost_sales)
  let l []
  set l lput es l
  set l lput ls l
  set sales lput l sales
end

to main_sequence
  ask retailers [
    update_forecast
    place_orders
    update_costs]
  ask distributors [
    update_sales
    update_forecast
    place_orders
    update_costs]
  ask factories [
    update_sales
    if stock < reorder_point
    [set stock stock + production_rate]
    update_forecast
    update_costs]
  ask customers [update_demand]
end

to update_forecast
  ;Retailers, Distributors and Factories update their expectations
  let forecasting []
  set forecast []
  let temp_demand 0
  if length(sales) > 0 [set temp_demand map [ ?1 -> sum(?1) ] sales]
  let ds 0
  ifelse (length(sales) > 2) and (max(temp_demand) != 0)
  [set forecast matrix:forecast-linear-growth (temp_demand)
    set ds standard-deviation temp_demand]
  [set forecast lput(round(demand / 7)) forecast
    set forecast lput(round(demand / 7)) forecast
    set forecast lput(0) forecast
    set forecast lput(0) forecast]
  let b item 1 forecast
  let a item 2 forecast
  let t length(sales)
  let i 1
  while [i <= 7] [
    set forecasting lput(t * a + b) forecasting
    set i i + 1
    set t t + 1]
  set demand round(sum(forecasting))
  if demand < 0 [set demand 0]
  let dailyd demand / 7
  let Lead_Time Lt0
  if breed = retailers [set Lead_Time Lt1]
  let z table:get safety_values SS_%
  if breed != factories
  [set EOQ round(sqrt(2 * demand * 52 * K / (HC * Product_cost)))]
  set reorder_point round(dailyd * Lead_Time + z * ds)

end

to print_watch
  if watching != 0
  [
   show (word "At the period " ticks " the agent " watching " update its expectations :")
   if ([breed] of turtle watching != customers) [
     show (word "Sales " [sales] of turtle watching)
     show (word "Forecast " [forecast] of turtle watching)]
   show (word "Demand " [demand] of turtle watching)
   if ([breed] of turtle watching != customers and [breed] of turtle watching != factories) [
     show (word "EOQ " [EOQ]  of turtle watching)
     show (word "Reorder Point " [reorder_point] of turtle watching)]
   show (word "Stock " [stock] of turtle watching)
  ]
end

to follow_someone
  ifelse watching = 0
  [let l read-from-string user-input "What agent do you want to inspect?"
    set watching l
  watch turtle watching
  inspect turtle watching]
  [set watching 0
    reset-perspective]
end

to place_orders
  ;Retailers and Distributors place orders according to their stock and forecasting
  if stock <= reorder_point [
    let p position [who] of self ([clients] of turtle supplier0)
    let actual_order first(item p ([orders] of turtle supplier0))
    if actual_order = 0 [
      let comande 0
      let lead_time Lt0
      if breed = retailers
      [set lead_time Lt1]
      ifelse strategy = 1
      [set comande round(EOQ - stock)]
      [set comande round(EOQ + (demand / 7) * lead_time)]
      let disp 0
      ask turtle supplier0 [
        let delivery ticks + lead_time
        let g []
        let ll 0
        ifelse stock > comande
        [set disp comande]
        [set disp stock
          set ll comande - disp]
        set g lput disp g
        set g lput delivery g
        set orders replace-item p orders g
        set stock stock - disp
        set daily_sales lput(disp) daily_sales
        set lost_sales lput(ll) lost_sales
      ]
      set placed_orders lput(disp) placed_orders]
  ]
end

to update_demand
  ifelse promotion = [0 0 0]
  [set demand round(random-normal Demand_W DS_D)
  set daily round(demand / 7)]
  [let p item 2 promotion
    if ticks = p [set promotion [0 0 0]]
  ]
end

to update_costs
  set holding_cost lput (HC * stock * Product_cost) holding_cost
  ifelse breed != factories
  [if (length(placed_orders) = 0) OR (length(placed_orders) != length(holding_cost))
  [set placed_orders lput 0 placed_orders]
  ifelse last(placed_orders) = 0
  [set order_cost lput 0 order_cost]
  [set order_cost lput K order_cost]
  set total_cost lput (last(order_cost) + last(holding_cost)) total_cost]
  [set total_cost lput (last(holding_cost)) total_cost]
end

to evaluate_results
  ;Collect statistics at the end of each period
  let l []
  ifelse first(promotion) = 0
  [set l lput (word ticks "-Reg") l]
  [set l lput (word ticks "-P-" item 0 promotion "-" item 1 promotion) l]
  set l lput(sum([stock] of customers)) l
  set l lput(sum([stock] of retailers)) l
  set l lput(sum([stock] of distributors)) l
  set l lput(sum([stock] of factories)) l
  set stocks_h l
  set l []
  let s 0
  foreach ([total_cost] of retailers) [ ?1 -> set s s + (last(?1)) ]
  set l lput(s) l
  set s 0
  foreach ([total_cost] of distributors) [ ?1 -> set s s + (last(?1)) ]
  set l lput(s) l
  set s 0
  foreach ([total_cost] of factories) [ ?1 -> set s s + (last(?1)) ]
  set l lput(s) l
  set costs_h l

  ; moving average of stocks
  set stock_customer_MA lput sum([stock] of customers) stock_customer_MA
  set stock_retailer_MA lput sum([stock] of retailers) stock_retailer_MA
  set stock_distributor_MA lput sum([stock] of distributors) stock_distributor_MA
  set stock_factory_MA lput sum([stock] of factories) stock_factory_MA

  while [length stock_customer_MA > MA] [set stock_customer_MA remove-item 0 stock_customer_MA]
  while [length stock_retailer_MA > MA] [set stock_retailer_MA remove-item 0 stock_retailer_MA]
  while [length stock_distributor_MA > MA] [set stock_distributor_MA remove-item 0 stock_distributor_MA]
  while [length stock_factory_MA > MA] [set stock_factory_MA remove-item 0 stock_factory_MA]

  ifelse empty? stock_customer_MA [set stock_customer_MA_mean 0] [set stock_customer_MA_mean mean(stock_customer_MA)]
  ifelse empty? stock_retailer_MA [set stock_retailer_MA_mean 0] [set stock_retailer_MA_mean mean(stock_retailer_MA)]
  ifelse empty? stock_distributor_MA [set stock_distributor_MA_mean 0] [set stock_distributor_MA_mean mean(stock_distributor_MA)]
  ifelse empty? stock_factory_MA [set stock_factory_MA_mean 0] [set stock_factory_MA_mean mean(stock_factory_MA)]

  let totalStocks (stock_customer_MA_mean + stock_retailer_MA_mean + stock_distributor_MA_mean + stock_factory_MA_mean)
  if (totalStocks != 0) [
    set stock_customer_MA_mean_relative (stock_customer_MA_mean / totalStocks)
    set stock_retailer_MA_mean_relative (stock_retailer_MA_mean / totalStocks)
    set stock_distributor_MA_mean_relative (stock_distributor_MA_mean / totalStocks)
    set stock_factory_MA_mean_relative (stock_factory_MA_mean / totalStocks)
  ]

  ; lost sales ratio
  set lost_sales_ret (lost_sales_ret + sum([sum(lost_sales)] of retailers))
  set lost_sales_dis (lost_sales_dis + sum([sum(lost_sales)] of distributors))
  set lost_sales_fac (lost_sales_fac + sum([sum(lost_sales)] of factories))

  set daily_sales_ret (daily_sales_ret + sum([sum(daily_sales)] of retailers))
  set daily_sales_dis (daily_sales_dis + sum([sum(daily_sales)] of distributors))
  set daily_sales_fac (daily_sales_fac + sum([sum(daily_sales)] of factories))

  if (lost_sales_ret + daily_sales_ret != 0) [
    set lost_ratio_sales_ret (lost_sales_ret / (lost_sales_ret + daily_sales_ret))
  ]
  if (lost_sales_dis + daily_sales_dis != 0) [
    set lost_ratio_sales_dis (lost_sales_dis / (lost_sales_dis + daily_sales_dis))
  ]
  if (lost_sales_fac + daily_sales_fac != 0) [
    set lost_ratio_sales_fac (lost_sales_fac / (lost_sales_fac + daily_sales_fac))
  ]

end

to purge
  ask turtles with [breed != customers]
  [if length(sales) > 100
    [let l length(sales)
      set sales sublist sales (l - 100) l
      ]]
end

to score_supplier [a b]
 ;agent A, score B
 ask turtle a [
  let list1 map [ ?1 -> first ?1 ] suppliers
  let p position supplier0 list1
  if item p supplier_score + b >= 0
  [set supplier_score replace-item p supplier_score (item p supplier_score + b)]
 ]
end

to update_plots
  set-current-plot "Daily Stock"
  let s []
  ;Customers
  set-current-plot-pen "Customers"
  plot sum([stock] of Customers)
  ;Retailers
  set-current-plot-pen "Retailers"
  plot sum([stock] of retailers)
  set s lput(sum([stock] of retailers)) s
  ;Distributors
  set-current-plot-pen "Distributors"
  plot sum([stock] of distributors)
  set s lput(sum([stock] of distributors)) s
  ;Factories
  set-current-plot-pen "Factories"
  plot sum([stock] of Factories)
  set s lput(sum([stock] of Factories)) s
  ;set-plot-y-range 0 max(s)
end
@#$#@#$#@
GRAPHICS-WINDOW
197
13
868
425
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-25
25
-15
15
0
0
1
Day
30.0

BUTTON
4
376
62
409
Setup
Setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
51
97
84
Distr1
Distr1
Fact
Fact * 6
23.0
1
1
NIL
HORIZONTAL

SLIDER
5
88
97
121
Distr2
Distr2
Distr1
Distr1 * 4
90.0
1
1
NIL
HORIZONTAL

SLIDER
5
126
190
159
Clients_N
Clients_N
Distr2
Distr2 * 50
500.0
1
1
NIL
HORIZONTAL

BUTTON
17
412
83
445
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
5
165
101
198
Demand_W
Demand_W
5
30
20.0
1
1
NIL
HORIZONTAL

PLOT
1031
10
1231
131
Clients per Retailer
NIL
NIL
0.0
10.0
0.0
40.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" ""

PLOT
875
182
1144
369
Daily Stock
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Factories" 1.0 0 -2674135 true "" ""
"Distributors" 1.0 0 -13345367 true "" ""
"Retailers" 1.0 0 -10899396 true "" ""
"Customers" 1.0 0 -2064490 true "" ""

BUTTON
90
412
156
445
Step
Go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
98
51
190
84
Lt1
Lt1
0
7
4.0
1
1
NIL
HORIZONTAL

SLIDER
5
14
97
47
Fact
Fact
1
5
4.0
1
1
NIL
HORIZONTAL

SLIDER
98
14
190
47
Lt0
Lt0
0
7
4.0
1
1
NIL
HORIZONTAL

SLIDER
101
165
193
198
DS_D
DS_D
0
round(Demand_W / 2)
6.0
1
1
NIL
HORIZONTAL

CHOOSER
4
279
190
324
Customers_Strategy
Customers_Strategy
"1-DailyPurchase" "2-PeriodicallyPurchase" "3-Random"
2

SWITCH
871
35
998
68
Show_Network
Show_Network
1
1
-1000

SLIDER
6
202
98
235
HC
HC
0.01
0.1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
99
202
191
235
K
K
50
400
200.0
50
1
NIL
HORIZONTAL

BUTTON
871
130
937
163
Promote!
create_promotion
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
5
327
190
372
Inventory_Policy
Inventory_Policy
"1-(s,Q)" "2-(s,S)" "3-(R,S)" "4-Random"
3

SLIDER
98
88
190
121
SS_%
SS_%
0.5
0.95
0.75
0.05
1
NIL
HORIZONTAL

SLIDER
6
237
190
270
Product_cost
Product_cost
5
50
35.0
5
1
NIL
HORIZONTAL

SWITCH
64
377
198
410
Score_Retailers?
Score_Retailers?
1
1
-1000

MONITOR
1046
134
1226
179
Retailers
ret_list
17
1
11

BUTTON
939
130
1005
163
Inspect
follow_someone
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1255
181
1416
226
NIL
stock_customer_MA_mean
17
1
11

MONITOR
1253
136
1402
181
NIL
stock_retailer_MA_mean
17
1
11

MONITOR
1252
90
1418
135
NIL
stock_distributor_MA_mean
17
1
11

MONITOR
1254
42
1404
87
NIL
stock_factory_MA_mean
17
1
11

TEXTBOX
1657
49
1807
315
Fact: number of factories\nDistr1: number of distributors\nDistr2: number of retailers\nClients_N: number of customers\n\nLt0: lead time (others) (??)\nLt1: lead time (retailers) (??)\nSS_%: safety values percentage (??)\n\nDemand_W: Costumer demand mean\nHC: holding cost\nDS_D: Costumer demand variance\nK: order time horizon???\nProduct_cost: Cost for a factory to make the product.
11
0.0
1

SLIDER
1256
245
1428
278
MA
MA
0
1000
707.0
1
1
NIL
HORIZONTAL

TEXTBOX
1261
230
1411
248
moving average length
11
0.0
1

MONITOR
585
489
806
534
NIL
mean([sum(lost_sales)] of retailers)
17
1
11

MONITOR
818
543
1019
588
NIL
mean([sum(sales)] of distributors)
17
1
11

MONITOR
324
543
557
588
NIL
mean([sum(daily_sales)] of distributors)
17
1
11

MONITOR
589
542
816
587
NIL
mean([sum(lost_sales)] of distributors)
17
1
11

MONITOR
589
603
806
648
NIL
mean([sum(lost_sales)] of factories)
17
1
11

MONITOR
814
489
1003
534
NIL
mean([sum(sales)] of retailers)
17
1
11

MONITOR
817
598
1004
643
NIL
mean([sum(sales)] of factories)
17
1
11

MONITOR
326
486
555
531
NIL
mean([sum(daily_sales)] of retailers)
17
1
11

MONITOR
327
597
549
642
NIL
mean([sum(daily_sales)] of factories)
17
1
11

MONITOR
1154
290
1404
335
NIL
lost_ratio_sales_ret
17
1
11

MONITOR
1154
340
1402
385
NIL
lost_ratio_sales_dis
17
1
11

MONITOR
1154
390
1399
435
NIL
lost_ratio_sales_fac
17
1
11

MONITOR
1418
290
1627
335
NIL
stock_customer_MA_mean_relative
17
1
11

MONITOR
1415
342
1630
387
NIL
stock_distributor_MA_mean_relative
17
1
11

MONITOR
1419
388
1616
433
NIL
stock_retailer_MA_mean_relative
17
1
11

MONITOR
1415
443
1613
488
NIL
stock_factory_MA_mean_relative
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model is an artificial market with four types of participants. The first are the costumers who have a daily demand and according to their strategy can purchase daily or periodically if their stock is below some specific level. The second are the retailers who sell products to costumers and update their demand forecast by considering the sales and the stock rupture (lost sales). The third are the distributors (who follow a similar procedure) to send products to retailers. Finally, there are the factories who start producing once their inventory level is lower than some reorder point.  
The model can help students and professionals to understand better the supply chain with a single product, and how simple changes as the promotions, can affect the stocks levels and the demand calculation with a considerable amplitude, which is know as the bullwhip effect. 

## HOW IT WORKS

The customers demand is normally distributed with a given standard deviation. Both the mean and the variability are user parameters. The inventory values (product cost, holding costs and order costs), are also parameters from the model. The user can also modify the number of agents. Finally, the clients� strategy and the retailers and distributors strategy are also parameters. At every day, the costumers can score the purchase experience (if there are some), so the next period the customers will choose the best supplier. At the beginning, the score is given by taking into account only the distance from retailers (the nearest retailer will be the supplier), but with the time, the agents could change this perspective by punishing the supplier if the sale is incomplete.  
As to suppliers (retailers and distributors), they use linear regression for update their forecast and calculate the reorder point. If the stock is lower than this point, they place an order to their own supplier. If their strategy is (s,Q), they will only ask for the difference between the actual stock and the Economic Order Quantity (EOQ). If the strategy is (s,S), they will also consider the daily demand during the lead time. The last option is to repeat this last strategy but periodically.   
The factories does the same estimation but for starting the production in a fix daily rate calculated at the beginning of the simulation.

## HOW TO USE IT

The user should fix some values and play the model (I recommend at least 720 periods for having some stable results), then collect statistics and play again. Different values will result in different costs and stock levels which can be compared in the analysis and conclusions phase.

## THINGS TO NOTICE

See how the stock levels for each type of participant are so different but at the same time they follow the same patron?, this is because the inventory theory, no matter what strategy the agents, it will always happen.

## THINGS TO TRY

Try to create promotions at some moment. See how they affect the stock levels and the inventory costs. See also how some retailer can increase the clients� number and hence the sales with these activities.

## EXTENDING THE MODEL

It would be nice to improve the model with:  
1. More sophisticated forecasting models  
2. Add some operational costs to the suppliers, so the user could evaluate the profit of every business.   
3. Add more products to the models. This will require some elasticity concept because the products could or could not be substitutes among them, so the availability and/or the price will affect the demand.  
4. Finally, we can think in smarter suppliers, who update their strategy and also improve it, to compete and to increase the earnings.

## CREDITS AND REFERENCES

Developped by Alvaro Gil at the Polytechnic School of Motreal alvaro.gil@polymtl.ca  
If you mention this model in an academic publication, we ask that you include these citations for the model itself:  
- Gil, Alvaro (2012). Artificial supply chain. �cole Polytechnique de Montr�al.   
alvaro.gil@polymtl.ca

About the NetLogo software  
- Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT NOTICE

Copyright 2012 Alvaro Gil. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:  
a) this copyright notice is included.  
b) this model will not be redistributed for profit without permission from Alvaro Gil. Contact the author for appropriate licenses for redistribution for profit.
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

dist0
false
0
Rectangle -7500403 true true 45 225 270 300
Rectangle -16777216 true false 75 270 105 300
Polygon -7500403 true true 30 225 150 165 285 225
Rectangle -16777216 true false 120 270 150 300
Rectangle -16777216 true false 165 270 195 300
Rectangle -16777216 true false 210 270 240 300
Line -16777216 false 30 225 285 225

dist1
false
0
Rectangle -7500403 true true 45 225 255 300
Polygon -7500403 true true 30 225 150 165 270 225
Line -16777216 false 30 225 270 225
Rectangle -16777216 true false 90 255 135 300
Rectangle -16777216 true false 165 255 210 300

dist2
false
0
Rectangle -7500403 true true 45 225 255 300
Line -16777216 false 30 225 270 225
Rectangle -16777216 true false 105 270 135 300
Rectangle -16777216 true false 195 255 240 300
Polygon -7500403 true true 30 225 45 195 255 195 270 225
Rectangle -16777216 true false 60 270 90 300
Rectangle -16777216 true false 150 270 180 300

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
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

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
<experiments>
  <experiment name="1-Lead_Time1" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 1080</exitCondition>
    <metric>stocks_h</metric>
    <metric>costs_h</metric>
    <enumeratedValueSet variable="DS_D">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HC">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Demand_W">
      <value value="19"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Clients_N">
      <value value="225"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Show_Network">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SS_%">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Fact">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Customers_Strategy">
      <value value="&quot;3-Random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Lt0">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Inventory_Policy">
      <value value="&quot;2 - (s, S)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Distr1">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Distr2">
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Product_cost">
      <value value="30"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Lt1" first="1" step="1" last="5"/>
  </experiment>
</experiments>
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
