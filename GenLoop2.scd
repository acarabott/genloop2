/*
    TODO Save as float format
    TODO Nick's SCMIR code for NRT
*/

s.options.inDevice = ServerOptions.inDevices[2];

s.boot;

s.waitForBoot({x = GenLoop.new(160, 5, 60)}); 

MIDIClient.init;
m = MIDIOut(0);
m.latency = 0;

~notes = (40..80);
~vels = (40..127);

~durs = [0.125, 0.25, 0.5];
m.noteOn(0, 60, 100);
m.noteOff(0, 60, 100);

r.stop;

m = MIDIOut;
r = Routine {
    inf.do {|i|
        var note = ~notes.choose;
        var vel = ~vels.choose;
        var wait = ~durs.choose;
        
        "note: ".post; (note).postln;
        "vel: ".post; (vel).postln;
        "wait: ".post; (wait).postln;
        
        m.noteOn(0, note, vel);
        wait.wait;
        m.noteOff(0, note, vel);
    };
};
r.play;
t = TempoClock();
r.play(t);
TempoClock.default.tempo = 0.2;
r.stop
x.recSynth.set(\sigIn, 0);
r.stop
s.boot
b = Buffer.read(s, "sounds/amen.wav");

b = Buffer.read(s, "sounds/GuitarMelody.aif");
b.play
c = Buffer.alloc(s, 1024);


SynthDef(\Onsets, {|out=0, bufnum, wbufnum, thresh=0.5, relax=1, floor=0.1, min=10, median=11|
    var sig, chain, onsets, phase;
	
	// phase = In.ar(clockIn);
	// phase = Phasor.ar(0, BufRateScale.kr(bufnum), 0, BufFrames.kr(bufnum));
	var nSamples = BufSamples.kr(bufnum);
	var duration = ( nSamples / BufSampleRate.kr(bufnum) ) * BufRateScale.kr(bufnum);
	phase = Line.ar(0, nSamples, duration, doneAction:2);
	sig = BufRd.ar(1, bufnum, phase, 1, 4);

	chain = FFT(LocalBuf(1024), sig);
    onsets = Onsets.kr(chain, thresh, \rcomplex, relax, floor, min, median);

 	SendTrig.kr(onsets, 0, phase);

	Logger.kr(phase, onsets, wbufnum);
	
	Out.ar(out,
		Pan2.ar(sig, 0);	
	);
}).send(s);

x.free;

x = Synth(\Onsets, [\bufnum, b, \wbufnum, c, \thresh, 0.1, \min, 7, \relax, 1, \floor, 0.17]);
x.free

c.getn(0, 1024, {|msg| msg.postln});
x.set(\trig, 1);

o = OSCresponderNode(s.addr, '/tr', {|t, r, msg| 
	Synth(\beep, [\freq, 440, \amp, 0.2, \pan, 0, \out, 0]);
}).add

x.set(\imp, 100);
x.free
o.action_({})

BufWr.ar()
DiskOut

BufDelayC
Trig
PV_MagBuffer
Count

PulseDivider

T2A
DC


MP3
Buffer

getn
getn
loadToFloatArray(index, count, action)

Score

Quarks.gui

FeatureSave

Array
f = File.open("/Applications/SuperCollider/testfile2.data", "r")

f.readAllString.postln;

SCMIR

Quarks.gui