function daq_out_trigger()
s = daq.createSession('ni');
ch = addAnalogOutputChannel(s,'Dev3','ao0','Voltage');
outputSingleScan(s,5);
pause(0.001) %1ms pause
outputSingleScan(s,0);

end

 