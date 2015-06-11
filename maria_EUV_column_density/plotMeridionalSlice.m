%makeGrid;
fillGridConstant;
%fillGridDiff;
clf;
h_ax = gca;
%imagesc( xx, yy, log10(ne), [-2 5]);
imagesc( xx, yy, log10(ne), [1 4.0] );
axis image;
axis xy;
hold on;

h_c = colorbar;
axes(h_c);
ylabel('Electron Number Density, cm^{-3}');


axes(h_ax);

% DRAW DIPOLE FIELD LINES
L = [2:7 ];
if(1)
for( k = 1:length(L) )  
    lambda = linspace(-pi/2, pi/2, 300);
    r = L(k).*cos(lambda).^2;
    B_x = r.*cos(lambda);
    B_z = r.*sin(lambda);
    h_flr(k) = plot(B_x, B_z, 'w--');
end;
end;

% DRAW EARTH CIRCLE
theta = deg2rad([-90:1:90]);
%h_n = patch( 1.04*cos(theta), 1.04*sin(theta), 'w' );
h_n = patch( cos(theta), sin(theta), 'w' );




