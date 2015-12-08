classdef solver < matWebSocketServer
    %SOLVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        %PosTx = [3.904 -1.820 1.758; 1.678 1.611 2.581; 0.060 -0.245 1.690; -1.616 0.150 2.624; 1.920 -5.347 2.282; 3.848 3.570 1.692]; % outside 4908
        %PosTx = [ -6.284 7.990 2.956;
        %          -0.315 4.775 2.944;
        %          -6.489 5.006 2.881;
        %         -12.231 0.254 2.961;
        %          -0.322 1.277 2.926;
        %         -12.464 7.889 2.948;]; % 1690
        
        %PosTx = [ 2.155 0.742 3.565;
        %          2.177 5.848 3.531;
        %          5.532 0.363 2.758;
        %          5.152 5.104 3.532;
        %          3.308 8.277 2.781;]
        %PosTx = [4.00016685227138,5.87125939582583,3.46300000000000;11.6793978037940,5.51011590443387,3.46900000000000;3.70751507268164,7.60332122255790,3.51900000000000;1.41800000000000,1.44300000000000,3.46600000000000;11.7658129977969,0.156868299666973,3.44700000000000;0.372553695915237,7.58935261766574,3.70000000000000];
	PosTx = [
                  0.392 13.990 3.667;
                  0.272  0.326 3.667;
                  0.425  8.052 3.667;
                  5.098  9.516 3.667;
                  4.859 14.183 3.667;
                  4.463  0.089 3.667;
                ];
        res = [0.2 0.2 0.1; 0.05 0.05 0.05];
        %rxHeight = 2.206;
    end
    
    methods
        function obj = solver(port)
            %Constructor
            obj@matWebSocketServer(port);
        end
    end
    
    methods (Access = protected)
        function onMessage(obj,message,conn)
            %display(['Received: ' message])
            
            % Parse JSON data
            data = loadjson(message);
            names = fieldnames(data.ALPS.TOA);
            toa = [];
            % Take median of received values per transmitter and store with
            % transmitter ID
            gotValidData = 0;
            for i=1:numel(names)
%                  if strcmp(names{i}, 't6')
%                      continue
%                  end
                toaData = data.ALPS.TOA.(names{i})(data.ALPS.TOA.(names{i})~=-1);
               %display(toaData)
                if numel(toaData) > 0
                    toa = [toa; [str2double(names{i}(2:end)) median(toaData)]];
                    gotValidData = gotValidData + 1;
                end
            end
            if gotValidData >= 3
                toa = sortrows(toa, 2);
                IndexTx = toa(:,1); %Find the coordinates of the visible Tx
                P = obj.PosTx(IndexTx,:);
                display(toa)
                d = toa(:,2)*340.29;
                
                % Call solver
                %[x,y] = Est2dPos(obj.PosTx, obj.rxHeight, toa, 340.29, [0.2 0.1 0.05]);
                %XlimSearch = [-0.5; 10];
                %YlimSearch = [-0.5; 10];
                XlimSearch = [min(obj.PosTx(:,1))-2;max(obj.PosTx(:,1))+2];
                YlimSearch = [min(obj.PosTx(:,2))-2;max(obj.PosTx(:,2))+2];
                ZlimSearch = [0.5 2]; %[0 0]; 
                [x,y,z] = tri_multi_laterate3D_VariedResNbeac(P,d,XlimSearch,YlimSearch,ZlimSearch, obj.res, 'a');
                display(x)
                display(y)
                %display(z)

                                % Encode position into JSON and send it back
                position = savejson('Position', struct('x', x, 'y', y));
                obj.send(conn,position);
            end
        end
    end
end

