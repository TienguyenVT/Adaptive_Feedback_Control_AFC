function [output,delayline_out] = FilterSample(x,w,delayline_in);
% 
% Sample x is filtered with filter w. If x has multiple columns,
% each column of x is filtered with w. If w has multiple colums,
% the data x is filtered with both columns of w.
%
% Inputs:
%   x             = input data (Dimensions:1xnr_channels)
%   w             = time-domain filter coefficients (Dimensions:filterlength x nr_filters)
%   delayline_in  = input delayline (Dimensions:filterlength x nr_channels)
% Outputs:  
%   output        = output data (Dimensions: 1 x max(nr_channels,nr_filters)
%   delayline_out = output delayline
% 
%Date: December, 2007  
%Copyright: (c) 2007 by Ann Spriet
%e-mail: ann.spriet@esat.kuleuven.be   

tmp = size(x);
nr_channels=tmp(2);
tmp = size(w);
nr_filters=tmp(2);

if and(nr_filters>1,nr_channels>1);
  error('Nr_channels and nr_filters cannot be both larger than 1');
end

delayline_out = [x;delayline_in(1:end-1,:)];

if nr_channels>1
  output = w'*delayline_out;
else
  output = delayline_out'*w;
end