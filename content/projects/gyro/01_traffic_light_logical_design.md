+++
title = "Traffic Light Logical Design"
date = 1970-01-01
+++
## Design Requirements

In the project overview, not much was specified about the actual function of the traffic totem. Rather, some requirements were established for functionality while the actual inner-workings were left undefined. Thus, before a design can be implemented, it must first be created. The basic requirements for the traffic totem are:

  - Four-way traffic
  - Only red, yellow, and green lights
  - Totem must respond to traffic

The first two of these requirements are somewhat self evident in how they'll impact the design of the totem. Four-way traffic requires that the totem will indeed be four-sided. The three light colors means... there will only need to be three light colors. However, the requirement for the totem to be responsive to traffic could reasonably be taken in several directions.

### Defining the Totem Response to Traffic

An unresponsive totem would operate simply by cycling the lights between the three colors on preset intervals and offsetting the cycles such that only parallel traffic is allowed to go at any given point in time. To make these lights responsive to traffic, the timing of these cycles must be partially dependent on the state of traffic at the intersection. The response could come in many forms, such as:

  - Cycling the lights anytime a traffic accumulates on a dead road
  - Cycling the lights after traffic on a active road is reduced
  - Extending the length of a light, but only for a maximum amount of time
  - Shortening the length of a light, but only down to a set minimum amount of time

And just as the response to the state of traffic can be defined in many ways, so too can the state of traffic. Some possible qualifiers for the state of traffic could be:

  - Whether there exists at least a single vehicle on a road
  - The amount of vehicles exist on a road
  - How long a road has been active or sleeping

Considering the restriction of only using logic gates to implement this design, it makes most sense to stick with binary qualifiers. Since the number of vehicles on a road and the amount of time they've been there aren't binary measurements, traffic will be measured simply based on whether there exists a vehicle on a road. Thus, the two input used by the totem will be a binary value representing whether a road has a vehicle on it at the intersection.

How will the totem use this information? The flow chart below maps the logic of a traffic light:

{% mermaid(label="Totem Cycle Flow Chart") %}
graph LR
    %% B-- yes -->D-- yes -->F-- yes -->E -->C
    %%            D-- no  -->E-->B
    %%                       F-- no  -->C
    %% B-- no  -->C

    B{{Has light changed recently?}}
    C[Change light]
    D{{Is either road sleeping?}}
    E[Wait for some time]
    F{{Is the other road active?}}

    F-- yes -->E -->B
    D-- no  -->E
    B-- yes -->D
    B-- no  -->C
    D-- yes -->F
    F-- no  -->C
{% end %}

This flow chart was derived from three principles ordered in order of precedence (the first principle is more important than the second is more important than the third):

  1. There should be a set maximum amount of time a light can remain a single color
  2. An active road should be allowed to remain active
  3. A sleeping road should be given a green light

## State Diagram

A traffic totem's core purpose is to ensure that any two roads of perpendicular traffic cannot both be active simultaneously. It does this most basically by giving a green light to only one road at a time. However, if the totem were to simply toggle between red and green, there would be danger of a road becoming active while an intersecting road hasn't fully cleared out of the intersection. Yellow lights solve this, but not fully. To ensure that the intersection is fully cleared, there will also be a brief period after a yellow light where all roads have a red light. The following state diagram models a totem that cycles its lights on a preset interval using yellow and double-red lights. However, it incorporated response whatsoever to traffic; that will be included soon.

{% mermaid(label="Totem Cycle Flow Chart") %}
stateDiagram-v2
    direction LR

    A: [G,R]
    B: [Y,R]
    C: [R,R]
    D: [R,G]
    E: [R,Y]
    F: [R,R]

    [*] --> A
    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> A
{% end %}

Assuming a constant clock cycle, this totem spends equal time in all states. A light would be green for the same amount of time it's yellow or red. Obviously, this doesn't make the most sense. A light should remain green much longer than it remains yellow. To implement this, we will say that a road will remain green unless its intersecting road is sleeping.

{% mermaid(label="Totem Cycle Flow Chart") %}
stateDiagram-v2
    direction LR

    A: [G,R]
    B: [Y,R]
    C: [R,R]
    D: [R,G]
    E: [R,Y]
    F: [R,R]

    A --> A:[1,0]
    D --> D:[0,1]

    [*] --> A
    A --> B:[0,*]\n[1,1]
    B --> C:[*,*]
    C --> D:[*,*]
    D --> E:[*,0]\n[1,1]
    E --> F:[*,*]
    F --> A:[*,*]
{% end %}

