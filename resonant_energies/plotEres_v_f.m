% Plot resonant energy vs. frequency

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id$

[ne, L]= ca92(6, 5);
f = 0.35;
m_resonance = 1; % 0 = Landau (damping), 1 = cyclotron (generation)

for( k = 1:length(L) )
  Eres(k) = calcEres_LC(L(k), 0, f, ne(k), m_resonance );
end;

figure;

subplot(2,1,1);
plot( L, ne, 'LineWidth', 2 );
set(gca, 'Yscale', 'log');
grid on;
xlabel('L');
ylabel('Ne, cm^{-3}');
title('Cold Plasma Density - CA92');
xlim([2 6]);

subplot(2,1,2);
semilogy( L, Eres, 'LineWidth', 2 );
grid on;
xlabel('L');
ylabel('Eres par, keV');
title(sprintf('Resonant Energy (m=%d), keV', m_resonance));
xlim([2 6]);

