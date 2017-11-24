# MOD.Lib~ #

MOD.Lib~ is a modular synthesis library of MSP abstractions for modular synthesis and signal processing in Cycling 74's Max.

## Design Goals ##

### Responsiveness ###
One of the joys of working on an analog modular synth is the responsiveness of the controls; there is an immediacy to twiddling knobs that and making patch connections that is satisfying.  Modular synths are also designed for exploration rather than efficiency. It is much easier to build an interesting sound than it is to recreate a polyphonic three oscillator voice.  The code in MOD.Lib~ generally prioritizes responsiveness over efficiency.  Generally speaking, MOD.Lib~ avoids limiting the input range of values, except to prevent illegal values; if you want an attack-decay envelope that is a month long, you can do it.  Similarly, if you want to run an envelope fast enough to become an oscillator, or trigger a hi-hat 1000 times a second, simply speed up the triggering, since MOD.Lib~ abstractions can be triggered at signal rate.

### Building Blocks ###
MOD.Lib~ also provides building blocks for modular synthesis objects.  For example, MOD.RisingEdge~ detects the rising edge of an incoming gate signal and converts it into a trigger.  




## Operation ##

### Abstractions ###
MOD.Lib~'s abstractions are designed to behave like normal MSP objects with support for positional arguments as well as attributes.  They can also be configured and controlled via messages.

### Values ###
Unlike modular synths, MOD.Lib~ uses un-normalized values for its parameters.  This makes it less friendly to beginners, but it makes it easier to specify  values and interface with MSP objects.  For example, if you want the duration of the decay segment of an envelope to change from 1000 to 2000 ms, you would send in a signal that changes from 1000 to 2000 (e.g., from line~) into the decay inlet of the envelope.

### Triggers ###
Triggers in MOD.Lib~ are just single sample long pulses of a non-zero value.  You can use click~ to make them, or, for more precise timing, use phasor~ -> MOD.PhasorPulse~, which outputs a pulse once per cycle of phasor~.







