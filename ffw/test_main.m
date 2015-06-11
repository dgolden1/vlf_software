clc;clear;
% Load execution times for:
% FFTrv FFT execution times for real 1D vectors
% FFTiv FFT execution times for complex 1D vectors
% IFFTiv IFFT execution times for complex 1D vectors
% These times have been calculated with the script provatempo2.m 
% from length N = 3 up to length N = 2048.
% A finer determination of such times can be done using PAPI for Matlab
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=5445&objectType=File
% or http://icl.cs.utk.edu/papi/
load fftexecutiontimes
%--------------------------------------------------------------------------
%------------------------------------------------------ FAST 2D CONVOLUTION
% Two arbitrary 2D matrices
a = rand(234,222);
b = rand(222,333);
% Add a complex part
% a=a+i*rand(size(a));
% b=b+i*rand(size(b));
 
% Optimized parameters for 2D convolution
opt = detbestlength2(FFTrv,FFTiv,IFFTiv,size(a),size(b),isreal(a),isreal(b));

tic;
y0  = fftolamopt2(a,b,opt);
t   = toc;
% equivalent to do y0 = conv2(a,b,'full');
% Another example
% y1 = fftolamopt2(a,b,opt,'same');
% equivalent to do y1 = conv2(a,b,'same');
disp('Time required for fast 2D convolution');
disp(t);
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%-------------------------------------------------------- FAST 2D FILTERING
I = imread('board.tif');
I = rgb2gray(I);
I = double(I);

% If the kernel filter is too small it is convenient to work in time domain, 
% without any FFT!
myfilter = rand(60,50);
tic;
If       = filter2(myfilter,I,'same');
t0       = toc;

% Rot90 of myfilter to make results consistent
mf       = fliplr(flipud(myfilter));
% equivalent to do mf = rot90(myfilter);

% Optimized parameters for 2D filtering
opt      = detbestlength2(FFTrv,FFTiv,IFFTiv,size(I),size(mf),isreal(I),isreal(mf));
tic;
If1      = fftolamopt2(I,mf,opt,'same');
t1       = toc;

disp('Time required by filter2');
disp(t0);
disp('Time required by fftolamopt2');
disp(t1);
disp('Max abs error');
disp(max(max(abs(If-If1))));
%--------------------------------------------------------------------------
%---------------------------------------- FAST NORMALIZED CROSS-CORRELATION
% This function can easily be used also for a fast 
% normalized cross-correlation.
% See normxcorr2 function (Matlab Image Processing Toolbox) for more details.
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------






