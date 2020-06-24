;; programming help from here: https://www.youtube.com/playlist?list=PLF0b3ThojznRKYcrw8moYMUUJK2Ra8Hwl

;; ------------------------------------ VARIABLES ----------------------------------
extensions [ nw ]

turtles-own[
  aware-independent? ;; if the agent became aware indepentent of the network
  aware-network? ;; if the agent because aware due to network influence
  adopted? ;; if the agent has adopted info
  adopted-num ;; number for if the agent has adopted info
  new ;; if the agent has adopted this tick
]

links-own [
  weight ;; trust between two agents
]

;; ------------------------------------ INITIALIZATION ---------------------------------------

;; ON PRESSING SETUP BUTTON
to setup
  clear-all

  ;; initialize the network
  create-pa

  ;; layout the network better
  repeat 60 [ layout-spring turtles links 0.2 1 1 ]

  ;; set the weights for edges between agents
  ask links [ add-weights ]

  ;; set the seed and trust level for the source
  set-seeds

  reset-ticks

end

;; CREATE A PREFERENTIAL ATTACHMENT NETWORK
to create-pa
  nw:generate-preferential-attachment turtles links num-turtles 1 [
      set size 0.75
      set  shape "person"
      set color green
      set aware-independent? false
      set aware-network? false
      set adopted? false
      set adopted-num 0
      set new false
    ]
end

;; SET THE INFORMATION SOURCE
to set-seeds

  ;; Set the information source as the one with the most connections
  ask max-n-of 1 turtles[count link-neighbors][
    set color yellow
    set adopted? true
    set new true
    set adopted-num 1

    ;; Set the link weight with input value
    ask my-links [
      set weight source-trust
      set thickness weight
    ]
  ]
end

;; ADD LINK WEIGHTS
to add-weights
  set weight random-float 1
  set thickness weight
end

;; ------------------------------------ DIFFUSION PROCESSES ------------------------------------

;; Adopt information from non-network sources
to adopt-rand
  if random-float 1 > 0.995 [
    set aware-independent? true
    set adopted? true
    ;set adopted-num 1
    set color red
    set new true
  ]
end

;; Adopt information from neighbours
to adopt-network-trust

  let num random-float 1 ;; introduce randomness into adoption
  let total 0 ;; numerator

    ask my-links[ ;; for each turtle, get the links
      let w weight ;; set variable for the weight of the link
      ask other-end[ ;; for each link, get the turtle on the other end
        set total (total +  (w * adopted-num)) ;;
        ;;show total
  ]]
    if num < total / count link-neighbors [
    set aware-network? true
    ;set adopted-num 1
    set adopted? true
    set color pink
    set new true
  ]

end

;; ------------------------------------ SOME ADMIN STUFF ------------------------------------

;; reset the colors and variables for agents that are no longer newly aware
to reset-new
  set new false
  if(aware-network?)[set color pink]
  if(aware-independent?)[set color red]
  if(adopted?)[set adopted-num 1]
end

;; change color of agents that are newly aware
to color-new
  if(new)[set color blue]
end

;; ------------------------------------ RUN PROCEDURES WITH EACH TICK ------------------------

to go

  ;; reset the turtles that were previously new
  ask turtles[reset-new]

  ;; stop running if all turtles have adopted
  if(not any? turtles with [not adopted?])[stop]

  ;; processes for adopting information
  ask turtles with [not adopted?] [
    adopt-network-trust ;; adopt from network effects
    adopt-rand ;; adopt from random effects
  ]

  ask turtles[color-new] ;; colour the turtles that have newly adopted

  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
204
10
641
448
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
117
91
180
124
NIL
setup\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
117
128
180
161
NIL
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

PLOT
666
66
866
216
Total Aware
Time
Agents aware
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"independent" 1.0 0 -2674135 true "" "plot count turtles with [aware-independent?]\n"
"network" 1.0 0 -7500403 true "" "plot count turtles with [aware-network?]"
"all" 1.0 0 -14439633 true "" "plot count turtles with [adopted?]"

BUTTON
117
166
192
199
go once
go
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
21
12
193
45
num-turtles
num-turtles
5
1500
1157.0
1
1
NIL
HORIZONTAL

PLOT
667
220
867
370
Newly aware
Time
Newly aware
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"independent" 1.0 0 -2674135 true "" "plot count turtles with [aware-independent? = true and new = true]"
"network" 1.0 0 -7500403 true "" "plot count turtles with [new = true and aware-network? = true]"
"all" 1.0 0 -15040220 true "" "plot count turtles with [new]"

SLIDER
21
50
193
83
source-trust
source-trust
0
1
0.05
0.01
1
NIL
HORIZONTAL

