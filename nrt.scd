(
~filepath = "sounds/drumLoop.wav";
~scmir = SCMIRAudioFile(~filepath);


w = SCWindow.new("soundfile test", Rect(20, 200, 900, 400)).front;
~sfViewOffset = 20;
~sfViewHeight = 200;
~sfViewWidth = 800;
~sfView = SCSoundFileView.new(w, Rect(~sfViewOffset,~sfViewOffset, ~sfViewWidth, ~sfViewHeight));
~sfView.gridOn = false;
~sfile = SoundFile.new;
~sfile.openRead(~filepath);
~sfView.soundfile = ~sfile;
~sfView.read(0, ~sfile.numFrames);

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

~drawlines = {
    w.drawHook_({|v|
        Pen.strokeColor = Color.red;
        Pen.width = 2;

        ~scmir.onsetdata.do { |item, i|
            var x = ~sfViewOffset + ((item/~scmir.duration) * ~sfViewWidth);
            Pen.moveTo(x@~sfViewOffset);
            Pen.lineTo(x@(~sfViewHeight + ~sfViewOffset));        
        };

        Pen.fillStroke;
    });
    w.refresh;
       
};

)