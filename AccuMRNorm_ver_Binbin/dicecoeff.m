%% calculating the dice coefficient
% october 2020

function dicecoeff(rnormmbi,rtempbi)

% read data
im1 = spm_vol(rnormmbi);
im2 = spm_vol(rtempbi);

i1 = spm_read_vols(im1);
i2 = spm_read_vols(im2);

% calculate coefficient & display solution
inter = sum(sum(sum(min(i1,i2)) ) ); 
s1 = sum(i1(:));
s2 = sum(i2(:));

d = (2*inter) / (s1 + s2);
%fprintf('Dice coefficient of %s and %s is %f\n',im1.fname, im2.fname, d);

assignin('base','dicecoef',d)
save('dice_coefficient.mat','d')

end
