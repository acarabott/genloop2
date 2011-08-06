(
s.waitForBoot({
    
SynthDef(\SlicePlay) { |buf=0, out=0, start=0, end=44100, fade=0.01|
    var phase = Phasor.ar(0, BufRateScale.kr(buf), start, end);
    var sig = BufRd.ar(1, buf, phase, 0);
    var env = EnvGen.ar(Env.linen(fade, ((end-start)/BufSampleRate.kr(buf)) - (fade * 2), fade, 1), doneAction: 2);

    Out.ar(out,
        Pan2.ar(sig*env, 0);
    );
}.add;

// ~mp3path = "/Users/arthurc/Music/iTunes/iTunes\ Music/Acoustic Ladyland/Skinny\ Grin/01\ Road\ Of\ Bones.mp3";
{
    // ~buffer = MP3.readToBuffer(s, ~mp3path, action:{
    //     var split = ~buffer.path.split($.).postln;
    //     ~tmpPath = split[0] ++ "z." ++ split[1];
    //     ("cp" + ~buffer.path + ~tmpPath).unixCmd;
    // });
    // s.sync;
    // ~filepath = ~tmpPath;
    // 
    // ~scmir = SCMIRAudioFile(~filepath);
    // s.sync;
    // ~sfile = SoundFile.new;
    // ~sfile.openRead(~filepath);
    // s.sync;
    
    ~filepath = "sounds/amen.wav";
    ~buffer = Buffer.read(s, ~filepath);
    ~scmir = SCMIRAudioFile(~filepath);
    ~sfile = SoundFile.new;
    ~sfile.openRead(~filepath);
    
w = Window.new("Slice", Rect(20, 200, 900, 400)).front;
// w.onClose_({
//     ("rm" + ~tmpPath).unixCmd;
// });
~sfViewOffset = 20;
~sfViewHeight = 200;
~sfViewWidth = 800;
~sfView = SoundFileView.new(w, Rect(~sfViewOffset,~sfViewOffset, ~sfViewWidth, ~sfViewHeight));
~sfView.gridOn = false;
~sfView.soundfile = ~sfile;
~sfView.read(0, ~sfile.numFrames);

~compensation = 255;
~doRoutine = {|ez|
    ~routine = {
        0.2.wait;
        if(~working.not) {
            ~working = true;
            ~scmir.extractOnsets(ez.value);
            ~working = false;                     
        };
        ~drawlines.();
            
    }.fork(AppClock);
};

~checkWorking = {|ez|
    {
        if(~working) {
            0.1.wait;
            ~checkWorking.(ez);
        } {
            ~routine.stop;
            ~doRoutine.(ez);
        };
    }.fork;
    
};

~slider = EZSlider(w, 
    Rect(840, 20, 40, 200), 
    "Thresh",
    action: {|ez|
        
        if(~routine.isPlaying) {
            ~checkWorking.(ez);
        };
        ~doRoutine.(ez);
        
    },
    initVal:0.5,
    initAction:true,
    layout:\vert
);
~working = false;

~pixels;
~drawlines = {
    w.drawHook_({|v|
        Pen.strokeColor = Color.red;
        Pen.width = 2;
        
        ~scmir.onsetdata.do { |item, i|
            // Compensate for latency of Onsets
            var val = (((item * ~sfile.sampleRate) - ~compensation ) / ~sfile.sampleRate);
            var x = ~sfViewOffset + ((val / ~scmir.duration) * ~sfViewWidth);

            Pen.moveTo(x@~sfViewOffset);
            Pen.lineTo(x@(~sfViewHeight + ~sfViewOffset));        
        };

        Pen.fillStroke;
    });
    w.refresh;
       
};

~sfView.mouseDownAction_({|view, x, y, mod, but, clicks|
    var pixels, closest, closestIndex, neighbourIndex;
    var samples, selection;
    
    pixels = (~sfViewWidth / ~scmir.duration) * ~scmir.onsetdata;
    samples = SCMIR.soundfile.sampleRate * ~scmir.onsetdata;
    
    closest = x.nearestInList(pixels);
    closestIndex = pixels.indexOf(closest);
    selection = Array.newClear(2);
    
    if(x > closest) {
        neighbourIndex = closestIndex + 1;
    } {
        neighbourIndex = closestIndex - 1;
    };
    
    
    switch (neighbourIndex)
        {-1}  {
            selection[0] = 0;
            selection[1] = samples[closestIndex];            
        }
        {~scmir.onsetdata.size}  {
            selection[0] = samples[closestIndex];
            selection[1] = ~sfile.numFrames;
        }
        {neighbourIndex} {
            selection = [samples[closestIndex], samples[neighbourIndex]].sort;
        };
    
    ~sfView.setSelection(0, [selection[0], selection[1] - selection[0]]);
    Synth(\SlicePlay, [\buf, ~buffer, \start, selection[0]-~compensation, \end, selection[1]-~compensation]);
});
}.fork(AppClock);
})

)


/*
    TODO Removing onset markers...
    TODO zooming and resizing
*/

{
    inf.do { |i|
        var index, start, end, dur;
        index = ~scmir.onsetdata.size.rand;
        start = (~scmir.onsetdata[index] * ~sfile.sampleRate)-~compensation;
        end = ((~scmir.onsetdata[index+1] ? ~scmir.duration)  * ~sfile.sampleRate)-~compensation;
        dur = (end - start) / ~sfile.sampleRate;
        
        dur.postln;
        Synth(\SlicePlay, [\buf, ~buffer, \start, start, \end, end]);
        (~buffer.duration/[8,16].choose).wait;
        // (dur*~durs.choose).wait;
    };
}.fork;

(60/)

1 = 60
0.5 = 60