%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PEM_TDfeedback_Modified.m
% Example file for using the time-domain implementation of the
% PemAFC-based feedback cancellation algorithm
% Modified by Linh Tran based on Ann Spriet's code 
% Date: Dec 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;
% addpath('data_file');
% addpath('CommonFunc\TD');
% % addpath('TM-AFC\Recordings\Speech');
% addpath('CommonFunc');
% addpath('CommonFunc\Obj_estimate');
% addpath('feedback cancellation_S');

%% Set Variables
prob_sig = 0;         % select among 0) without probe signal, 1)with probe signal as a white noise 
in_sig = 2;           % 0) white noise, 1) speech weighted noise, 2) real speech, 3) music

fs = 16000;          % sampling frequency
N = 80*fs;            % total number of samples

Kdb = 30;             % gain of forward path in dB
K = 10^(Kdb/20);        
d_k = 96;             % delay of the forward path K(q) in samples 
d_fb = 1;            % delay of the feedback cancellation path in samples
Lg_hat = 64;          % the full length of adaptive filter
SNR = 25;               % amplified signal to injected noise ratio

% Fixed Stepsize
    mu = 0.001;         % fixed step size

% performance parameters
MIS = zeros(N,1);
MSG = zeros(N,1);
ASG = zeros(N,1);

%%%%%%%%%%%%%%%%%%%%%%%%%
%Settings Feedback path %
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Feedback path
% %    % Measured feedback path_no obstacle placed near the ear         
% %       load Int_NormalFit_g1      % length = 21
% %       g = [Int_NormalFit_g1];      
% %       g = g - mean(g);        % remove DC value in feedback path  
% %       g = [zeros(d_fb,1);g(1:end);zeros(1,1)];
% %       Lg = length(g);           % the length of true feedback path
% %       Nfreq = 128;
% %       G = fft(g,Nfreq);  
% %       
% %    % Measured feedback path_with a flat obstacle placed closest to the ear
% %       load Int_ObjClosest_g1
% %       gc = [Int_ObjClosest_g1];   
% %       gc = gc - mean(gc);        % remove DC value in feedback path
% %       gc = [zeros(d_fb,1);gc(1:end);zeros(1,1)];
% %       Gc = fft(gc,Nfreq);         

load('mFBPathIRs16kHz_FF.mat');
E = mFBPathIRs16kHz_FF(:,3,1,1);
g = E - mean(E);  % feedback path and remove mean value
Lg = length(g);    % length of feedback path
Nfreq = 512;
G = fft(g,Nfreq);

load('mFBPathIRs16kHz_PhoneNear.mat');
Ec = mFBPathIRs16kHz_PhoneNear(:,3,1);
gc = Ec - mean(Ec);  % feedback path and remove mean value
Gc = fft(gc,Nfreq);

 
TDLy = zeros(Lg,1);            %time-delay vector true feedback path
   
   
%%%%%%%%%%%%%%%%%%%%%%%%%
%Settings desired signal%
%%%%%%%%%%%%%%%%%%%%%%%%%
%% Desired Signal (incoming signal)

 if in_sig == 0     
    % 0) incoming signal is a white noise
    Var_noise =0.001;
    input = sqrt(Var_noise)*randn(N,1);
 elseif in_sig == 1
    % 1) incoming signal is a synthesized speech
    Var = 1;
    h_den = [1;-2*0.96*cos(3000*2*pi/15750);0.96^2];
    v = sqrt(Var)*randn(N,1);     % v[k] is white noise with variance one
    input = filter(1,h_den,v);        % speech weighted noise 
 elseif in_sig == 2
    
     % 2) incoming signal is a real speech segment from NOIZEUS
    load('HeadMid2_Speech_Vol095_0dgs_m1.mat')
    input = HeadMid2_Speech_Vol095_0dgs_m1(1:N,1);    

 else
    % 3) incoming signal is a music 
    load('HeadMid2_Music_Vol095_0dgs_m1');      
    input1 = HeadMid2_Music_Vol095_0dgs_m1;
    input = input1(16000:end);  
 end   
 
    input = input./max(abs(input));
    ff = fir1(64,[.025],'high');    
    u_ = filter(ff,1,input);    
 
