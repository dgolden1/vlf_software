function outputsig = remove_impulses(full_signal, full_noise_centers, NUMB4, NUMAFT, pw)
% Noise_centers is the vector returned from find_impulse_locs
% NUMB4 and NUMAFT specify the number of values before and after that the
% algorith uses to model the portion in error
% pw specifies the size of the impulse to be corrected.

% Originally by Jeremie Papon (jpapon at gmail dot com)
% Modified by Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id$

%% Setup
poolsize = matlabpool('size');
if poolsize == 0 % If there is no open matlabpool
  poolsize = 1;
end

if rem(length(full_signal), poolsize) ~= 0
  warning('remove_impulses not tested with signal lengths that are not divisible by pool size (%d / %d)', ...
    length(full_signal), poolsize);
end

b_warnings = false; % Display warnings

%% Separate signal into chunks and loop
% Break signal into several overlapping chunks, optimized for parallel
% processing

chunksize = ceil(length(full_signal)/poolsize);
start_i = zeros(length(poolsize), 1);
end_i = zeros(length(poolsize), 1);
this_outputsig = {};

warning('Parfor disabled!');
for kk = 1:poolsize
% parfor kk = 1:poolsize
  start_i(kk) = ((kk-1)*chunksize)+1;
  end_i(kk) = kk*chunksize;
  start_i(kk) = max(start_i(kk) - NUMB4, 1);
  end_i(kk) = min(end_i(kk) + NUMAFT, length(full_signal));
  
  signal = full_signal(start_i(kk):end_i(kk));
  
  % Only choose the noise centers that appear in this chunk centers
  noise_centers = full_noise_centers(full_noise_centers >= start_i(kk) & full_noise_centers < end_i(kk));
  noise_centers = noise_centers - start_i(kk) + 1;
  
  % Process each chunk in parallel
  this_outputsig{kk} = signal(:).'; % Row vector
  for t=1:length(noise_centers)
    c_start = noise_centers(t) - floor(2*pw/5);
    c_end = noise_centers(t) + ceil(3*pw/5);

    numb4=NUMB4;
    numaft = NUMAFT;
    %Check to see if window takes us out of bounds, adjust window if so
    if(c_end>length(signal)||c_start<1)
      continue;
      warning('Impulse on edge of window, ignoring');
    end

    if(c_start-numb4<1)
      numb4 = c_start - 1;
      if b_warnings, warning('Reducing window size for AR fitting, may lose interpolation accuracy'); end
    elseif(c_end+numaft-1>length(signal))
      numaft = length(signal)+1-c_end;
      if b_warnings, warning('Reducing window size for AR fitting, may lose interpolation accuracy'); end
    end

    ivec = [zeros(1,numb4) ones(1,c_end-c_start) zeros(1,numaft)];
    U=eye(numb4+numaft+(c_end-c_start));
    K = eye(numb4+numaft+(c_end-c_start));
    for p = 1:length(ivec)
      U(p,:)=U(p,:)*ivec(p);
      K(p,:)=K(p,:)*~ivec(p);
        end

        try
            for iter = 1:3
                temp = fliplr(this_outputsig{kk}(c_start-numb4:c_end+numaft-1)');
                if(iter == 1)
                    [w,a,sbc,fpe] = arfit(temp(1:numb4),15,15,'zero');
                else
                    [w,a,sbc,fpe] = arfit(temp,15,15,'zero');
                end
                %make excitation matrix
                P= length(a);
                N = length(temp);
                arev = -1*fliplr(a);
                A = zeros(N-P,N);
                for k = 1:N-P
                    A(k,k:k+P) = [arev 1];
                end
                Ac = A*U;
                Auc = A*K;
                sig_ls = -1*pinv(Ac'*Ac)*Ac'*Auc*(temp'*K)';
                this_outputsig{kk}(c_start-numb4:c_end+numaft-1) = (K*temp+sig_ls)';
            end
        catch er
            if strcmp(er.identifier, 'Arfit:ShortTimeSeries')
                if b_warnings, warning(er.message); end
            else
                rethrow(er);
            end
        end
  end
end

%% Combine the chunks
outputsig = zeros(1, length(full_signal));
for kk = 1:poolsize
  if start_i(kk) == 1
    sig_start_i = 1;
  else
    sig_start_i = 1 + NUMB4;
  end
  if end_i(kk) == length(full_signal)
    sig_end_i = length(this_outputsig{kk});
  else
    sig_end_i = length(this_outputsig{kk}) - NUMAFT;
  end
  sig_len = sig_end_i - sig_start_i + 1;
  
  o_start_i = start_i(kk) + sig_start_i - 1;
  o_end_i = o_start_i + sig_len - 1;
  
  outputsig(o_start_i:o_end_i) = this_outputsig{kk}(sig_start_i:sig_end_i);
end
outputsig(end-NUMAFT+1:end) = this_outputsig{end}(end-NUMAFT+1:end);
