patches-own [
  feromone
  cibo
  nido
  profumo-nido
  risorse-cibo
  feromone-killer
]

breed [ant ants]
breed [killer killers]

ant-own[
  velocita-ant
  metabolismo-ant
  sf ;;scorta ants
  massimo_sf
]

killer-own[
  velocita-killer
  metabolismo-killer
  sk ;;scorta killers
  massimo_sk
]

globals [
  nmorti_ant
  nmorti_killer
]

;;;;;;;;;
;;SETUP;;
;;;;;;;;;

to Setup
  clear-all
  setup-ant
  set-patch-size 10
  setup-patches
  setup-killer
  reset-ticks
end

to setup-killer
  set-default-shape killer "turtle"
  create-killer Numero_Killer
  ask killer[
  set xcor 20
  set ycor 20
  set size 7
  set color red
  set massimo_sk random Scorta-Formichiere + 1
  set sk massimo_sk
  set velocita-killer random Vel-Killer + 1
  set metabolismo-killer random Metabolismo-Formichiere + 1
  ]
end

to setup-ant
  set-default-shape ant "bug"
  create-ant formiche
  ask ant [
    set size 1
    set color red
    set massimo_sf random Scorta-Formiche + 1
    set sf massimo_sf
    set velocita-ant random Vel-Ant + 1
    set metabolismo-ant random Metabolismo-Formiche + 1
  ]
end

to setup-patches
  ask patches
  [
    setup-nido
    setup-cibo
    recolor-patch
  ]
end

to setup-nido
  set nido (distancexy 0 0) < 5
  set profumo-nido 200 - distancexy 0 0
end

to setup-cibo
  if (distancexy (-0.3 * max-pxcor) 15) < 5
  [ set risorse-cibo 1 ]
  if risorse-cibo > 0
  [ set cibo one-of [1] ]
end

to recolor-patch
  ifelse nido
  [ set pcolor violet ]
  [ ifelse cibo > 0
    [ if risorse-cibo = 1 [ set pcolor cyan ]
    ]
    [ set pcolor scale-color green feromone 0.1 5
      ] ]
end



;;;;;;
;;GO;;
;;;;;;

to go
  move-ant
  move-killer
  if Feromone_Formichiere = true [killer-puzzone]
  if Food_Regeneration = true [RegenerationFood]
  tick
end

;;Rigenerazione scorta di cibo
to RegenerationFood
let resto ticks
set resto resto mod 150
if resto = 0
  [ ask patches [setup-cibo] ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;ANTS movimento e cerca di cibo;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-ant
  ask ant[
    reproduce-ant
    ifelse color = red
    [cerca-cibo]
    [ritorna-nido]
    wiggle
    fd velocita-ant
    set sf sf - metabolismo-ant
    muori
    fd 1]
  diffuse feromone (Diffusione-Feromone / 100)
  ask patches
  [set feromone feromone * (Persistenza-Feromone - 10) / 100
   recolor-patch]
end

to muori
  if sf <= 0 [set nmorti_ant nmorti_ant + 1]
  if sf <= 0 [die]
end

to wiggle
  if (feromone-killer >= 0.01)
  [rt 180 fd 5]
  rt random 40
  lt random 40
  if not can-move? 1 [ rt 180 ]
end

to reproduce-ant
  if random-float 100 < ant-reproduce AND count ant < formiche [
   set sf (sf / 2)
   hatch 1 [rt random-float 360 fd 1]
  ]
end

to ritorna-nido
  ifelse nido
  [set color red
  rt 180]
  [set feromone feromone + 40
  uphill-profumo-nido
  ]
  set sf massimo_sf
end

to cerca-cibo
  if cibo > 0
  [set color orange + 1
  set cibo cibo - 1
  rt 180
  stop]
  if (feromone >= 0.05) and (feromone < 2)
  [uphill-feromone]
end

to uphill-feromone
  let scent-ahead feromone-scent-at-angle   0
  let scent-right feromone-scent-at-angle  45
  let scent-left  feromone-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

to uphill-profumo-nido
  let scent-ahead profumo-nido-at-angle   0
  let scent-right profumo-nido-at-angle  45
  let scent-left  profumo-nido-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
  [ ifelse scent-right > scent-left
    [ rt 45 ]
    [ lt 45 ] ]
end

to-report profumo-nido-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [profumo-nido] of p
end

to-report feromone-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody [ report 0 ]
  report [feromone] of p
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;KILLERS movimento, riproduzione e caccia;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to killer-puzzone
  ask killer [
  set feromone-killer feromone-killer + 60
  ]

    diffuse feromone-killer (Diffusione-Feromone / 100)
    ask patches
    [set feromone-killer feromone-killer * (Persistenza-Feromone - 10) / 100
      recolor-patch]
end

to move-killer
  ask killer[
    reproduce-killer
    mangia-formica
    wiggle-killer
    set sk sk - metabolismo-killer
    muori-killer
  ]
end

to wiggle-killer
  fd velocita-killer
  rt random 30
  lt random 30
end

to reproduce-killer
    if random-float 100 < killer-reproduce AND count killer < Numero_Killer[  ; throw "dice" to see if you will reproduce
    set sk (sk / 2)                ; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 fd 1 ]   ; hatch an offspring and move it forward 1 step
  ]
