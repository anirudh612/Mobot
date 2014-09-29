classdef trajectoryFollower < handle
    properties
      rob  
      vmax
      amax
    end
    methods
        function obj = trajectoryFollower(robot_name)
            obj.rob = neato(robot_name);
            obj.vmax = 0.15;
            obj.amax = 3*obj.vmax;
       
        end
            
            
        function opVelocity(obj)
            sref=0;
            t_prev=0;
            robotTrajObj = robotTrajectory();
            robotObj = robotModel();
            DistFinal = 0.3*12.565*robotTrajObj.Ks;
            tf = 2*robotTrajObj.t_pause + (DistFinal-(obj.vmax^2/obj.amax))/obj.vmax + obj.vmax/obj.amax;
            %lh = event.listener(robot.encoders,'OnMessageReceived',@neatoEncoderEventListener);
            tstart = tic();
            figure(1);
            while(true)
                t_now=toc(tstart);
                V = trapezoidalVelocityProfile(t_now, obj.amax, obj.vmax,1,tf,robotTrajObj.t_pause);
                dt = t_now-t_prev;
                sref = sref + V*dt;
                w = getOmegaAtDistance(robotTrajObj,sref,obj.amax,obj.vmax,robotTrajObj.t_pause,tf);
                [vl,vr] = robotObj.VwTovlvr(V,w);
                obj.rob.sendVelocity(vl,vr);
                %{
                axis manual;
                axis([-350 350 -350 350]);
                scatter(-y,x,'.','b');
                hold on;
                %}
                if(t_now>=tf)
                    obj.rob.sendVeloctiy(0,0);
                    break;
                end
                t_prev=t_now;
            end
        end
    end
end
            