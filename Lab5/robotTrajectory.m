classdef robotTrajectory < handle
   properties
      distance
      velocity
      poses
      time
      omega
      Ks = 0.5;
      Kv = 0.5;
      t_pause = 0.5;
      num_samples = 1000;
   end
   methods
        function obj = robotTrajectory()
            velocity_obj = figure8ReferenceControl(obj.Ks,obj.Kv,obj.t_pause);
            tf = velocity_obj.getTrajectoryDuration();
            obj.distance = zeros(obj.num_samples,1);
            obj.velocity = zeros(obj.num_samples,1);
            obj.omega = zeros(obj.num_samples,1);
            obj.poses = zeros(obj.num_samples,3);
            dt = tf/obj.num_samples;
            obj.time = (1:obj.num_samples)*dt;
            for i=2:obj.num_samples
                velocity_obj.computeControl(dt*(i-1));
                obj.velocity(i) = velocity_obj.v;
                obj.omega(i) = velocity_obj.w;
                obj.distance(i) = obj.distance(i-1) + obj.velocity(i-1)*dt;
                temp_theta = obj.poses(i-1,3)+obj.omega(i-1)*dt/2;
                obj.poses(i,1) = obj.poses(i-1,1)+1000*obj.velocity(i-1)*cos(temp_theta)*dt;
                obj.poses(i,2) = obj.poses(i-1,2)+1000*obj.velocity(i-1)*sin(temp_theta)*dt;
                obj.poses(i,3) = temp_theta+obj.omega(i-1)*dt/2;
            end
            scatter(obj.poses(:,1),obj.poses(:,2),'r');
            hold on;
        end 
        
       function vel_t = getVelocityAtTime(obj, t)
           vel_t = interp1(obj.time, obj.velocity, t); 
       end
       
       function dist_t = getVelocityAttime(obj, t)
           dist_t = interp1(obj.time, obj.distance, t); 
       end
       
       function pose_t = getPosesAttime(obj,t)
           pose_t = zeros(1,3);
           pose_t(1) = interp1(obj.time, obj.poses(:,1), t); 
           pose_t(2) = interp1(obj.time, obj.poses(:,2), t);
           pose_t(3) = interp1(obj.time, obj.poses(:,3), t);
       end
       
       function pose_dist = getPoseAtDistance(obj,dist,amax,vmax,tPause,tf)
           tramp = vmax/amax;
           t0 = tf-2*tPause-2*tramp;
           persistent prev_pose;
           if dist<0.5*amax*tramp^2
               t = sqrt(2*dist/amax)+tPause;
           elseif dist<(0.5*amax*tramp^2+vmax*t0)
               t = (dist-0.5*amax*tramp^2)/(vmax)+tPause;
           else
               A = -0.5*amax;
               B = amax*tramp;
               C = 0.5*amax*tramp^2 + vmax*-dist;
               if B^2-4*A*C>0
                    t = (-B+sqrt(B^2-4*A*C))/(2*A);
                    t = tPause+tramp+t0+t;
               else
                   pose_dist = prev_pose;
                   return
               end
               
           end
           pose_dist = getPosesAttime(obj,t);
           prev_pose = pose_dist;
       end
       
       function omega_t = getOmegaAttime(obj, t)
           omega_t = interp1(obj.time, obj.omega, t); 
       end
       
       function omega_dist = getOmegaAtDistance(obj,dist,amax,vmax,tPause,tf)
           persistent omega_prev;
           tramp = vmax/amax;
           t0 = tf-2*tPause-2*tramp;
           if dist<0.5*amax*tramp^2
               t = sqrt(2*dist/amax)+tPause;
           elseif dist<(0.5*amax*tramp^2+vmax*t0)
               t = (dist-0.5*amax*tramp^2)/(vmax)+tPause;
           else
               A = -0.5*amax;
               B = amax*tramp;
               C = 0.5*amax*tramp^2 + vmax*-dist;
               if B^2-4*A*C>0
                    t = (-B+sqrt(B^2-4*A*C))/(2*A);
                    t = tPause+tramp+t0+t;
               else
                   omega_dist = omega_prev;
                   return
               end
               
           end
           omega_dist = obj.getOmegaAttime(t);
           omega_prev = omega_dist;
       end
       
       
       
end   
end