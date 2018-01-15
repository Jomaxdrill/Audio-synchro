%Elaborazione dell'audio digitale final project: Track synchronization
%Created by Jonathan Leonard Crespo Eslava and Andres Sebastian Cespedes
%Cubides
%28/12/2017
clear
close all;
%% -----------------------------------------------------------------------
%This program synchronizes two audio tracks that have been recorded in
%similar times, i.e. the audio recorded from a microphone and the audio
%recorded from the camera in the realization of a video scene.

%To achieve this, the correlation function is used, using MatLab function
%xcorr on the first instants of the tracks. In order to eliminate the
%"silences" introduced by any of the recording dispositives the variance of
%both signals is calculated and then the change is detected. Once a
%detection of a "silence" is confirmed the program calculates de
%correlation function again on the near area and synchronizes again the
%tracks by cutting off the extra part or by adding zeros on the missing
%part.
%% -----------------------------------------------------------------------
%Declaration of variables:

[y0,F0] = audioread('baseaudio.wav'); %Audio to synchronize with.
[y1,F1] = audioread('AudWAV.wav'); %Audio to fix to be syncrhonized.
downSm = 4; %Downsampling rate, 1 = no downsampling.

%-------------------------------------------------------------------------


strTime = 5*60; %First piece of time for calculating the correlation function in seconds.

y0 = downsample(y0,downSm);
y1 = downsample(y1,downSm);

% First 5 minutes each one ,F0 = 44.1kHz
t =  ((F0/downSm)*strTime); 

r0=y0(1:t);%First 5 minutes audio-video(Camera) to synchronize.
r1=y1(1:t);%First 5 minutes audio(Microphone) to synchronize.

[corr,lags]=xcorr(r0,r1);%Calculate correlation between signals

[maxi,delayIdx] = max(abs(corr));%get maximum peak of correlation function

lagDiff = lags(delayIdx); %get the  max delay in lags array.

info1 = sprintf('The number of samples to synchronize both tracks is %d with a sample rate of %d. \n',abs(lagDiff),F0/downSm);
disp(info1)


%% First synchronization (Full audio)
X2 = y1(abs(lagDiff):end);

%% Correction of the drift between the signals.
resolution = 8; 
retards = driftLags(y0,X2,resolution,F0/downSm);
pendant = retards(2,2)./(abs(retards(1,3:end))-abs(retards(1,2:resolution-1))); %size resolution-2
[min,delayIdx] = min(pendant);
pendant(delayIdx) = [];
deriva = floor(mean(pendant));
%Removing/adding the retarding samples on the track
if retards(1,2) < 0
    %The track to synchronize is getting delayed on time, some samples must
    %be removed.
    idx = (deriva:deriva:length(X2));
    X2(idx)=[];
else
    %The track to synchronize is getting beyond on time, some samples must
    %be added.
    idx = (deriva:deriva:length(X2));
    toAdd = length(idx);
    XFixedTemp = zeros(length(X2)+toAdd,1);
    XFixedTemp(deriva:deriva:length(XFixedTemp)) = 0;
    idx = 1:deriva-1;
    idxS = 1:deriva:length(XFixedTemp);
    for n = 1:floor(length(XFixedTemp)/deriva)
        idx = (n-1)*deriva+1+n:((n-1)*deriva+1+n) + deriva-1;
        XFixedTemp(((n-1)*deriva+1):((n-1)*deriva+1)+deriva-1) = X2(((n-1)*deriva+1):(n-1)*(deriva+1)+deriva);
    end
    
    
end

%% Second synchronization (Finding of "strange pieces": Silences)
%To do this the correlation function is used once more, but in order to
%find the interval in which the correlation function will be calculated the
%variance of both signals is calculated and compared by realizing a simple
%difference.
%After this the point where the difference on the variances change is where
%the program decides to calculate the correlation function in an interval
%of 2 seconds starting on the frame right before the one where the change
%was found.
%It repeats this process until the delay between the two signals is smaller
%than 0.1 seconds (A delay amount in which the human ear can detect the 
%effect).

flag = 1; %This flag will go 0 once the delay is smaller than 100 ms.
frame_length = floor((F0/downSm)*0.1);
XFixed = X2;

while flag == 1
    % Finding changes in the variance of the resulting signal.

    % Calculation of correlation between both signals in a short time
    Cprime = slidingVariance(y0,XFixed,frame_length);
    ipt = findchangepts(Cprime,'Statistic','rms'); %Find the point where the RMS value of Cprime changes.

    

    sampleN = (ipt(1)-1)*frame_length; %Find the approximate sample when the silence starts.

    r0 = y0(sampleN:sampleN+F0*2); %a vector with 2 seconds of the signal starting from the abrupt change found.
    r1 = XFixed(sampleN:sampleN+F0*2); 

    [corrS,lagS]=xcorr(r0,r1);%Calculate correlation between signals

    [maxiS,delayIdxS] = max(abs(corrS));%get maximum peak of correlation function

    lagDiffS = lagS(delayIdxS);%get the  max delay in lags array.
    
     if abs(lagDiffS)<((F0/downSm)*0.2)
        flag = 0;        %The delay  was smaller than 100ms
     else
         info2 = sprintf('The point where the "strange piece" was found is %d with a sample rate of %d. \n',ipt*frame_length,F0/downSm);
        disp(info2)
        %The delay is bigger and the audio will be re-synchronized.
        %Re-synchronization:
        if lagDiffS > 0 
            XFixed = zeros((length(X2) + abs(lagDiffS)),1);
            XFixed(1:sampleN-1) = X2(1:sampleN-1);
            XFixed(sampleN:sampleN+(abs(lagDiffS))-1) = zeros(abs(lagDiffS),1);
            idx1 = sampleN+(abs(lagDiffS)):length(XFixed);
            idx2 = sampleN:length(X2);
            XFixed(idx1) = X2(idx2);
                   
        else
            XFixed = zeros(length(y0),1);
            XFixed(1:sampleN) = X2(1:sampleN);
            idx1 = sampleN+1:length(XFixed)-1;
            idx2 = sampleN+abs(lagDiffS)+1:length(XFixed)+abs(lagDiffS)-1;
            XFixed(idx1) = X2(idx2);
            
        end
     end 
    
end
%--------------------------------------------------------------------------
%Depending on the sign of the delay we know if the base signal is behind or
%beyond the signal we are fixing. Finding the correlation between the
%original and the one to fix (in that order) we see that if lagDiffS is
%negative, the signal to fix is behind the original signal, this because of
%an "unknown piece" produced in the signal to fix. In the other case, the 
%original signal was the one introducing an "unknown piece".

%The way we choosed to fix this was to add zeros on the signal to fix
%until it was synchronized again, or cutting down the strange piece on the
%signal to fix. This because it's necessary to stick with
%the original tempo.
%--------------------------------------------------------------------------
%% Creating the resulting audio file.
audiowrite('synchro.wav',XFixed,F0/downSm);