At this point, the second and third principles are implemented. To implement the first, each green light needs to be extended to multiple consecutive states, with each able to transition to the next green-light state or to a yellow light. I've made the somewhat arbitrary decision to extend the light to a maximum of six clock cycles based solely on the fact that it results in a total of 16 states, which is a power of 2. And thus we have our final state diagram.

{% mermaid(label="Totem Cycle Flow Chart") %}
stateDiagram-v2
    direction LR

    %% Nodes

    A1 : [G,R]
    state "Extended Light" as Green {
        A2 : [G,R]
        A3 : [G,R]
        A4 : [G,R]
        A5 : [G,R]
        A6 : [G,R]
    }
    B  : [Y,R]
    C  : [R,R]
    D1 : [R,G]
    state "Extended Light" as Red {
        D2 : [R,G]
        D3 : [R,G]
        D4 : [R,G]
        D5 : [R,G]
        D6 : [R,G]
    }
    E  : [R,Y]
    F  : [R,R]

    %% Transitions

    [*] --> A1

    A1 --> A2 : [1,*]\n[0,0]
    A2 --> A3 : [1,*]\n[0,0]
    A3 --> A4 : [1,*]\n[0,0]
    A4 --> A5 : [1,*]\n[0,0]
    A5 --> A6 : [1,*]\n[0,0]

    A1 --> B  : [0,1]
    A2 --> B  : [0,1]
    A3 --> B  : [0,1]
    A4 --> B  : [0,1]
    A5 --> B  : [0,1]
    A6 --> B  : [*,*]

    B --> C   : [*,*]
    C --> D1  : [*,*]

    D1 --> D2 : [*,1]\n[0,0]
    D2 --> D3 : [*,1]\n[0,0]
    D3 --> D4 : [*,1]\n[0,0]
    D4 --> D5 : [*,1]\n[0,0]
    D5 --> D6 : [*,1]\n[0,0]

    D1 --> E  : [1,0]
    D2 --> E  : [1,0]
    D3 --> E  : [1,0]
    D4 --> E  : [1,0]
    D5 --> E  : [1,0]
    D6 --> E  : [*,*]

    E --> F : [*,*]
    F --> A1 : [*,*]
{% end %}

## Binary Tables

By indexing each state by S<sub>0</sub>, S<sub>1</sub>, S<sub>2</sub>, etc., we can now translate the state diagram into a transition table. The transition table shows the current states and each possible input (whether each road is sleeping/active) in the left three columns, and the state that should come next given those three variables in the right column.

{% mermaid(label="Totem Cycle Flow Chart") %}
stateDiagram-v2
    direction LR

    %% Nodes

    A1 : S<sub>00</sub>
    state "Extended Light" as Green {
        A2 : S<sub>01</sub>
        A3 : S<sub>02</sub>
        A4 : S<sub>03</sub>
        A5 : S<sub>04</sub>
        A6 : S<sub>05</sub>
    }
    B  : S<sub>06</sub>
    C  : S<sub>07</sub>
    D1 : S<sub>08</sub>
    state "Extended Light" as Red {
        D2 : S<sub>09</sub>
        D3 : S<sub>10</sub>
        D4 : S<sub>11</sub>
        D5 : S<sub>12</sub>
        D6 : S<sub>13</sub>
    }
    E  : S<sub>14</sub>
    F  : S<sub>15</sub>

    %% Transitions

    [*] --> A1

    A1 --> A2 : [1,*]\n[0,0]
    A2 --> A3 : [1,*]\n[0,0]
    A3 --> A4 : [1,*]\n[0,0]
    A4 --> A5 : [1,*]\n[0,0]
    A5 --> A6 : [1,*]\n[0,0]

    A1 --> B  : [0,1]
    A2 --> B  : [0,1]
    A3 --> B  : [0,1]
    A4 --> B  : [0,1]
    A5 --> B  : [0,1]
    A6 --> B  : [*,*]

    B --> C   : [*,*]
    C --> D1  : [*,*]

    D1 --> D2 : [*,1]\n[0,0]
    D2 --> D3 : [*,1]\n[0,0]
    D3 --> D4 : [*,1]\n[0,0]
    D4 --> D5 : [*,1]\n[0,0]
    D5 --> D6 : [*,1]\n[0,0]

    D1 --> E  : [1,0]
    D2 --> E  : [1,0]
    D3 --> E  : [1,0]
    D4 --> E  : [1,0]
    D5 --> E  : [1,0]
    D6 --> E  : [*,*]

    E --> F : [*,*]
    F --> A1 : [*,*]
{% end %}

