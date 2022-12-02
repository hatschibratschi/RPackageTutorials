# install.packages('soundgen')
library(soundgen)

s1 = soundgen(sylLen = 900, temperature = 0.001,
              pitch = list(time = c(0, .3, .8, 1), 
                           value = c(300, 900, 400, 1300)),
              noise = c(-40, -20), 
              subFreq = 100, subDep = 20, jitterDep = 0.5, 
              plot = TRUE, ylim = c(0, 4))
playme(s1, samplingRate = 16000)
seewave::savewav(wave = s1,f=22050,filename =  'sound/test.wav')

s2 = soundgen(nSyl = 8, sylLen = 50, pauseLen = 70, temperature = 0,
              pitch = c(368, 284), amplGlobal = c(0, -20))
# add noise so SNR decreases from 20 to 0 dB from syl1 to syl8
s2 = s2 + runif(length(s2), -10 ^ (-20 / 20), 10 ^ (-20 / 20))
# playme(s2, samplingRate = 16000)
a = segment(s2, samplingRate = 16000, plot = TRUE)
seewave::savewav(wave = s2, f=22050,filename =  'test.wav')


f0_Hz = 440
sound = sin(2 * pi * f0_Hz * (1:16000) / 16000)
# playme(sound, samplingRate = 16000)
seewave::savewav(wave = sound, f=22050,filename =  'test.wav', channel = 1)


# stereo
wave_stereo = tuneR::Wave(
  left = runif(9000, -1, 1) * 10000,
  right = runif(9000, -1, 1) * 10000,
  bit = 16, samp.rate = 4000)
getRMS(wave_stereo, stereo = 'both', plot = TRUE)$summary
tuneR::writeWave(wave_stereo, 'test.wav')
playme(wave_stereo, samplingRate = 16000)
