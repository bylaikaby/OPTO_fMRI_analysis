function p2 = getpow2(num,type)
%GETPOW2 - Get the next smaller or greater power of 2 number
%	p2 = getpow2(num,type)
%	HM, 10.10.00

if nargin < 2,
	type = 'floor';
end

n = 1;
while(1),
	num2 = 2^n;
	if (num2 > num),
		if (strcmp(type,'floor')),
			num2 = 2^(n-1);
		else
			num2 = 2^n;
		end
		break;
	end
	n = n + 1;
end

p2 = num2;
