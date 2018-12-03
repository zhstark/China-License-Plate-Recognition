function bw_fir=projection(imane_bw)

X_yuzhi=1;
[y,x]=size(imane_bw);
Y_touying=(sum((~imane_bw)'))';
X_touying=sum((~imane_bw));


Y_up=fix(y/2);
Y_yuzhi = mean( Y_touying( (fix(y/2)-10) : (fix(y/2)+10) ,1 ) )/1.6;
while((Y_touying(Y_up,1)>=Y_yuzhi)&&(Y_up>1))
    Y_up=Y_up-1;
end
Y_down=fix(y/2);
while((Y_touying(Y_down,1)>=Y_yuzhi)&&(Y_down<y))
    Y_down=Y_down+1;
end

X_right=1;


if(X_touying(1,fix(x/14)))<=X_yuzhi
    X_right=fix(x/14);
end

bw_fir=imane_bw(Y_up:Y_down,X_right:x);