<details>
  <summary class="dropdown-summary">Show Content</summary>

| #  | S  | X<sub>0</sub> | X<sub>1</sub> | S<sup>+</sup> |
|----|----|----|----|----|
| 00 | 00 | 0  | 0  | 01 |
| 01 | 00 | 0  | 1  | 06 |
| 02 | 00 | 1  | 0  | 01 |
| 03 | 00 | 1  | 1  | 01 |
| 04 | 01 | 0  | 0  | 02 |
| 05 | 01 | 0  | 1  | 06 |
| 06 | 01 | 1  | 0  | 02 |
| 07 | 01 | 1  | 1  | 02 |
| 08 | 02 | 0  | 0  | 03 |
| 09 | 02 | 0  | 1  | 06 |
| 10 | 02 | 1  | 0  | 03 |
| 11 | 02 | 1  | 1  | 03 |
| 12 | 03 | 0  | 0  | 04 |
| 13 | 03 | 0  | 1  | 06 |
| 14 | 03 | 1  | 0  | 04 |
| 15 | 03 | 1  | 1  | 04 |
| 16 | 04 | 0  | 0  | 05 |
| 17 | 04 | 0  | 1  | 06 |
| 18 | 04 | 1  | 0  | 05 |
| 19 | 04 | 1  | 1  | 05 |
| 20 | 05 | 0  | 0  | 06 |
| 21 | 05 | 0  | 1  | 06 |
| 22 | 05 | 1  | 0  | 06 |
| 23 | 05 | 1  | 1  | 06 |
| 24 | 06 | 0  | 0  | 07 |
| 25 | 06 | 0  | 1  | 07 |
| 26 | 06 | 1  | 0  | 07 |
| 27 | 06 | 1  | 1  | 07 |
| 28 | 07 | 0  | 0  | 08 |
| 29 | 07 | 0  | 1  | 08 |
| 30 | 07 | 1  | 0  | 08 |
| 31 | 07 | 1  | 1  | 08 |
| 32 | 08 | 0  | 0  | 09 |
| 33 | 08 | 0  | 1  | 09 |
| 34 | 08 | 1  | 0  | 14 |
| 35 | 08 | 1  | 1  | 09 |
| 36 | 09 | 0  | 0  | 10 |
| 37 | 09 | 0  | 1  | 10 |
| 38 | 09 | 1  | 0  | 14 |
| 39 | 09 | 1  | 1  | 10 |
| 40 | 10 | 0  | 0  | 11 |
| 41 | 10 | 0  | 1  | 11 |
| 42 | 10 | 1  | 0  | 14 |
| 43 | 10 | 1  | 1  | 11 |
| 44 | 11 | 0  | 0  | 12 |
| 45 | 11 | 0  | 1  | 12 |
| 46 | 11 | 1  | 0  | 14 |
| 47 | 11 | 1  | 1  | 12 |
| 48 | 12 | 0  | 0  | 13 |
| 49 | 12 | 0  | 1  | 13 |
| 50 | 12 | 1  | 0  | 14 |
| 51 | 12 | 1  | 1  | 13 |
| 52 | 13 | 0  | 0  | 14 |
| 53 | 13 | 0  | 1  | 14 |
| 54 | 13 | 1  | 0  | 14 |
| 55 | 13 | 1  | 1  | 14 |
| 56 | 14 | 0  | 0  | 15 |
| 57 | 14 | 0  | 1  | 15 |
| 58 | 14 | 1  | 0  | 15 |
| 59 | 14 | 1  | 1  | 15 |
| 60 | 15 | 0  | 0  | 00 |
| 61 | 15 | 0  | 1  | 00 |
| 62 | 15 | 1  | 0  | 00 |
| 63 | 15 | 1  | 1  | 00 |
</details>

This table can be expanded by expanding each state index into it binary form. For example, $S_{13}$ would become $S_{1101}$ where $S_{0}=1$, $S_{1}=1$, $S_{2}=0$, and $S_{3}=1$. The resulting table from this expansion is:

<details>
  <summary class="dropdown-summary">Show Content</summary>

