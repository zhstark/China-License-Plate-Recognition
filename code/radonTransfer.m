% radon transfer
function slantAngle=radonTransfer(I)

I=edge(I);

theta = 1:180;
[R,xp] = radon(I,theta);

[I,J] = find( R>=max( max(R) ) );
slantAngle=90-J;