@#$#@#$#@
# ODD Description

This ODD description is written following the guidance of Grimm et al. (2010). The implementation of this model in NetLogo was aided by Rand (2019a, 2019b, 2019c). 

## Purpose

This model represents the process of information diffusion in a social network during a crisis, with consideration for different levels of trust between agents. The purpose of this model is to empirically understand the impact of trust in an information source on the speed of information diffusion across agents within the network. 

## Entities, state variables, and scales

This model includes two types of agents. One agent is selected to be the _information source_ and all other agents correspond to information-seeking individuals who are impacted by an ongoing crisis. Each agent has a binary variable that indicates whether or not they have adopted the information that is circulating through the network (_adopted state_). Agents also have a binary variable indicating whether they have adopted the information in the current time step (_newly adopted state_). 

Agents exist in an abstracted social network space where they are connected to each other through links. Each link is weighted from (0,1], indicating the level of trust between two agents. Values closer to 1 correspond to stronger trust. For visual clarity, the width of a link corresponds to the weight. Note that the length of a single link bears no significance. Connections between agents follow a preferential attachment structure (Barabasi and Albert, 1999) to model an environment in which many agents are connected to one dominant information source. 

The agent with the largest number of links to other agents is set to be the information source. The model can be initialized to varying numbers of agents (from 5 - 1500). 

One time step corresponds to an arbitrary temporal unit. 

## Process overview and scheduling

This model proceeds according to the following procedures:
 
1. 	Initialization as described below.

2.	All agents who adopted the information in the previous time step are no longer in the _newly adopted state_.

3.	At each time step, all agents who are NOT in the _adopted state_ 

	- Draw a random float within the (0,1) range, 
	- Determine the number of network neighbours who are in an _adopted state_ (and not _newly adopted_), 
	- For each of these neighbours evaluate the level of trust in the relationship using the trust coefficient in the link, 
	- Decide whether to adopt, first according to p<sub>i,b</sub>, then p<sub>i,a</sub>, as outlined in the ‘Submodules’ section  below, 
	- If deciding to adopt, update internal state to both _adopted state_ and _newly adopted state_.

4.	Update to the output statistics 

5.	Advance a timestep and repeat Steps 2-4

6. 	Terminate model when all agents are in the _adopted state_.  


## Design concepts


_Basic Principles_: This model implements a modified version of the Independent Cascade model of information diffusion, first described by Goldenberg et al. (2001) and previously implemented as an ABM by Rand et al. (2015). This model incorporates weighted links between agents to account for varying levels of trust. A key theoretical underpinning to this model is the notion that the trust between an agent and their neighbours impacts the likelihood with which that agent will adopt information transmitted by their neighbours (Haynes et al., 2008; Hovland et al., 1953; Wu et al., 2017). 

_Emergence_: Given enough sustained exposure from network neighbours, all agents in the model will eventually adopt the information in the network. We see that increases in trust with the information source have little significant impact on the overall time to 100% information diffusion within the network (ie. number of ticks to when all agents are in _adopted state_). 

_Adaptation_: Agents in this model do not adapt.

_Objectives_: Agents do not have any explicit objectives. 

_Learning_: Agents do not learn. 

_Prediction_: Agents in this model do not make any predictions.

_Sensing_: Each agent has an awareness of whether or not their neighbours (the other agents with whom they share a direct link) have adopted the information in the network. Agents update this knowledge with each time step in the model. Agents are also aware of the level of trust in the relationship with their neighbours. 

_Interaction_: Agents interact by transmitting information to their network neighbours. This interaction models a form of communication, such as through word-of-mouth, online platforms. 
 
_Stochasticity_: This model has three stochastic components that result in model behaviours that can vary with the same parameter settings. 1) Firstly, the social network structure is initialized according to probabilities of connectivity, and thus varies slightly with each initialization. 2) Secondly, the weight of each link between two non-source agents is generated randomly within the (0,1) range. 3) Thirdly, each agent draws a random number within the (0,1) range at each time step. This number is used to determine whether or not the agent adopts the information in the network, according to the procedure defined in the ‘Submodels’ section below. 

_Collectives_: The entire social network of connected agents exists as a collective. All agents in the model are connected to the network. 

_Observation_: With each tick, we observe the total number of agents in the _adopted state_ and in the _newly adopted state_. 

## Initialization

The model is initialized according to the following steps: 

1.	The model is first initialized by selecting the total number of agents. The default number is 1000. 
2.	The network structure is then initialized according to the properties of preferential attachment networks. Nodes are added one at a time and are connected to existing nodes with a probability that corresponds to the number of connections that each existing node already has. This approach results in networks that contain a small number of highly linked nodes. The connectedness of nodes in the network follows a power law distribution in which few nodes contain the vast majority of links and many nodes have few links (Barabási and Albert, 1999). 

