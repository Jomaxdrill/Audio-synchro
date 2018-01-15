function [CPrime] = slidingVariance(baseSignal,signalToFix,frame_length)
%Sliding Variance, function to calculate the vector with the
%difference between the variance of the two entered signals.
%   First the variance of the signal in each frame is calculated and stored
%   for later being normalized and made a difference between the two
%   variances.
if length(baseSignal) < length(signalToFix)
    N = length(baseSignal);
else
    N = length(signalToFix);
end
framesNumber = floor(N/frame_length);
C = zeros(2,framesNumber);

baseSignal = baseSignal/max(baseSignal);
signalToFix = signalToFix/max(signalToFix);

for n = 1:framesNumber
    idx1 = ((n-1)*frame_length) + 1; 
    idx2 = idx1 + frame_length - 1;
    idx = idx1:idx2;
    A = baseSignal(idx);
    B = signalToFix(idx);
    C(1,n) = var(A);
    C(2,n) = var(B);
end

CPrime = C(1,1:end)/max(C(1,1:end))-C(2,1:end)/max(C(2,1:end)); %Array with the difference between the normalized variances.

end

