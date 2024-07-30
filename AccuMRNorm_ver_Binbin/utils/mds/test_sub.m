function dS_dx = test_sub(M,dS_dx,gdist,x,hat_dist_x)

for m = 1:M
  r = gdist(m,2); s = gdist(m,3);
  v = (x(r,:)-x(s,:)) * hat_dist_x(m);
  dS_dx(r,:) = dS_dx(r,:) + v;
  dS_dx(s,:) = dS_dx(s,:) - v;
end
