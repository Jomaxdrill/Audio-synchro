function [retards] = driftLags(baseSignal,toFixSignal,resolution,F0)
%DRIFT function to find the systematic retard between two audio signals to
%be synchronized.
%   Taking both signals, on the total time of the base signal the
%   correlation is calculated on N = resolution points equally distribuited
%   on the signal, this to generate an array of length N with the report of
%   lag between both signals.
n = length(baseSignal);
frameLength = floor(F0*2) ; %Two seconds of the signals to calculate cross correlation.
retards = zeros(2,resolution);
for i = 1:resolution
    idx = floor(n/resolution)*(i-1);
    idx1 = baseSignal(idx+1:idx+frameLength-1);
    idx2 = toFixSignal(idx+1:idx+frameLength-1);
    
    [cor,lags] = xcorr(idx1,idx2);
    [maxi,delayIdx] = max(abs(cor));%get maximum peak of correlation function
    lagDiff = lags(delayIdx); %get the  max delay in lags array.
    retards(1,i) = lagDiff;
    retards(2,i) = idx;
end

end

