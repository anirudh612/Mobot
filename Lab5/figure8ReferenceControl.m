classdef figure8ReferenceControl < handle
    
    properties (GetAccess = 'public', SetAccess = 'private')
        v
        w
        Ks
        Kv
        tPause
        robotObj
    end
    
    methods
        function obj = figure8ReferenceControl(Ks,Kv,tPause)
            obj.Ks = Ks;
            obj.Kv = Kv;
            obj.tPause = tPause;
            obj.robotObj = robotModel();
        end
        
        function obj = computeControl(obj,timeNow)
            if timeNow<obj.tPause
                obj.v = 0;
                obj.w = 0;
            elseif timeNow<getTrajectoryDuration(obj)-obj.tPause
                vr = 0.3*obj.Kv + 0.14125*(obj.Kv/obj.Ks)*sin((timeNow-obj.tPause)*obj.Kv/(2*obj.Ks));
                vl = 0.3*obj.Kv - 0.14125*(obj.Kv/obj.Ks)*sin((timeNow-obj.tPause)*obj.Kv/(2*obj.Ks));
                [obj.v,obj.w] = obj.robotObj.vlvrToVw(vl,vr);
            else
                obj.v = 0;
                obj.w =0;
            end
        end
        
        function duration = getTrajectoryDuration(obj)
            duration = 12.565*obj.Ks/obj.Kv + 2*obj.tPause;
        end
    end
end
        
            
            
                
                
                
            