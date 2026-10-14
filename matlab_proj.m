H=300;                                      % the radius will be H tan(draw)
W=198;

draw=(pi/180)*13;

r=(H*tan(draw))/10;

counter=0;

NEW=0.4;

h=4.6;

e=0.66;

sub_factor=0.33*(1+1.11*tanh(1.4*(W/H/NEW-1.8)));
                                      % for single seam extraction


[X,Y]=meshgrid(1:4:400,1:5:500);
                                      % our grid will be 100x100


%X=X(:);
%Y=Y(:);
%plot(X,Y,'b.');


x1=[100,100];                          % panel coordinates
x2=[298,100];
x3=[298,394];
x4=[100,394];


x_co=[x1(1),x2(1),x3(1),x4(1),x1(1)];

y_co=[x1(2),x2(2),x3(2),x4(2),x1(2)];


panelX=[x1(1),x2(1),x3(1),x4(1)];

panelY=[x1(2),x2(2),x3(2),x4(2)];


Svalue=[0.0297,0.0854,0.1311,0.1607,0.1708,...
        0.1596,0.1294,0.0859,0.0397,0.0069];

Svalue=Svalue/65;

Smax=sub_factor*h*e;


SeValues=zeros(1,10);

% CHANGE MADE:
% X and Y are 100 x 100, so Subsidence must also be 100 x 100
Subsidence=zeros(100,100);


%% SUBSIDENCE CALCULATION

for m=1:100                         % X loop for x-coordinates

    for n=1:100                     % Y loop for y-coordinates

        val=0;                      % counter updated for each coordinate

        for i=1:10                  % 10 concentric circles

            counter=0;

            theta=0:pi/32:2*pi;

            xunit=i*r*cos(theta)+X(m,n);

            yunit=i*r*sin(theta)+Y(m,n);


            for j=1:65               % 65 points on each circle

                flag=inpolygon(xunit(j),yunit(j),panelX,panelY);


                if flag==1

                    counter=counter+1;


                    v1=[100,100,0];

                    v2=[298,100,0];

                    v3=[298,394,0];

                    v4=[100,394,0];


                    pt=[xunit(j),yunit(j),0];


                    d1=point_to_line(pt,v1,v4);

                    d2=point_to_line(pt,v1,v2);

                    d3=point_to_line(pt,v2,v3);

                    d4=point_to_line(pt,v3,v4);


                    db=min([d1,d2,d3,d4]);


                    dmax=354.46;
                    % distance between starting face and ending face


                    d=d2;
                    % distance of point from starting face line


                    Wz=0.5*tanh((5*db)/(1.5*NEW*h)-2.4)+0.5;


                    Qz=0.9-0.1*tanh(0.5*(d-0.4*dmax));


                    a_(i,j)=Svalue(i)*(-Smax)*Wz*Qz*100;


                else

                    a_(i,j)=0;

                end

            end

        end


        Subsidence(m,n)=sum(sum(a_));

    end

end


%% 3D SUBSIDENCE PLOT

figure;

surf(X,Y,Subsidence);

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Subsidence (m)');

title('3D Ground Subsidence Prediction');

colorbar;

shading interp;

grid on;

view(45,30);


%% CONTOUR PLOT

figure;

contour(X,Y,Subsidence,'showtext','on');

hold on;

line(x_co,y_co,'Color','red','LineStyle','--');

xlabel('X (m)');
ylabel('Y (m)');

title('Contour Plot of Ground Subsidence');

colorbar;

grid on;