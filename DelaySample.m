function [output,delayline_out] = DelaySample(x,delay,delayline_in);
% Delays sample x with delay. 
%
% INPUTS:
%   x             = input data (Dimensions:1xnr_channels)
%   delay         = discrete-time delay
%   delayline_in  = input delayline (Dimensions:(delay+1)xnr_channels)
% OUTPUTS:  
%   output        =  output data (Dimensions: 1xnr_channels)
%   delayline_out = output delayline
% 
%Date: December, 2007  
%Copyright: (c) 2007 by Ann Spriet
%e-mail: ann.spriet@esat.kuleuven.be   

delayline_out = [x;delayline_in(1:end-1,:)];
output = delayline_out(delay+1,:);
