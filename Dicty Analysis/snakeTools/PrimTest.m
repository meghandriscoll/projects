function cellPrim = PrimTest(XSnake, YSnake)

% global XSnake YSnake;
% global cellPrim;

cellPrim=0;
h=0;

for i=1:1:(size(XSnake)-1);

    xp=XSnake(i+1,1)-XSnake(i,1);
    yp=YSnake(i+1,1)-YSnake(i,1);

    cellPrim= cellPrim + sqrt(xp.^2+yp.^2);

    h=h+1;
end

% add last segment to perimeter of cell

x = XSnake(1,1)-XSnake(i+1,1);
y = YSnake(1,1)-YSnake(i+1,1);
segment0 = sqrt(x.^2+y.^2);
cellPrim = cellPrim + segment0;
