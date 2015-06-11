function [mags,angles,ecc,F,T,F_RA,T_RA,S_RA,theta] = specgramRA_cmplx(z,nfft,Fs,window,noverlap)
%syntax: [mags,angles,ecc,F,T,F_RA,T_RA,S_RA,theta] = specgramRA_cmplx(z,nfft,Fs,window,noverlap)
%Outputs go from frequency Fs/NFFT to (NFFT/2-1)*Fs/NFFT in increments of
%Fs/NFFT.
%
%z is a complex number
%
%outputs:
%mags: sum of magnitude of paired pos and neg freq
%angles: angle of paired pos and neg freq
%ecc: eccentricity of paired pos and neg freq
%F: regular frequency vector, excluding DC and Fs/2 (can't have azimuth)
%T: regular time grid
%F_RA: reassigned frequency mesh (matrix) - determined by weighted convex
%mixture of reassigned pos and neg freqs
%T_RA: reassigned frequency mesh (matrix)
%S_RA: regular reassigned grid squared magnitude (squared quantity)
%theta: regular reassigned grid azimuth
%
%No scaling is performed on mags - do it in calling function (divide by
%sum(window) only, no factor of 2 needed)
%
%--- Ryan Said, 8/3/2006 ---

[Z,F_vec,T_vec,rfZ,rtZ] = specgramRA(z,nfft,Fs,window,noverlap,1);
angles = mod180(((angle(Z(2:nfft/2,:)) + angle(Z(nfft:-1:nfft/2+2,:)))/2)*180/pi)*pi/180; %[rad]
mags = (abs(Z(2:nfft/2,:)) + abs(Z(nfft:-1:nfft/2+2,:)));
mm = abs(abs(Z(2:nfft/2,:)) - abs(Z(nfft:-1:nfft/2+2,:)));
ecc = sqrt(1-((mm+eps)./(mags+eps)).^2);%add eps so origin has ecc of 0 instead of NaN
F_vec = F_vec(2:nfft/2);
t_param = 1-2/pi*atan(abs(Z(nfft:-1:nfft/2+2,:))./(abs(Z(2:nfft/2,:)) + eps));
T_RA = t_param.*rtZ(2:nfft/2,:) + (1-t_param).*rtZ(nfft:-1:nfft/2+2,:); %convex mixture
F_RA = t_param.*rfZ(2:nfft/2,:) + (1-t_param).*(Fs-rfZ(nfft:-1:nfft/2+2,:));   %convex mixture

F = F_vec;
T = T_vec;

if(nargout > 6)

    thr_dB = 90; %reassign everything thr_dB dB down from max

    [rows,cols] = size(mags);
    %S_RA  = zeros(rows,cols);
    Nw = length(window);
    MAX_AVE_NUM = 11;
    phasor_mat = zeros(rows,cols,MAX_AVE_NUM);
    pointer_mat = ones(rows,cols);
    maxM = max(max(mags));
    Threshold = 10^((20*log10(maxM)-thr_dB)/20);
    %reverse index to real quantity assignment:
    time_index_RA = round((T_RA*Fs - (Nw-1)/2)/(Nw-noverlap) + 1);
    freq_index_RA = round(F_RA*nfft/Fs);%No plus one here - shifted F_RA to start at Fs/nfft, not at DC

    overflow_num = 0;
    for jj=1:cols    %cols are t, rows are f
        for ii = 1:rows %Do each time instant at the same time (cycle through rows by column)
            if abs(mags(ii,jj))>Threshold
                jj_hat = time_index_RA(ii,jj);
                jj_hat=min(max(jj_hat,1),cols);
                ii_hat= freq_index_RA(ii,jj);
                ii_hat = min(max(ii_hat,1),rows);
                %NOTE: add up squared values, not absolute values
                %S_RA(ii_hat,jj_hat)=S_RA(ii_hat,jj_hat) + mags(ii,jj)^2 ;
                phasor_mat(ii_hat,jj_hat,pointer_mat(ii_hat,jj_hat)) =  mags(ii,jj).*exp(sqrt(-1)*angles(ii,jj));
                pointer_mat(ii_hat,jj_hat) = pointer_mat(ii_hat,jj_hat,1) + 1;
                if(pointer_mat(ii_hat,jj_hat) > MAX_AVE_NUM)
                    pointer_mat(ii_hat,jj_hat) = MAX_AVE_NUM;
                    overflow_num = overflow_num + 1;
                end
            end
        end
    end;
    if(overflow_num > 0)
        disp(['Overflow # = ' num2str(overflow_num)]);
    end


    S_RA = sum(abs(phasor_mat).^2,3)./pointer_mat;

    alpha = (sum(imag(phasor_mat).^2,3) - sum(real(phasor_mat).^2,3))./...
        (2*sum(imag(phasor_mat).*real(phasor_mat),3) + eps);
    a = alpha + sqrt(1+alpha.^2);
    theta = atan(alpha - sqrt(1+alpha.^2));
    %second derivative test: for terms where this is positive, the first "a"
    %was correct (gives maximum for slope)
    d2error = (3.*a.^2 - 1).*(sum(imag(phasor_mat).^2,3) - sum(real(phasor_mat).^2,3)) ...
        - 2.*a.*(a.^2 - 3).*sum(real(phasor_mat).*imag(phasor_mat),3);
    theta(find(d2error > 0)) = atan(a(find(d2error > 0)));  %error is the minimum

end


