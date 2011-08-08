(
s.waitForBoot({

SynthDef(\SlicePlay) { |buf=0, out=0, start=0, end=44100, fade=0.01, rate=1, pan=0|
    var phase = Phasor.ar(0, BufRateScale.kr(buf)*rate, start, end);
    var sig = BufRd.ar(1, buf, phase, 0);
    var env = EnvGen.ar(Env.linen(fade, ((end-start)/BufSampleRate.kr(buf)) - (fade * 2), fade, 1), doneAction: 2);

    Out.ar(out,
        Pan2.ar(sig*env, pan);
    );
}.add;

~mp3path = "/Users/arthurc/Music/iTunes/iTunes Music/Jeff Buckley/Grace/10 Dream Brother.mp3";
// {
    // ~buffer = MP3.readToBuffer(s, ~mp3path, action:{
    //     var split = ~buffer.path.split($.);
    //     ~tmpPath = split[0] ++ "z." ++ split[1];
    //     ("cp" + ~buffer.path + ~tmpPath).systemCmd;
    // });
    // s.sync;
    // ~filepath = ~tmpPath;
    // 
    // ~scmir = SCMIRAudioFile(~filepath, [[Tartini]]);
    // s.sync;
    // ~sfile = SoundFile.new;
    // ~sfile.openRead(~filepath);
    // s.sync;
    
    ~filepath = "/Applications/SuperCollider/sounds/clipperDrums.wav";
    ~buffer = Buffer.read(s, ~filepath);
    ~scmir = SCMIRAudioFile(~filepath);
    ~sfile = SoundFile.new;
    ~sfile.openRead(~filepath);
    
w = Window.new("Slice", Rect(20, 200, 900, 600)).front;
w.onClose_({
    ("rm" + ~tmpPath).unixCmd;
});
~sfViewOffset = 20;
w.view.addFlowLayout(0@0, ~sfViewOffset@~sfViewOffset);
w.view.decorator.bounds = Rect(~sfViewOffset, ~sfViewOffset, w.bounds.width-~sfViewOffset, w.bounds.height-~sfViewOffset);
~sfView = SoundFileView.new(w, w.bounds.width-(~sfViewOffset*2)@200 );
~sfView.gridOn = false;
~sfView.resize = 5;
~sfView.elasticMode = 1;
~sfView.soundfile = ~sfile;
~sfView.read(0, ~sfile.numFrames);

~compensation = 255;
~doRoutine = {|ez|
    ~routine = {
        0.2.wait;
        if(~working.not) {
            ~working = true;
            ~scmir.extractOnsets(ez.value);
            // s.sync;
            ~working = false;                     
        };
        // s.sync;
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
~working = false;



~sliderView = SCCompositeView(w, 40@200);
~slider = EZSlider(~sliderView, 
    40@200,
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


~drawlines = {
    w.drawHook_({|v|
        // Re-position slider
        ~sliderView.bounds = ~sliderView.bounds.top_(~sfView.bounds.bottom + ~sfViewOffset);
        
        // Add onset lines
        Pen.strokeColor = Color.red(1, 0.8);
        Pen.width = 1;
        
        ~scmir.onsetdata.do { |item, i|
            // Compensate for latency of Onsets
            var val = (((item * ~sfile.sampleRate) - ~compensation ) / ~sfile.sampleRate);
            var x = ~sfViewOffset + ((val / ~scmir.duration) * ~sfView.bounds.width);

            Pen.moveTo(x@~sfViewOffset);
            Pen.lineTo(x@(~sfView.bounds.height + ~sfViewOffset));        
        };

        Pen.fillStroke;
    });
    w.refresh;
       
};

~sfView.mouseDownAction_({|view, x, y, mod, but, clicks|
    var pixels, closest, closestIndex, neighbourIndex;
    var samples, selection;
    
    pixels = (~sfView.bounds.width / ~scmir.duration) * ~scmir.onsetdata;
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
        {~scmir.onsetdata.size}  {
            selection[0] = samples[closestIndex]-~compensation;
            selection[1] = ~sfile.numFrames;
            
            samples[closestIndex].postln;
        }
        {neighbourIndex} {
            selection = ([samples[closestIndex], samples[neighbourIndex]]-~compensation).sort;
        };
    // selection.postln;
    ~sfView.setSelection(0, [selection[0], selection[1] - selection[0]]);
    Synth(\SlicePlay, [\buf, ~buffer, \start, selection[0], \end, selection[1]]);
});
// }.fork(AppClock);
})

)
~drawlines.();

/*
    TODO Zooming
    TODO Removing onset markers...
    TODO Set hit duration
    TODO long file fail (kanjira.wav)
*/
