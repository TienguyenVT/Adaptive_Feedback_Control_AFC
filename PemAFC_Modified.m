function [e,AF,AR] = PemAFC_Modified(Mic,Ls,AF,AR,UpdateFC)
%
%function [e,AF,AR] = PemAFC(Mic,Ls,AF,AR,UpdateFC,RemoveDC)
%  
%Update equation of time-domain LMS-based implementation of PEM-based
%adaptive feedback canceller
%
%INPUTS:
% * Mic = microphone sample
% * Ls  = loudspeaker sample
% * AF  = time-domain LMS-based feedback canceller and its properties
%          -AF.wTD: time-domain filter coefficients (dimensions: AF.N x 1)  
%          -AF.N  : time-domain filter length
%          -AF.mu : stepsize
%          -AF.p  : power in step-size normalization
%          -AF.lambda: weighing factor for power computation
%          -AF.TDLLs: time-delay line of loudspeaker samples
%          (dimensions: AF.N x 1)
%          -AF.TDLLswh: time-delay line of pre-whitened loudspeaker
%          samples (dimensions: AF.N x 1)
%
% * AR        = auto-regressive model and its properties
%                -AR.w           : coefficients of previous AR-model
%                -AR.N           : filter length AR model (Note: N=Nh+1)
%                -AR.framelength : framelength on which AR model is estimated
%                -AR.TDLMicdelay : time-delay line of microphone samples
%                                  (dimensions: AR.framelength+1 x 1)
%                -AR.TDLLsdelay  : time-delay line of loudspeaker samples
%                                  (dimensions: AR.framelength+1 x 1)
%                -AR.TDLMicwh    : time-delay line of pre-whitened
%                                  microphone signal
%                                  (dimensions: AR.N x 1)
%                -AR.TDLLswh     : time-delay line of pre-whitened
%                                  loudspeaker signal
%                                  (dimensions: AR.N x 1)
%                -AR.frame       : frame of AR.framelength error signals
%                                  on which AR model is computed  
%                -AR.frameindex
% * UpdateFC = boolean that indicates whether or not the feedback canceller should be updated 
%                    (1 = update feedback canceller; 0 = do not update feedback canceller)  
% * RemoveDC   = boolean that indicates whether or not the DC component of the estimated feedback path should be removed 
%                    (1 = remove DC of feedback canceller; 0 = do not remove DC of feedback canceller)  
%OUTPUTS:
% * e          = feedback-compensated signal 
% * AR         = updated AR-model and its properties
% * AF         = updated feedback canceller and its properties 
%
%
%
%Date: December, 2007  
%Copyright: (c) 2007 by Ann Spriet
%e-mail: ann.spriet@esat.kuleuven.be

delta = 1e-10;
AF.TDLLs = [Ls;AF.TDLLs(1:end-1,1)];
e     = Mic - AF.gTD'*AF.TDLLs;

e = 2*tanh(0.5*e);              % clip the error signal by tanh function

%Delay microphone and loudspeaker signal by framelength
[Micdelay,AR.TDLMicdelay] = DelaySample(Mic,AR.framelength,AR.TDLMicdelay); 
[Lsdelay,AR.TDLLsdelay] = DelaySample(Ls,AR.framelength,AR.TDLLsdelay);

% Filter microphone and loudspeaker signal with AR-model
[Micwh,AR.TDLMicwh] = FilterSample(Micdelay,AR.w,AR.TDLMicwh);
[Lswh,AR.TDLLswh]   = FilterSample(Lsdelay,AR.w,AR.TDLLswh);

%Update AR-model  
AR.frame = [e;AR.frame(1:AR.framelength-1)];
     
if and(AR.frameindex == AR.framelength-1,AR.N-1>0)
  R = zeros(AR.N,1);
  for j = 1:AR.N
     R(j,1) = (AR.frame'*[AR.frame(j:length(AR.frame)); zeros(j-1,1)])/AR.framelength;
  end
  [a,Ep] = levinson(R,AR.N-1);
  AR.w = a';
end

AR.frameindex = AR.frameindex+1;
      
if AR.frameindex == AR.framelength
  AR.frameindex = 0;
end

AF.TDLLswh = [Lswh;AF.TDLLswh(1:end-1,1)];
ep = Micwh - AF.gTD'*AF.TDLLswh;

if UpdateFC == 1

AF.gTD = AF.gTD + (AF.mu/(norm(AF.TDLLswh)^2+delta))*AF.TDLLswh.*ep;

% Remove DC
AF.gTD = AF.gTD - mean(AF.gTD);
end