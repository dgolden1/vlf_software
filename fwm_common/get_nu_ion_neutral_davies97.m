function nuin=get_nu_ion_neutral_davies97(h)
% From article by Davies, Lester and Robinson [1997], Ann. Geoph. 15, 1557
% Only collisions of NO+ ions are important (O+ and H+ are at high enough
% altitude so that nu_in << wH_i)
% See also: plot_collisionrate, get_nu_electron_neutral_swamy92
nuin=4.34e-16*getSpecies('N2',h)+4.28e-16*getSpecies('O2',h)+...
    2.44e-16*getSpecies('O',h);

