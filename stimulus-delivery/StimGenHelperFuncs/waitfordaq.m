function waitfordaq()
    s = daq.createSession('ni');
    s.IsContinuous = true;
    ch = addAnalogInputChannel(s,'Dev3', 'ai0', 'Voltage');
    ch.TerminalConfig = 'SingleEnded';
    s.Rate = 10000;
    s.NotifyWhenDataAvailableExceeds = 10;
    lh = addlistener(s, 'DataAvailable', @checkThresh);
    global h;
    h = 1;
    startBackground(s);
    while(h)
        pause(0.0001);
    end
    stop(s);
    delete(s);
end






function checkThresh(src, event)
    %hold on
    %plot(event.TimeStamps, event.Data);
    %disp(event.Data);
    global h;
    if any(event.Data > 2)
        h = 0;
        %plot(event.TimeStamps, event.Data);
    end
end