u = zeros(N,1); 
for n = 1 : N
    % loop through input signal
    if n <= length(u_)
        u(n) = u_(n);
    else
        u(n) = u_(rem(n,length(u_))+1,1);
    end  
end 
% u = u1; 
 
%%%%%%%%%%%%%%%%%%%%%%%%%
%Settings Probe signal  %
%%%%%%%%%%%%%%%%%%%%%%%%%
%% Probe signal w(k)
    Var_P = 0.001;
    if prob_sig == 1
        w = sqrt(Var_P)*randn(N,1);   % w[k] is a white noise;        
    else                            % With probe signal as a white noise        
        w = zeros(N,1);               % Without probe signal
    end
    
 % SNR
    if prob_sig == 1
        estKu = K * u;
        factor = SNRFactor(estKu,w,SNR);
        u = factor * u;
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-whitening filter  %
%%%%%%%%%%%%%%%%%%%%%%%%%
     
La = 20;
framelength= 0.01*fs;
[AF,AR] = PemAFCinit(Lg_hat,mu,La,framelength);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialisation data vectors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

y = zeros(N,1);         % loudspeaker signal
e_delay = zeros(N+d_k,1);
y_delayfb = zeros(N+d_fb,1);
m = zeros(N,1);         % received microphone signal

%%%%%%%%%%%%%%%%%%%%%%%%%
% PEM lattice algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 2:N 
    % Change the feedback path at sample N/2

    if k == N/2
       g = gc;       
       G = Gc; 
    end
    
     y(k) = K*e_delay(k) + w(k);

     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     % Simulated feedback path: computation of microphone signal
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
      TDLy = [y(k);TDLy(1:end-1,1)];
      m(k) = u(k) + g'*TDLy;        %received microphone signal
     
      y_delayfb(k+d_fb) = y(k);     
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      %Feedback cancellation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [e_delay(k+d_k),AF,AR] = PemAFC_Modified(m(k),y_delayfb(k),AF,AR,1);  

  
 %  Misalignment of the PEM-AFC
    g_hat = [zeros(d_fb,1);AF.gTD];
                
    G_hat = fft(g_hat,Nfreq);    
    G_tilde = G(1:ceil(Nfreq/2))-G_hat(1:ceil(Nfreq/2));
    
    % Misalignment
    MIS(k) = 20*log10(norm(G_tilde)/norm(G(1:ceil(Nfreq/2))));
    
    % Maximum Stable Gain (MSG)    
    MSG(k) = 20*log10(min(1./abs(G_tilde)));    
    
    % Added Stable Gain (ASG)
    ASG(k) = MSG(k) - 20*log10(min(1./abs(G(1:Nfreq/2+1)))); 
    
    if mod(k/N*100, 2) == 0, 
        [num2str(k/N*100) '%'],
    t = linspace(0,(N-1)/fs,N);
    
figure(1);plot(t,MIS);
xlabel('Time [s]');
ylabel('MIS [dB]');grid on
% title('Misalignment');
drawnow;

figure(2);plot(t,MSG);
xlabel('Time [s]');
ylabel('MSG [dB]');
title('maximum stable gain');grid on
drawnow;

figure(3);plot(t,ASG);
xlabel('Time [s]');
ylabel('ASG [dB]'); grid on
title('added stable gain');grid on
drawnow;

figure(4);plot(g);hold on;plot(g_hat,'r');grid on;hold off

figure(5);plot(t,y); grid on; 
xlabel('Time [s]');
ylabel('Amplitude');
legend ('PEM-NLMS');
drawnow;

    end
end

% Average values of MIS, MSG, ASG
aveMis = mean(MIS)
aveMSG = mean(MSG)
aveASG = mean(ASG)




