function bpseg = bpfilter(seg, freq, h)
% BPFILTER 2nd-order bandpass filter. 
%
% SYNTAX:
%
% bpseg = bpfilter(seg, freq)
% bpseg = bpfilter(seg, freq, h)
%
% INPUTS:
% 
% SEG can be vector or matrix. Each column is one channel.
% FREQ is the cut-off frequency. Must be in the range of [0 fn] where fn is
%      the nyquist frequency (sample rate/2). Values of freq will
%      automatically fit in the range of  0 < freq < fn if saturated.
% H is the sample frequency. Default is HDR.SampleRate in matlabs base 
% workspace or 128 if HDR does not exist in workspace. 
%
% OUTPUTS:
%
% BPSEG is the filtered signal/signals.
% 
% EXAMPLE:
%
% Bandpass filter the two EEG signals of s between 0 and 30 seconds that
% has a samplerate of 128.
% filtseg = bpfilter(s(round(1*h):round(30*h), HDR.EEG(1:2), [0.3 h/2], 128);
%
% Created by Martin Längkvist, 2012

if nargin==2
    try
        HDR=evalin('base','HDR');
        h=HDR.SampleRate;
    catch
        h=128;
    end
end

filtorder = 2;

if freq(1) > 0 && freq(2) >= h/2
    [b, a] = butter(filtorder, freq(1)*(2/h), 'high');
elseif freq(1) <= 0 && freq(2) < h/2
    [b, a] = butter(filtorder, freq(2)*(2/h), 'low');
elseif freq(1) > 0 && freq(2) < h/2
    [b, a] = butter(filtorder, freq*(2/h));
else
    disp('ERROR: Cut-off frequency');
    return
end

bpseg = filtfilt(b, a, seg);

%disp(['Filtered successfully with a: ' num2str(a) ' b: ' num2str(b)]);

end

