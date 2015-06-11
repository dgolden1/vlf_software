% Plot the photon cross-section
global me clight ech
if isempty(me)
    loadconstants
end
Eph=logspace(log10(5),log10(20000));
mc2=me*clight^2/ech/1000; % in keV
k0=Eph/mc2;
%k0=[.01:.01:100];
Zatm=[7 8 18];
fracatm=[.795 .2 .005];
natatm=[2 2 1];
natm=3;
sigphe=0; sigcompton=0; sigpair=0; Zm=0;
for iatm=1:3
    sigphe=sigphe+photoeffect(k0,Zatm(iatm))*fracatm(iatm)*natatm(iatm);
    sigcompton=sigcompton+Zatm(iatm)*fracatm(iatm)*natatm(iatm)*compton(k0);
    sigpair=sigpair+pairproduction(k0,Zatm(iatm))*fracatm(iatm)*natatm(iatm);
    Zm=Zm+Zatm(iatm)*fracatm(iatm)*natatm(iatm);
end
Zm
sigtot=sigphe+sigcompton+sigpair;
loglog(Eph,[sigphe ; sigcompton ;  sigpair ; sigtot],'linewidth',2);
set(gca,'fontsize',14);
legend('Photoeffect','Comton','Pair production','Total');
grid on
xlabel('Photon energy, keV');
ylabel('Cross-section, m^2');
title('\gamma-photon cross-sections');
set(gca,'ylim',[1e-29 1e-24])
