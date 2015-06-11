function [x] = rk4(f,t,x,dt)
  % Integrate in time using rk4
  % x' = f(t,x)
  k1 = dt*f(t,x);
  k2 = dt*f(t+1/2*dt,x+1/2*k1);
  k3 = dt*f(t+1/2*dt,x+1/2*k2);
  k4 = dt*f(t+dt,x+k3);
  x = x + 1/6*(k1+2*k2+2*k3+k4);
