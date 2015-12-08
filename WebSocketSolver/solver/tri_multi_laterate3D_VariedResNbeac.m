function [x,y,z] = tri_multi_laterate3D_VariedResNbeac(P,d,XlimSearchInit,YlimSearchInit,ZlimSearchInit, res,type)
%P      : Nx2 matrix with each row being the (x,y) of node
%d      : Mx1 matrix with toa or tof values
%Xspace : 1x2 matrix ith min and max x coordinate in the search space
%Yspace : 1x2 matrix ith min and max y coordinate in the search space
%res    : Resolution of search grid in iterations
%         In the form of a NumIter x 3 matrix, where each row corresponds
%         to the resolution in that iteration. Column corresponds to x,y,z 
    X = P(:,1);
    Y = P(:,2);
    Z = P(:,3);
           
    Nbeac = length(X);
    NumIter = size(res,1);
       
    Xlim_S(1) = XlimSearchInit(1);  Xlim_E(1) = XlimSearchInit(2);
    Ylim_S(1) = YlimSearchInit(1);  Ylim_E(1) = YlimSearchInit(2);
    Zlim_S(1) = ZlimSearchInit(1);  Zlim_E(1) = ZlimSearchInit(2);
    
    for i=1:NumIter
        %Call optim func with lims X,Y<Z
        x_search = Xlim_S(i):res(i,1):Xlim_E(i); 
        y_search = Ylim_S(i):res(i,2):Ylim_E(i);
        z_search = Zlim_S(i):res(i,3):Zlim_E(i);
        
        [xp,yp,zp] = meshgrid(x_search,y_search,z_search);
        v = zeros(numel(x_search), numel(y_search), numel(z_search));
        for k = 1:length(z_search)
            for m = 1:length(y_search)
                for n = 1:length(x_search)
                    if type == 'f' %TOF
                        v(n,m,k) = double(MinFunc3d_TOF(x_search(n),y_search(m),z_search(k),X,Y,Z,d,Nbeac));
                    else % type = 'a'
                        v(n,m,k) = double(MinFunc3d_TDOA(x_search(n),y_search(m),z_search(k),X,Y,Z,d,Nbeac));
                    end
                end
            end
        end
        [x_ind,y_ind,z_ind]=ind2sub(size(v),find(v==min(min(min(v)))));
        x_min(i) = x_search(x_ind(1)); %use only the first minima in case of multiple
        y_min(i) = y_search(y_ind(1));
        z_min(i) = z_search(z_ind(1));
        
        clear x_search y_search z_search;
        Xlim_S(i+1) = x_min(i)-res(i,1);
        Xlim_E(i+1) = x_min(i)+res(i,1); 
        Ylim_S(i+1) = y_min(i)-res(i,2);
        Ylim_E(i+1) = y_min(i)+res(i,2); 
        Zlim_S(i+1) = z_min(i)-res(i,3);
        Zlim_E(i+1) = z_min(i)+res(i,3); 
        
    end
    
    x = x_min(end);
    y = y_min(end);
    z = z_min(end);
    
end


