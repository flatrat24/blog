+++
title = "Project Gyro"
description = "A physical implementation of vehicles moving through a traffic signal-governed intersection"
sort_by = "date"
template = "project.html"
page_template = "page.html"
+++
## Overview
The goal of this project is to create a physical representation of an traffic intersection. The initial general specifications are:

* The intersection should be a four-way: two roads with two lanes each
* The intersection should be governed by a four-way traffic signal
* Only the three basic lights (red, yellow, green) are used. No special lights should be considered (protected turn, flashing red, etc.)
* The traffic signal should respond to traffic in some capacity
* Only motor vehicle traffic is considered. Pedestrians, bikes, etc., are fully ignored

These specifications were chosen largely to simplify the design process. I've decided to restrict myself to using only logic gates to implement the logic control rather than opting for something like a microcontroller or SoC. I imagine that the logic for a four-way, traffic-responsive, traffic signal is complex enough as is that incorporating features such as special lights, pedestrians, and extra more lanes, would complicate the logic beyond what's reasonable for a logic-gate based design.

## Terminology

Before continuing, I should clarify the terminology I'll be using throughout this project. I'll note I'm an engineering student and have no training/education in urban design, traffic control, or any other field related to this project. As such, my terminology will be borrowed from colloquial terms or, if needed, coined by me. There might be established terms that would make my own redundant, but that doesn't concern me. The following are terms whose meaning might be more specific/different than the colloquial word used:

* **Traffic Signal:** A trio of red, yellow, and green lights all facing the same singular direction
* **Traffic Totem:** Four traffic signals housed inside a single enclosure with each signal facing one of four perpendicular directions
* **Lane:** A single path for vehicles to travel along in single file with a uniform direction throughout
* **Road:** A set of parallel lanes directly adjacent to each other, but no necessarily with a uniform direction.
* **Active/Sleeping/Dead Road:** An active road is one that 1) has vehicles on it, and 2) has a green light. A sleeping road is one that only fulfills has vehicles but no green light. A dead road is one without vehicles regardless of the color of the light.

## Project Structure

I'll be approaching this project in steps. I've broken down the overall design into a few key components that should be internally complete and able to interface with each other component to create a fully functioning intersection based on the established specifications. These components and the roles they serve in the system, are:
* **The Traffic Totem:** The totem must be able to receive input from the traffic to adjust its light cycle accordingly; the totem must also output some signal to the traffic to communicate which lanes can go/which can't
* **The Motor Vehicles:** The vehicles will be capable of three functions:
    * Self propulsion - this will likely be implemented through
    * Signaling to the totem that it is at the intersection - 
    * Listening to the totem for when the vehicle is able to move through the intersection - 
* **The Road:** The road largely just serves as a facilitator. Its main two functions will be to enable the self propulsion of the vehicles by acting as a track, and act as the interface between the totem and vehicle communicating
