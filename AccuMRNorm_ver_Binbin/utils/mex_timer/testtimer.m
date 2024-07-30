function testtimer(cmd)
  
switch (cmd)
 case { 'start' }
  mmtimer('SetTimer',1,50, 'periodic', 'fprintf(''. '');');
 case { 'kill','stop', 'end' }
  mmtimer('KillTimer',1);
 otherwise
end
