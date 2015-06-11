function outputsig = remove_impulses(signal,noise_centers,NUMB4,NUMAFT,pw)
% Noise_centers is the vector returned from find_impulse_locs
% NUMB4 and NUMAFT specify the number of values before and after that the
% algorith uses to model the portion in error
% pw specifies the size of the impulse to be corrected.


outputsig = signal(:).';
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
        warning('Reducing window size for AR fitting, may lose interpolation accuracy')
    elseif(c_end+numaft-1>length(signal))
        numaft = length(signal)+1-c_end;
        warning('Reducing window size for AR fitting, may lose interpolation accuracy')
    end
    
    ivec = [zeros(1,numb4) ones(1,c_end-c_start) zeros(1,numaft)];
    U=eye(numb4+numaft+(c_end-c_start));
    K = eye(numb4+numaft+(c_end-c_start));
    for p = 1:length(ivec)
        U(p,:)=U(p,:)*ivec(p);
        K(p,:)=K(p,:)*~ivec(p);
    end

  for iter = 1:3
    temp = fliplr(outputsig(c_start-numb4:c_end+numaft-1)');
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
    outputsig(c_start-numb4:c_end+numaft-1) = (K*temp+sig_ls)';
  end
end
