function vcclose=vc2vcclose(vc,sens,d);

dall=sqrt((vc(:,1)-sens(:,1)).^2+(vc(:,2)-sens(:,2)).^2+(vc(:,3)-sens(:,3)).^2);

vcclose=vc(dall<d,:);

return; 