3.	The node with the greatest number of connections is set as the information source, and is this set to have adopted the information. 

4.	All other agents are set to an unadopted state. 

5.	Trust coefficients are assigned to all link weights. The trust coefficient for links connected to the information source are set uniformly according to an input parameter. Trust coefficients between all non-source links are set randomly within the (0,1] range. 


## Input data 

This model does not include any input data. 

## Submodels

Agents decide to adopt information in a manner derived from the Independent Cascade model of information diffusion, initially from Goldenberg et al. (2001), and applied to the context of crisis communication by Rand et al. (2015). We modify this model to account for varying levels of trust between agents. According to this model, agents in the network can adopt information according to one of two processes: 

Firstly, an agent may adopt information due to awareness or influence exerted that is external to the network. The probability of this occurring at a given tick is defined below. Given that we are interested in diffusion processes between network neighbours, we set this probability to be relatively low. This value is also within the range of values explored by Rand et al. (2015). 

> p<sub>i,a</sub> = 0.005  

> Where:
> p<sub>i,a</sub> is the probability of node i adopting information by external influence 

Secondly, an agent may adopt information as result of transmission from their network neighbours. We define this probability with consideration for the proportion of neighbours who have adopted the information and the level of trust between the given agent and each of these neighbours. Thus, both stronger trust relationships and a greater proportion of adopted neighbours results in a greater probability of a given agent adopting the information. 
	
> p<sub>i,b</sub> = (&sum;<sup>k<sub>i</sub></sup><sub>j=1</sub> w<sub>i,j</sub>x<sub>i,j</sub> ) / k<sub>i</sub> 

> Where:
> p<sub>i,b</sub> is the probability of node i adopting information by network transmission
> k<sub>i</sub> is the number of neighbours of node i   
> w<sub>i,j</sub> is the weight of the link to the jth neighbour of node i
> x<sub>i,j</sub> is a binary (0,1) variable indicating whether the jth neighbour of node i has adopted the information  




## References 

Barabási, A.-L., Albert, R., 1999. Emergence of Scaling in Random Networks. Science 286, 509–512. https://doi.org/10.1126/science.286.5439.509

Goldenberg, J., Libai, B., Muller, E., 2001. Talk of the Network: A Complex Systems Look at the Underlying Process of Word-of-Mouth. Mark. Lett. 12, 211–223. https://doi.org/10.1023/A:1011122126881

Grimm, V., Berger, U., DeAngelis, D.L., Polhill, J.G., Giske, J., Railsback, S.F., 2010. The ODD protocol: A review and first update. Ecol. Model. 221, 2760–2768. 

Haynes, K., Barclay, J., Pidgeon, N., 2008. The issue of trust and its influence on risk communication during a volcanic crisis. Bull. Volcanol. 70, 605–621. https://doi.org/10.1007/s00445-007-0156-z

Hovland, C.I., Janis, I.L., Kelley, H.H., 1953. Communication and persuasion, Communication and persuasion. Yale University Press, New Haven, CT, US.

Rand, W., 2019a. Agent-Based Modeling: Network Extension.

Rand, W., 2019b. Agent-Based Modeling: Model 6 - New Network Structures.

Rand, W., 2019c. Agent-Based Modeling: Model 4 - Networks.

Rand, W., Herrmann, J., Schein, B., Vodopivec, N., 2015. An Agent-Based Model of Urgent Diffusion in Social Media. J. Artif. Soc. Soc. Simul. 18, 1.

Wu, H., Arenas, A., Gómez, S., 2017. Influence of trust in the spreading of information. Phys. Rev. E 95, 012301. https://doi.org/10.1103/PhysRevE.95.012301


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
<experiments>
  <experiment name="total-time" repetitions="60" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <steppedValueSet variable="source-trust" first="0.1" step="0.05" last="1"/>
    <enumeratedValueSet variable="num-turtles">
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="0.06"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="independent-prob">
      <value value="0.995"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network">
      <value value="&quot;pa&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="runtime" repetitions="60" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [adopted?]</metric>
    <metric>count turtles with [new]</metric>
    <metric>mean [count link-neighbors] of turtles with [adopted?]</metric>
    <steppedValueSet variable="source-trust" first="0.05" step="0.05" last="1"/>
    <enumeratedValueSet variable="num-turtles">
      <value value="100"/>
      <value value="500"/>
      <value value="1000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="density">
      <value value="0.06"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="independent-prob">
      <value value="0.995"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="network">
      <value value="&quot;pa&quot;"/>
    </enumeratedValueSet>
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
