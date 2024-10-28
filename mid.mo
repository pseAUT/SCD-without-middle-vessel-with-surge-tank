function mid
	input Real a;
	input Real b;
	input Real c;
	output Real result;
	algorithm
	result :=a+b+c-min(min(a,b),c)-max(max(a,b),c);

end mid;
