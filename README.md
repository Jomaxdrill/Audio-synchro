# ------Clip Alignment------- 

The following software aligns two tracks of digital audio that have been recorded at approximately the same time.
i.e. The video of a scene and the audio taken from the microphones.

The final objective is to replace a better quality audio file with the one that exists in a video.

------------------------------------------------------------------------------------------------------------------------------
What is necessary

This project has been developed so far on MatLab, the source code is to run in MatLab, therefore you will need:

-MatLab: to run the code, version  R2012b or higher is needed.

-ffmpeg or similar: this to encode/decode the audio and video to work with. Is necessary to have both audio files in WAV format, 
in order to be possible for MatLab to load them. Also to encode the result into a new video with the synchronized audio (In the 
section you can find a brief description for doing this, it can change as ffmpeg updates so it's better to read the official 
documentation).

-(Optional) Audacity or any audio editor: this to verify the correct synchronization of both tracks.

-Restrictions: 
	- The track to synchronize has to be longer than the original track, this on the beginning.
	- None of the tracks should have the name "synchro.wav", if so, it will be overwritten after the process.
	
-----------------------------------------------------------------------------------------------------------------------------
Study case

In this case, the tracks were recorded in the "Elaborazione dell'audio digitale" lesson ,
by a microphone(one to modify and replace) and video screen recorder.
Signal process tecniques as cross correlation were used to correct the disalignment and 
noise dead times.Also to control the outcome drift.

-----------------------------------------------------------------------------------------------------------------------------
Installing 
-To set up this piece of software is necessary just to put the sourcecode files along with the WAV files in a folder on the computer
  and then open MatLab to add this folder to MatLab path.
-Next step consist in updating the information on the sourcecode. For this open the code and change the first lines on the code
to make it work properly:
	- On the code there is a brief description of the method used, right after you will see two lines of code like this:

	[y0,F0] = audioread('baseaudio.wav'); %Audio to synchronize with.
	[y1,F1] = audioread('AudWAV.wav'); %Audio to fix to be syncrhonized.

   -This lines must have the name of the audio files on WAV format that you obtained before, by simply changing the name 
	  on between of the ' ' signs it's done, just paying attention to write also the format of the audio file and making sure 
	  it is on the same folder as the sourcecode.

  - Next is to set the downsampling rate, if we want the program to run faster it's possible to perform a downsampling
	  on the tracks. By changing the downSm variable, this can be achieved.

	    downSm = 1; %Downsampling rate, 1 = no downsampling.

	- 1: no downsampling.	
  - 2: half of the original frequency.
	- And so on...
  
	More than 4 on this variable however is not recommended since the audio is often at 44100 Hz reducing it more than 4 times
	would result in a very poor quality on the output.
-After this just click Run on the MatLab menu or hit F5 on the keyboard, depending on the machine that is running this will take 
some time. On the folder where everything is a new audio called synchro.wav should appear. This audio has now the same timing as the
base audio that was inserted.

-Now by using ffmpeg or a similar software you can encode the video and audio together into a new video file with the new audio.
	- For example on with ffmpeg the next line can be used:

	ffmpeg -i video.mp4 -i synchro.wav -map 0:0 -map 1:0 -c:a aac -c:v copy outVideo.mp4

 -This will use the same video on the same codec and will encode the WAV audio into aac format with the default 
  settings.

----------------------------------------------------------------------------------------------------------------------------------
Running the tests

You will have a project folder in which you can see the 3 codesources on .m format along with the files:
	-video.mp4
	-microphone.3gpp
	-AudWAV.wav
	-baseaudio.wav
In order to run the project open the file called "Audiosync.m" only the last two WAV files are necessary, their name is already 
preinserted so by just running the matlab code you will obtain the synchro.wav file. It's possible now to compare them with the
original track. Audacity is recommended.

-----------------------------------------------------------------------------------------------------------------------------------


Authors

Andres Sebastian Cespedes Cubides
Jonathan Leonard Crespo Eslava

License
MIT/X11

Acknowledgments

SERVETTI ANTONIO-Professor of Automatic & Informatics department Politecnico di Torino


---------------------------------------------------------------------------------------------------------------------------------------
Annexes

ffmpeg

If you want to replicate the project case using your own video file follow these steps:
1.It was used ffmpeg to obtain the audio part of the video ,install it according to your operative system: https://www.ffmpeg.org/download.html
2.In the folder that is obtained from the .zip archive of the download find the "ffmpeg.exe" archive ( located: ffmpeg-20171128-86cead5-win64-static\bin  )
3.Copy and paste the video file in the bin folder.
4.Open the Command prompt screen and write the path where is located the bin folder (e.g C:\Users\YourName> cd C:\User\ffmepg\bin ) 
5.Open ffmpeg (e.g C:\Users\YourName\ffmepg\bin>ffmepg)
6.Write the following example code and enter:  ffmpeg -i namevideo.mov  audio.wav
namevideo.mov  corresponds to your video file name(keep in mind the format).
This code generates a .wav file called audio.wav which has the sound of the video.
7.Copy it and the possible audio track you have to align in the folder containing the matlab code files given in this project.
8.Remember to change the names of the files or in the MatLab code if necessary.