| #  | S  | S  | S  | S  | X  | X  | S  | S  | S  | S  |
|----|----|----|----|----|----|----|----|----|----|----|
| 00 | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 0  | 1  |
| 01 | 0  | 0  | 0  | 0  | 0  | 1  | 0  | 1  | 1  | 0  |
| 02 | 0  | 0  | 0  | 0  | 1  | 0  | 0  | 0  | 0  | 1  |
| 03 | 0  | 0  | 0  | 0  | 1  | 1  | 0  | 0  | 0  | 1  |
| 04 | 0  | 0  | 0  | 1  | 0  | 0  | 0  | 0  | 1  | 0  |
| 05 | 0  | 0  | 0  | 1  | 0  | 1  | 0  | 1  | 1  | 0  |
| 06 | 0  | 0  | 0  | 1  | 1  | 0  | 0  | 0  | 1  | 0  |
| 07 | 0  | 0  | 0  | 1  | 1  | 1  | 0  | 0  | 1  | 0  |
| 08 | 0  | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 1  | 0  |
| 09 | 0  | 0  | 1  | 0  | 0  | 1  | 0  | 1  | 1  | 0  |
| 10 | 0  | 0  | 1  | 0  | 1  | 0  | 0  | 0  | 1  | 0  |
| 11 | 0  | 0  | 1  | 0  | 1  | 1  | 0  | 0  | 1  | 0  |
| 12 | 0  | 0  | 1  | 1  | 0  | 0  | 0  | 1  | 0  | 0  |
| 13 | 0  | 0  | 1  | 1  | 0  | 1  | 0  | 1  | 1  | 0  |
| 14 | 0  | 0  | 1  | 1  | 1  | 0  | 0  | 1  | 0  | 0  |
| 15 | 0  | 0  | 1  | 1  | 1  | 1  | 0  | 1  | 0  | 0  |
| 16 | 0  | 1  | 0  | 0  | 0  | 0  | 0  | 1  | 0  | 1  |
| 17 | 0  | 1  | 0  | 0  | 0  | 1  | 0  | 1  | 1  | 0  |
| 18 | 0  | 1  | 0  | 0  | 1  | 0  | 0  | 1  | 0  | 1  |
| 19 | 0  | 1  | 0  | 0  | 1  | 1  | 0  | 1  | 0  | 1  |
| 20 | 0  | 1  | 0  | 1  | 0  | 0  | 0  | 1  | 1  | 0  |
| 21 | 0  | 1  | 0  | 1  | 0  | 1  | 0  | 1  | 1  | 0  |
| 22 | 0  | 1  | 0  | 1  | 1  | 0  | 0  | 1  | 1  | 0  |
| 23 | 0  | 1  | 0  | 1  | 1  | 1  | 0  | 1  | 1  | 0  |
| 24 | 0  | 1  | 1  | 0  | 0  | 0  | 0  | 1  | 1  | 1  |
| 25 | 0  | 1  | 1  | 0  | 0  | 1  | 0  | 1  | 1  | 1  |
| 26 | 0  | 1  | 1  | 0  | 1  | 0  | 0  | 1  | 1  | 1  |
| 27 | 0  | 1  | 1  | 0  | 1  | 1  | 0  | 1  | 1  | 1  |
| 28 | 0  | 1  | 1  | 1  | 0  | 0  | 1  | 0  | 0  | 0  |
| 29 | 0  | 1  | 1  | 1  | 0  | 1  | 1  | 0  | 0  | 0  |
| 30 | 0  | 1  | 1  | 1  | 1  | 0  | 1  | 0  | 0  | 0  |
| 31 | 0  | 1  | 1  | 1  | 1  | 1  | 1  | 0  | 0  | 0  |
| 32 | 1  | 0  | 0  | 0  | 0  | 0  | 1  | 0  | 0  | 1  |
| 33 | 1  | 0  | 0  | 0  | 0  | 1  | 1  | 0  | 0  | 1  |
| 34 | 1  | 0  | 0  | 0  | 1  | 0  | 1  | 1  | 1  | 0  |
| 35 | 1  | 0  | 0  | 0  | 1  | 1  | 1  | 0  | 0  | 1  |
| 36 | 1  | 0  | 0  | 1  | 0  | 0  | 1  | 0  | 1  | 0  |
| 37 | 1  | 0  | 0  | 1  | 0  | 1  | 1  | 0  | 1  | 0  |
| 38 | 1  | 0  | 0  | 1  | 1  | 0  | 1  | 1  | 1  | 0  |
| 39 | 1  | 0  | 0  | 1  | 1  | 1  | 1  | 0  | 1  | 0  |
| 40 | 1  | 0  | 1  | 0  | 0  | 0  | 1  | 0  | 1  | 1  |
| 41 | 1  | 0  | 1  | 0  | 0  | 1  | 1  | 0  | 1  | 1  |
| 42 | 1  | 0  | 1  | 0  | 1  | 0  | 1  | 1  | 1  | 0  |
| 43 | 1  | 0  | 1  | 0  | 1  | 1  | 1  | 0  | 1  | 1  |
| 44 | 1  | 0  | 1  | 1  | 0  | 0  | 1  | 1  | 0  | 0  |
| 45 | 1  | 0  | 1  | 1  | 0  | 1  | 1  | 1  | 0  | 0  |
| 46 | 1  | 0  | 1  | 1  | 1  | 0  | 1  | 1  | 1  | 0  |
| 47 | 1  | 0  | 1  | 1  | 1  | 1  | 1  | 1  | 0  | 0  |
| 48 | 1  | 1  | 0  | 0  | 0  | 0  | 1  | 1  | 0  | 1  |
| 49 | 1  | 1  | 0  | 0  | 0  | 1  | 1  | 1  | 0  | 1  |
| 50 | 1  | 1  | 0  | 0  | 1  | 0  | 1  | 1  | 1  | 0  |
| 51 | 1  | 1  | 0  | 0  | 1  | 1  | 1  | 1  | 0  | 1  |
| 52 | 1  | 1  | 0  | 1  | 0  | 0  | 1  | 1  | 1  | 0  |
| 53 | 1  | 1  | 0  | 1  | 0  | 1  | 1  | 1  | 1  | 0  |
| 54 | 1  | 1  | 0  | 1  | 1  | 0  | 1  | 1  | 1  | 0  |
| 55 | 1  | 1  | 0  | 1  | 1  | 1  | 1  | 1  | 1  | 0  |
| 56 | 1  | 1  | 1  | 0  | 0  | 0  | 1  | 1  | 1  | 1  |
| 57 | 1  | 1  | 1  | 0  | 0  | 1  | 1  | 1  | 1  | 1  |
| 58 | 1  | 1  | 1  | 0  | 1  | 0  | 1  | 1  | 1  | 1  |
| 59 | 1  | 1  | 1  | 0  | 1  | 1  | 1  | 1  | 1  | 1  |
| 60 | 1  | 1  | 1  | 1  | 0  | 0  | 0  | 0  | 0  | 0  |
| 61 | 1  | 1  | 1  | 1  | 0  | 1  | 0  | 0  | 0  | 0  |
| 62 | 1  | 1  | 1  | 1  | 1  | 0  | 0  | 0  | 0  | 0  |
| 63 | 1  | 1  | 1  | 1  | 1  | 1  | 0  | 0  | 0  | 0  |
</details>

