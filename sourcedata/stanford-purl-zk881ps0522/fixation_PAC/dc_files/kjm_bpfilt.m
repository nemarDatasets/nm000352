function [] = kjm_bpfilt(band, samplerate)
% function [] = kjm_bpfilt(band, samplerate)
% This is Kai's ugly default bandpass - by default, separates them by 2 hz.
% jacked from filter design toolbox




A_stop1 = 60;  % Attenuation in the first stopband = 60 dB
F_stop1 = band(1)-2;  % Edge of the stopband in Hz
F_pass1 = band(1); % Edge of the passband in Hz
F_pass2 = band(2); % Closing edge of the passband in Hz
F_stop2 = band(2)-2; % Edge of the second stopband in Hz
A_stop2 = 60;  % Attenuation in the second stopband in Hz
A_pass = 1;  % Amount of ripple allowed in the passband in Hz




BandPassSpecObj = ...
   fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
  F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, ...
  A_stop2, samplerate);


