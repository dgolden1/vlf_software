N = 1024;

FS = 4000;
frequencies = [ 697, 770, 852, 941, 1209, 1336, 1477, 1633 ];

hilbert_l = 51;
hilbert_coeff = remez (hilbert_l-1, [.05 .95], [1 1], 'Hilbert');
delay_coeff = zeros(1,hilbert_l);
delay_coeff(ceil(hilbert_l/2)) = 1;

n = [1:1:1024];
x = sin ((2*pi*n.^2)/FS);

index = 1;
plotgrid = [];
xaxis = [];

trees = {};
% Wavelet Decomposition
trees{1} = [1 0; 2 0; 3 0; 4 0; 5 0; 6 0; 7 0; 8 0];
% Level Basis, Maximum Tree Depth
trees{2} = buildtree (floor(log2(N)));
% Level Basis, Gabor-like Decomposition
trees{3} = buildtree (floor(log2(sqrt(N))));
% Custom Decomposition
trees{4} = buildtree_sparse (6, 2*frequencies/FS);

titles = {'Wavelet Decomposition',  ...
          'Level Basis, Maximum Tree Depth', ...
          'Level Basis, Gabor-like Decomposition', ...
          'Custom Decomposition'};

for tree_i = [1:1:4];
  tree = trees{tree_i};

  %# Compute the transform of the real part of the analytic signal.
  [coeffs1, lengths, depths] = ...
      wavelet_packet_decomp(filter(delay_coeff, [1], x), ...
                            tree, 'haar', 20, 'per');
  %# Compute the transform of the imaginary part of the analytic signal.
  [coeffs2, lengths, depths] = ...
      wavelet_packet_decomp(filter(hilbert_coeff, [1], x), ...
                            tree, 'haar', 20, 'per');
  %# Compute the magnitude of the resultant transform
  coeffs = sqrt (coeffs1.^2 + coeffs2.^2);
  
  plotgrid = grid_wavelet_packet(coeffs, lengths, depths);
  size(plotgrid);
  %#  plotgrid = [coeffs];
  
  %#    xaxis = [xaxis, index/FS];
  
  yaxis = [0:FS/(2*size(plotgrid,1)-1):FS/2];
  
  xaxis = [1:1:size(plotgrid,2)];
  
  subplot (2,2,tree_i);
  imagesc(xaxis, yaxis, abs(flipud(plotgrid)));
  
  axis('xy');
  colormap(flipud(gray));
  
  title (titles{tree_i});
  xlabel ('n');
  ylabel ('Frequency (Hz)');
end;