end

to mangia-formica
    if count ant-here = 1
    [if count killer-here = 1
      [ask one-of ant-here[die]
      set nmorti_ant nmorti_ant + 1
      ask killer[set sk massimo_sk]]
    ]
end

to muori-killer
  if sk <= 0 [set nmorti_killer nmorti_killer + 1]
  if sk <= 0 [die]
end
@#$#@#$#@
GRAPHICS-WINDOW
190
70
908
789
-1
-1
10.0
1
10
1
1
1
0
1
1
1
-35
35
-35
35
0
0
1
ticks
60.0

BUTTON
9
11
75
47
NIL
Go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
107
10
175
48
NIL
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
7
54
179
87
Diffusione-Feromone
Diffusione-Feromone
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
7
95
180
128
Persistenza-Feromone
Persistenza-Feromone
0
100
100.0
1
1
NIL
HORIZONTAL

INPUTBOX
7
334
95
394
Formiche
100.0
1
0
Number

MONITOR
193
16
269
61
NIL
count ant
17
1
11

SLIDER
6
138
178
171
ant-reproduce
ant-reproduce
0
100
10.0
1
1
NIL
HORIZONTAL

SWITCH
17
276
180
309
Feromone_Formichiere
Feromone_Formichiere
0
1
-1000

MONITOR
276
16
355
61
NIL
nmorti_killer
17
1
11

INPUTBOX
8
407
163
467
Metabolismo-Formiche
3.0
1
0
Number

INPUTBOX
9
476
164
536
Scorta-Formiche
300.0
1
0
Number

INPUTBOX
8
611
163
671
Scorta-Formichiere
500.0
1
0
Number

INPUTBOX
8
544
167
604
Metabolismo-Formichiere
5.0
1
0
Number

SLIDER
7
181
179
214
killer-reproduce
killer-reproduce
0
100
1.0
1
1
NIL
HORIZONTAL

INPUTBOX
101
333
186
393
Numero_Killer
2.0
1
0
Number

PLOT
924
170
1124
320
Metabolismo Ant
NIL
NIL
0.0
5.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [metabolismo-ant] of Ant"

PLOT
923
12
1123
162
Scorta Ant
NIL
NIL
0.0
301.0
0.0
301.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [sf] of Ant"

PLOT
1162
10
1362
160
Scorta Killer
NIL
NIL
0.0
501.0
0.0
501.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [sk] of Killer"

INPUTBOX
8
682
74
742
Vel-Ant
5.0
1
0
Number

INPUTBOX
94
683
152
743
Vel-Killer
8.0
1
0
Number

PLOT
925
328
1125
478
Velocità Ant
NIL
NIL
0.0
5.0
0.0
6.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [velocita-ant] of Ant"

SWITCH
17
235
171
268
Food_Regeneration
Food_Regeneration
0
1
-1000

PLOT
1163
172
1363
322
Metabolismo Killer
NIL
NIL
0.0
6.0
0.0
6.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [metabolismo-killer] of Killer"

PLOT
1162
330
1362
480
Velocità Killer
NIL
NIL
0.0
8.0
0.0
8.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [velocita-killer] of Killer"

MONITOR
362
16
435
61
NIL
nmorti_ant
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
