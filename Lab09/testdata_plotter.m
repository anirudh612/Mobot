clf()
modelPts = modelPts+1;
scatter(modelPts(2,:),modelPts(1,:))
axis([-4 4 -4 4])
hold on
plot(lines_p1,lines_p2)
scatter(y(thePose),x(thePose),'*')
%[e,j] = lml_obj1.getJacobian(thePose,modelPts);
jacob_p1 = [2 2+j(:,1)];
jacob_p2 = [2 2+j(:,2)];
plot(jacob_p2, jacob_p1);
axis equal