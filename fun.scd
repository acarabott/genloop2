(
{
    inf.do { |i|
        var index, start, end, dur;
        // index = ~scmir.onsetdata.size.rand;
        index = ~range.choose.max(0).min(~scmir.onsetdata.size);
        index.postln;
        start = (~scmir.onsetdata[index] * ~sfile.sampleRate)-~compensation;
        end = start + ((~buffer.duration/16)*~buffer.sampleRate);
        end = ((~scmir.onsetdata[index+1] ? ~scmir.duration)  * ~sfile.sampleRate)-~compensation;
        dur = (end - start) / ~sfile.sampleRate;
        
        if(~prob.coin) {
            if(0.5.coin) {
                ~rf = {|val| 1 + (val/10)};
            } {
                ~rf = {|val| 1 - (val/10)};
            };
            if(0.3.coin) {
                ~fuck = 3;
            } {
                ~fuck = 4;
            };
            ~duck = [2, 4];
            ~fuck.do { |j|
                Synth(\SlicePlay, [\buf, ~buffer, \start, start, \end, end, \rate, ~rf.(j)]);
                (~wait/~duck.choose).wait;
            };
        } {
            Synth(\SlicePlay, [\buf, ~buffer, \start, start, \end, end, \rate, 1, \pan, (-1,-0.5..1.0).choose]);
            ~wait.wait;
            // (~buffer.duration/[16].choose).wait;
        };
        
        // (dur*~durs.choose).wait;
    };
}.fork(TempoClock.default, 1);
)
100.max(0).min(6)
~prob = 0;
~wait = (1/8);
~scmir.onsetdata.size
~range = (0..~scmir.onsetdata.size/16)
~range = (0..1);
~range = [(1600..1800)].flat;
{
    inf.do { |i|
        ~range = (720..721)+~yeah.choose;
        1.wait;
    };
}.fork(TempoClock.default, 1)
TempoClock.default.tempo = 1.4

~scmir.onsetdata.do { |item, i|
    var next = ~scmir.onsetdata[i+1];
    
    if(next.notNil) {
        if((~scmir.onsetdata[i+1] - item) > 1) {
            i.postln;
        };
    };
};

Tdef(\x).play;

c = 0;
(
    Tdef(\x, {
        loop({
            var index, start, end, dur, choice;
            // index = ~scmir.onsetdata.size.rand;
            index = ~range.choose.max(0).min(~scmir.onsetdata.size-1);

            start = (~scmir.onsetdata[index] * ~sfile.sampleRate)-~compensation;
            end = ((~scmir.onsetdata[index+1] ? ~scmir.duration)  * ~sfile.sampleRate)-~compensation;
            dur = (end - start) / ~sfile.sampleRate;
            
            switch (c%8)
                {0}  {
                    Synth.before(~verb, \SlicePlay, [\buf, ~buffer, \start, ~scmir.onsetdata[9]*~sfile.sampleRate-~compensation, \end, ~scmir.onsetdata[10]*~sfile.sampleRate-~compensation, \rate, 1, \pan, 0, \out, ~drumbus]);
                    
                }
                {4}  {

                    choice = [2,3,11].wchoose([0.45,0.45,0.1]);
                    Synth.before(~verb, \SlicePlay, [\buf, ~buffer, \start, ~scmir.onsetdata[choice]*~sfile.sampleRate-~compensation, \end, ~scmir.onsetdata[choice+1]*~sfile.sampleRate-~compensation, \rate, 1, \pan, 0, \out, ~drumbus]);
                }
                {c%8} {
                    Synth.before(~verb, \SlicePlay, [\buf, ~buffer, \start, start, \end, end, \rate, 1, \pan, (-1,-0.5..1.0).choose, \out, ~drumbus]);
                };
            
            c = c + 1;
            (1/~wait).wait;
        })
    })
)

Tdef(\x).play
~wait = 6;
~range = (0..13);
~drumbus = Bus.audio(s, 1);

~verb = Synth(\DrumVerb, [\in, ~drumbus]);
~verb.set(\room, 0.7);
~verb.set(\mix, 0.7);
~verb.set(\damp, 0.9);
Synth.before(~verb, \SlicePlay, [\buf, ~buffer, \start, 0, \end, 11025, \rate, 1, \pan, (-1,-0.5..1.0).choose, \out, ~drumbus]);


SynthDef(\DrumVerb) { |in=0, out=0, mix=0.5, room=0.8, damp=0.1, mul=1, pan=0|
    var sig = In.ar(in,2);
    // var verb = FreeVerb.ar(sig, mix, room, damp, mul);
    var verb = FreeVerb2.ar(sig[0], sig[1], mix, room, damp, mul);
    Out.ar(out,
        Mix.ar([sig, verb]);
    );
}.add;

~swap.()
~swap = {}
    
~choices = []
~range = (0..13);

Tdef(\y).stop

(
    Tdef(\y, {
        loop({
            var index, start, end, dur;
            // index = ~scmir.onsetdata.size.rand;
            index = ~yrange.choose.max(0).min(~scmir.onsetdata.size);
            start = (~scmir.onsetdata[index] * ~sfile.sampleRate)-~compensation;
            end = ((~scmir.onsetdata[index+4] ? ~scmir.duration)  * ~sfile.sampleRate)-~compensation;
            dur = (end - start) / ~sfile.sampleRate;
        
            // [1,2].choose.do { |i|
                Synth(\SlicePlay, [\buf, ~buffer, \start, start, \end, end, \rate, 1, \pan, (-1,-0.5..1.0).choose]);
                1.wait;
            // };
        })
    })
)

~yrange = (560..580);