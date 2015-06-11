function [value,isterminal,direction]=testscript_plot_b_endevent(t,x)
  physconst
  value=sqrt(sum(x.^2))-R_E;
  isterminal=1;
  direction=0;
