rp = 1;          
rs = 60;       
f = [0.2 0.3];   
a = [1 0];       
dev = [(10^(rp/20)-1)/(10^(rp/20)+1)  10^(-rs/20)];  
[n,fo,ao,w] = firpmord(f,a,dev) ;
b = firpm(n,fo,ao,w); 
n=length(b);
b=b.*blackman(n)';
fvtool(b,1);