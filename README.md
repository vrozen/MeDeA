# MeDeA

The Mechanics Design Assistant (MeDeA) is a prototype tool provided with the paper:
  Riemer van Rozen, A Pattern-Based Game Mechanics Design Assistant, Foundations of Digital Games, 2015.
  https://vrozen.github.io/fdg2015/fdg2015_rozen.pdf

## Running MeDeA
First install Rascal MPL, please find instructions here http://www.rascal-mpl.org
then run Rascal, open the project, start a console and type:
```
import lang::mm::IDE;
mm_register();
```
You can now left click a Micro-Machinations (.mm) file, click 'run MeDeA' and use it to analyze, explain and understand existing mechanics and generate, filter, explore and apply design decision alternatives for modifying mechanics.

## Diagrams and Patterns
Example models are provided in
  MeDeA/MM-IDE/test/diagrams/
and example patterns are provided in
  MeDeA/MM-IDE/test/patterns/
Using the textual MPL language you can also write your own patterns and extend the capabilities of the tool.