### Deriving Equations

From here, we're able to extract equations for each $S^{+}$ term. I've chosen to use the [Quine-McCluskey Algorithm](https://en.wikipedia.org/wiki/Quine%E2%80%93McCluskey_algorithm) to do this, but other methods like the [Karnaugh Map](https://en.wikipedia.org/wiki/Karnaugh_map) exist.

#### S0

{% mermaid() %}
graph TD
    A00(011100)
    A01(011101)
    A02(011110)
    A03(011111)
    A04(100000)
    A05(100001)
    A06(100010)
    A07(100011)
    A08(100100)
    A09(100101)
    A10(100110)
    A11(100111)
    A12(101000)
    A13(101001)
    A14(101010)
    A15(101011)
    A16(101100)
    A17(101101)
    A18(101110)
    A19(101111)
    A20(110000)
    A21(110001)
    A22(110010)
    A23(110011)
    A24(110100)
    A25(110101)
    A26(110110)
    A27(110111)
    A28(111000)
    A29(111001)
    A30(111010)
    A31(111011)

    B00(01110*)
    B01(01111*)
    B02(10000*)
    B03(10001*)
    B04(10010*)
    B05(10011*)
    B06(10100*)
    B07(10101*)
    B08(10110*)
    B09(10111*)
    B10(11000*)
    B11(11001*)
    B12(11010*)
    B13(11011*)
    B14(11100*)
    B15(11101*)

    C00((0111**))
    C01(1000**)
    C02(1001**)
    C03(1010**)
    C04(1011**)
    C05(1100**)
    C06(1101**)
    C07((1110**))

    D01(100***)
    D02(101***)
    D03((110***))

    E01((10****))

    A00 --> B00
    A01 --> B00

    A02 --> B01
    A03 --> B01

    A04 --> B02
    A05 --> B02

    A06 --> B03
    A07 --> B03

    A08 --> B04
    A09 --> B04

    A10 --> B05
    A11 --> B05

    A12 --> B06
    A13 --> B06

    A14 --> B07
    A15 --> B07

    A16 --> B08
    A17 --> B08

    A18 --> B09
    A19 --> B09

    A20 --> B10
    A21 --> B10

    A22 --> B11
    A23 --> B11

    A24 --> B12
    A25 --> B12

    A26 --> B13
    A27 --> B13

    A28 --> B14
    A29 --> B14

    A30 --> B15
    A31 --> B15

    B00 --> C00
    B01 --> C00

    B02 --> C01
    B03 --> C01

    B04 --> C02
    B05 --> C02

    B06 --> C03
    B07 --> C03

    B08 --> C04
    B09 --> C04

    B10 --> C05
    B11 --> C05

    B12 --> C06
    B13 --> C06

    B14 --> C07
    B15 --> C07

    C01 --> D01
    C02 --> D01

    C03 --> D02
    C04 --> D02

    C05 --> D03
    C06 --> D03

    D01 --> E01
    D02 --> E01
{% end %}

#### S1
{% mermaid() %}
graph TD
    A00(000001)
    A01(000101)
    A02(001001)
    A03(001100)
    A04(001101)
    A05(001110)
    A06(001111)
    A07(010000)
    A08(010001)
    A09(010010)
    A10(010011)
    A11(010100)
    A12(010101)
    A13(010110)
    A14(010111)
    A15(011000)
    A16(011001)
    A17(011010)
    A18(011011)
    A19(100010)
    A20(100110)
    A21(101010)
    A22(101100)
    A23(101101)
    A24(101110)
    A25(101111)
    A26(110000)
    A27(110001)
    A28(110010)
    A29(110011)
    A30(110100)
    A31(110101)
    A32(110110)
    A33(110111)
    A34(111000)
    A35(111001)
    A36(111010)
    A37(111011)
{% end %}

#### S2
{% mermaid() %}
graph TD
    A00(000001)
    A01(000100)
    A02(000101)
    A03(000110)
    A04(000111)
    A05(001000)
    A06(001001)
    A07(001010)
    A08(001011)
    A09(001101)
    A10(010001)
    A11(010100)
    A12(010101)
    A13(010110)
    A14(010111)
    A15(011000)
    A16(011001)
    A17(011010)
    A18(011011)
    A19(100010)
    A20(100100)
    A21(100101)
    A22(100110)
    A23(100111)
    A24(101000)
    A25(101001)
    A26(101010)
    A27(101011)
    A28(101110)
    A29(110010)
    A30(110100)
    A31(110101)
    A32(110110)
    A33(110111)
    A34(111000)
    A35(111001)
    A36(111010)
    A37(111011)
{% end %}

#### S3
{% mermaid() %}
graph TD
    A00((000000))
    A01(000010)
    A02(000011)
    A03(010000)
    A04(010010)
    A05((010011))
    A06(011000)
    A07(011001)
    A08(011010)
    A09(011011)
    A10(100000)
    A11(100001)
    A12((100011))
    A13((101000))
    A14(101001)
    A15(101011)
    A16(110000)
    A17(110001)
    A18((110011))
    A19(111000)
    A20(111001)
    A21(111010)
    A22(111011)

    B00((00001*))
    B01((0100*0))
    B02(01100*)
    B03(01101*)
    B04((10000*))
    B05((1010*1))
    B06((11000*))
    B07(11100*)
    B08(11101*)

    C00((0110**))
    C01((1110**))

    A01 --> B00
    A02 --> B00

    A03 --> B01
    A04 --> B01

    A06 --> B02
    A07 --> B02

    A08 --> B03
    A09 --> B03

    A10 --> B04
    A11 --> B04

    A14 --> B05
    A15 --> B05

    A16 --> B06
    A17 --> B06

    A19 --> B07
    A20 --> B07

    A21 --> B08
    A22 --> B08

    B02 --> C00
    B03 --> C00

    B07 --> C01
    B08 --> C01
{% end %}
