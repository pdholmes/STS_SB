classdef STSAnimator < Animator.AbstractAnimator
    % STSAnimator handles the current time, interfaces with the control
    % panel and plots pose and SBs with trajectories
        
    properties
        ax1
        ax2
        ax3
        
        datapath
        info
        traj_data
        mytraj
        mypred
        SB_data
        results_data
        trial_list
        
        posehandles
        perthandle
        SBhandles
        SBtrajhandles
        SBpthandles
        
        success_color = 1/256*[158,202,225];
        fail_color = 1/256*[253,174,107];
        success_fill_color
        fail_fill_color
        markercolor = [0.3 0.3 0.3];
        
        SBplotiter = 3;
        myview_az = 40;
        myview_el = 30;
        myaspect = [5 1 1];
    end
    
    properties (Access = private)
    end
    
    properties
    end
    
    methods
        function obj = STSAnimator(datapath)
            obj = obj@Animator.AbstractAnimator(); % Calling super constructor
            
            obj.datapath = datapath;
            
            obj.success_fill_color = 1 - 0.2*(1 - obj.success_color);
            obj.fail_fill_color = 1 - 0.2*(1 - obj.fail_color);

            obj.info.subject = '1';
            obj.info.strategy = 'N';
            obj.info.trial = 'N_1';
            obj.info.SBtype = 'BFFFB';
            
            obj.traj_data = load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', obj.info.subject, obj.info.subject, obj.info.strategy));
            obj.SB_data = load(sprintf('%s/stability_basins/subject%s/subject%s_%s_basin_%s.mat', obj.datapath, obj.info.subject, obj.info.subject, obj.info.strategy, obj.info.SBtype));
            obj.results_data =  load(sprintf('%s/total_results/total_results_%s.mat', obj.datapath, obj.info.SBtype));

            obj.trial_list = obj.traj_data.traj_metadata.sts_type;
            
            mytrajidx = find(strcmp(obj.info.trial, obj.trial_list));
            obj.mytraj = obj.traj_data.traj{mytrajidx};
            
            obj.startTime = 0;
            obj.currentTime = obj.startTime;
            obj.endTime = obj.mytraj.times(end);
        end
        
        function obj = initializeGUI(obj)
            % creates plot handles in the axes
            notify(obj, 'trialListChanged');
            obj = obj.initializePose();
            obj = obj.initializeSB();
            obj = obj.initializeSBtraj();
        end
        
        function obj = updateInfo(obj, GUIinfo)
            % update the current subject, strategy, SB type and trial based
            % on input from the control panel.
            obj.currentTime = 0;
            
            if ~strcmp(obj.info.subject, GUIinfo.subject) || ~strcmp(obj.info.strategy, GUIinfo.strategy)
                obj.info = GUIinfo;
                obj.traj_data = load(sprintf('STS_trajectories/subject%s/subject%s_trajectories_%s.mat', obj.info.subject, obj.info.subject, obj.info.strategy));
                obj.SB_data = load(sprintf('%s/stability_basins/subject%s/subject%s_%s_basin_%s.mat', obj.datapath, obj.info.subject, obj.info.subject, obj.info.strategy, obj.info.SBtype));
                obj.trial_list = obj.traj_data.traj_metadata.sts_type;
                obj.info.trial = obj.trial_list{1};
                mytrajidx = find(strcmp(obj.info.trial, obj.trial_list));
                obj.mytraj = obj.traj_data.traj{mytrajidx};
                notify(obj, 'trialListChanged');
                obj.updateSB(obj.currentTime);
            elseif ~strcmp(obj.info.trial, GUIinfo.trial)
                obj.info.trial = GUIinfo.trial;
                mytrajidx = find(strcmp(obj.info.trial, obj.trial_list));
                obj.mytraj = obj.traj_data.traj{mytrajidx};
            end
            
            if ~strcmp(obj.info.SBtype, GUIinfo.SBtype)
                obj.info.SBtype = GUIinfo.SBtype;
                obj.SB_data = load(sprintf('%s/stability_basins/subject%s/subject%s_%s_basin_%s.mat', obj.datapath, obj.info.subject, obj.info.subject, obj.info.strategy, obj.info.SBtype));
                obj.results_data =  load(sprintf('%s/total_results/total_results_%s.mat', obj.datapath, obj.info.SBtype));
                obj.updateSB(obj.currentTime);
            end
            
            obj.endTime = obj.mytraj.times(end);
            result_idx = find(strcmp(obj.results_data.total.subject, obj.info.subject) & strcmp(obj.results_data.total.sts_type, obj.mytraj.my_sts_type));
            obj.mypred = obj.results_data.total.prediction{result_idx};
            obj.updatePose(obj.currentTime);
            obj.updateSBtraj();
            obj.updateSBpt(obj.currentTime);
            
            notify(obj, 'trialChanged');
            notify(obj, 'newTimeStep', Animator.TimeStepData(obj.currentTime, []));
        end
        
        function Draw(obj, t, x)
            % draws the pose and SB animation with time
            obj = obj.updatePose(t);
            obj = obj.updateSBpt(t);
        end
        
        function obj = AssociateAxes(obj, myGUI)
            obj.ax1 = myGUI.UIAxes;
            obj.ax2 = myGUI.UIAxes3;
            obj.ax3 = myGUI.UIAxes2;
        end
        
        function obj = initializePose(obj)
            % creates the plot handles for the pose plot
            hold(obj.ax1, 'on');
            mycolor = obj.success_color;
            
            t = obj.mytraj.sync_idxs(1);
            
            origin = (obj.mytraj.skel_mocap.joints.rtoe(1, :) + obj.mytraj.skel_mocap.joints.ltoe(1, :))/2;
            rtoe = obj.mytraj.skel_mocap.joints.rtoe(t, :) - origin;
            rankle = obj.mytraj.skel_mocap.joints.rankle(t, :) - origin;
            rknee = obj.mytraj.skel_mocap.joints.rknee(t, :) - origin;
            rhip = obj.mytraj.skel_mocap.joints.rhip(t, :) - origin;
            ltoe = obj.mytraj.skel_mocap.joints.ltoe(t, :) - origin;
            lankle = obj.mytraj.skel_mocap.joints.lankle(t, :) - origin;
            lknee = obj.mytraj.skel_mocap.joints.lknee(t, :) - origin;
            lhip = obj.mytraj.skel_mocap.joints.lhip(t, :) - origin;
            shoulders = obj.mytraj.skel_mocap.joints.shoulder(t, :) - origin;
            hip = (rhip + lhip)/2;
            
            title(obj.ax1, ['Subject ' obj.info.subject ': ' obj.mytraj.my_sts_type ' -- success'], 'Interpreter', 'none');
            axis(obj.ax1, 'equal');
            xlim(obj.ax1, [-0.875, 0.875]);
            ylim(obj.ax1, [0, 1.75]);
            set(obj.ax1, 'XTick', [], 'YTick', []);
            
            
            t = obj.mytraj.sync_idxs(1);
            obj.posehandles = plot(obj.ax1, [rtoe(1, 1); rankle(1, 1); rknee(1, 1); hip(1, 1); shoulders(1, 1); hip(1, 1); lknee(1, 1); lankle(1, 1); ltoe(1, 1)], [rtoe(1, 2); rankle(1, 2); rknee(1, 2); hip(1, 2); shoulders(1, 2); hip(1, 2); lknee(1, 2); lankle(1, 2); ltoe(1, 2)], 'Color', mycolor, 'LineWidth', 4, 'MarkerSize', 15);
            plot(obj.ax1, [3*0.0254, 3*0.0254], [0, 0.075], ':', 'Color', obj.fail_color, 'LineWidth', 4);
            plot(obj.ax1, [-3*0.0254, -3*0.0254], [0, 0.075], ':', 'Color', obj.fail_color, 'LineWidth', 4);
            
            obj.perthandle = quiver(obj.ax1, hip(1, 1) + 0.1, hip(1, 2) + 0.1, 0.4, 0, 'k', 'LineWidth', 6, 'Color', [0.3 0.3 0.3]);
            obj.perthandle.Visible = 'off';
        end
        
        function obj = initializeSB(obj)
            % creates the plot handles for the SB plot
            SBtimesback = 1 - obj.SB_data.options.times_vec;
            for plotRun=1:2
                % plot different projections
                if plotRun==1
                    projectedDimensions=[1 2];
                    myax = obj.ax2;
                    
                elseif plotRun==2
                    projectedDimensions=[3 4];
                    myax = obj.ax3;
                end
                
                hold(myax, 'on');
                Z = project(obj.SB_data.options.R0, projectedDimensions);
                Zpts = polygon(Z)';
                obj.SBhandles{plotRun}.p10 = fill3(myax, ones(size(Zpts, 1), 1)*SBtimesback(1), Zpts(:, 1), Zpts(:, 2), [0.6 0.6 0.6]);
                obj.SBhandles{plotRun}.p10.LineWidth = 2;
                for i = 1:obj.SBplotiter:length(obj.SB_data.Rcont)
                    for j = 1:length(obj.SB_data.Rcont{i})
                        Z = project(obj.SB_data.Rcont{i}{j}, projectedDimensions);
                        Zpts = polygon(Z)';
                        obj.SBhandles{plotRun}.p1(i) = fill3(myax, ones(size(Zpts, 1), 1)*SBtimesback(i), Zpts(:, 1), Zpts(:, 2), obj.success_fill_color);
%                         obj.SBhandles{plotRun}.p1(i).FaceAlpha = 0.05;
%                         obj.SBhandles{plotRun}.p1(i).EdgeAlpha = 0.09;
                        obj.SBhandles{plotRun}.p1(i).FaceAlpha = 0;
                        obj.SBhandles{plotRun}.p1(i).EdgeAlpha = 1;
                    end
                end
            end
            set(obj.ax2,'defaulttextinterpreter','latex');
            set(obj.ax2, 'FontName', 'Helvetica');
            view(obj.ax2, obj.myview_az, obj.myview_el);
            pbaspect(obj.ax2, obj.myaspect);
            set(obj.ax2, 'XTick', [0 0.2 0.4 0.6 0.8 1]);
            xlabel(obj.ax2, '$t$', 'FontSize', 24, 'Interpreter', 'latex');
            ylabel(obj.ax2, '$r_x$', 'FontSize', 24, 'Interpreter', 'latex');
            zlabel(obj.ax2, '$v_x$', 'FontSize', 24, 'Interpreter', 'latex');
            box(obj.ax2, 'on');
            
            set(obj.ax3,'defaulttextinterpreter','latex');
            set(obj.ax3, 'FontName', 'Helvetica');
            view(obj.ax3, obj.myview_az, obj.myview_el);
            pbaspect(obj.ax3, obj.myaspect);
            set(obj.ax3, 'XTick', [0 0.2 0.4 0.6 0.8 1]);
            xlabel(obj.ax3, '$t$', 'FontSize', 24, 'Interpreter', 'latex');
            ylabel(obj.ax3, '$r_y$', 'FontSize', 24, 'Interpreter', 'latex');
            zlabel(obj.ax3, '$v_y$', 'FontSize', 24, 'Interpreter', 'latex');
            box(obj.ax3, 'on');
            
        end
        
        function obj = initializeSBtraj(obj)
            % creates plot handles for the SB trajectory
            for plotRun = 1:2
                if plotRun==1
                    myax = obj.ax2;
                    mypos = 'p_x_com';
                    myvel = 'v_x_com';
                elseif plotRun==2
                    myax = obj.ax3;
                    mypos = 'p_y_com';
                    myvel = 'v_y_com';
                end
                obj.SBtrajhandles{plotRun}.p1 = plot3(myax, obj.mytraj.times/obj.mytraj.times(end), obj.mytraj.(mypos), obj.mytraj.times(end)*obj.mytraj.(myvel), 'LineWidth', 3, 'Color', obj.success_color);
                obj.SBtrajhandles{plotRun}.p1p = plot3(myax, obj.mytraj.times/obj.mytraj.times(end), obj.mytraj.(mypos), obj.mytraj.times(end)*obj.mytraj.(myvel), 'LineWidth', 7, 'Color', obj.success_color, 'LineStyle', ':', 'Visible', 'off');
                obj.SBtrajhandles{plotRun}.p1pb = plot3(myax, obj.mytraj.times/obj.mytraj.times(end), obj.mytraj.(mypos), obj.mytraj.times(end)*obj.mytraj.(myvel), 'LineWidth', 7, 'Color', obj.success_color, 'LineStyle', ':', 'Visible', 'off');
                obj.SBtrajhandles{plotRun}.p1e = plot3(myax, obj.mytraj.times(1)/obj.mytraj.times(end), obj.mytraj.(mypos)(1), obj.mytraj.times(end)*obj.mytraj.(myvel)(1), 'LineWidth', 3, 'Color', obj.markercolor, 'Marker', '^', 'MarkerSize', 8, 'LineStyle', 'none', 'Visible', 'off');
                obj.SBtrajhandles{plotRun}.p1eb = plot3(myax, obj.mytraj.times(1)/obj.mytraj.times(end), obj.mytraj.(mypos)(1), obj.mytraj.times(end)*obj.mytraj.(myvel)(1), 'LineWidth', 3, 'Color', obj.markercolor, 'Marker', '^', 'MarkerSize', 8, 'LineStyle', 'none', 'Visible', 'off');
                obj.SBtrajhandles{plotRun}.p1f = plot3(myax, obj.mytraj.times(1)/obj.mytraj.times(end), obj.mytraj.(mypos)(1), obj.mytraj.times(end)*obj.mytraj.(myvel)(1), 'LineWidth', 5, 'Color', obj.markercolor, 'Marker', '+', 'MarkerSize', 13, 'LineStyle', 'none', 'Visible', 'off');
                obj.SBtrajhandles{plotRun}.p1fb = plot3(myax, obj.mytraj.times(1)/obj.mytraj.times(end), obj.mytraj.(mypos)(1), obj.mytraj.times(end)*obj.mytraj.(myvel)(1), 'LineWidth', 5, 'Color', obj.markercolor, 'Marker', '+', 'MarkerSize', 13, 'LineStyle', 'none', 'Visible', 'off');
                
                x = [obj.mytraj.times(1)/obj.mytraj.times(end)]*ones(4, 1);
                y = [myax.YLim(1), myax.YLim(1), myax.YLim(2), myax.YLim(2)];
                z = [myax.ZLim(1), myax.ZLim(2), myax.ZLim(2), myax.ZLim(1)];
                obj.SBpthandles{plotRun}.p1 = fill3(myax, x, y, z, [0.4 0.4 0.4]);
                obj.SBpthandles{plotRun}.p1.FaceAlpha = 0;
                obj.SBpthandles{plotRun}.p1.LineWidth = 2;
            end
            legend(obj.ax2, [obj.SBtrajhandles{1}.p1; obj.SBtrajhandles{1}.p1p; obj.SBtrajhandles{1}.p1e; obj.SBtrajhandles{1}.p1f], {'Trajectory', 'Pert. applied', 'Exits basin', 'Failure init.'}, 'Location', 'NorthEast');
            legend(obj.ax3, [obj.SBtrajhandles{2}.p1; obj.SBtrajhandles{2}.p1p; obj.SBtrajhandles{2}.p1e; obj.SBtrajhandles{2}.p1f], {'Trajectory', 'Pert. applied', 'Exits basin', 'Failure init.'}, 'Location', 'NorthEast');
        end
        
        function obj = updatePose(obj, plot_time)
            % updates the pose to the current time
            [~, idx1] = min(abs(obj.mytraj.times - plot_time));
            t = obj.mytraj.sync_idxs(idx1);
            
            switch obj.mytraj.classification
                case 'success'
                    mycolor = obj.success_color;
                    classstr = 'success';
                case 'fail'
                    mycolor = obj.fail_color;
                    if obj.mytraj.label == 6
                        classstr = 'step';
                    elseif obj.mytraj.label == 7
                        classstr = 'sit';
                    end
            end
            
            title(obj.ax1, ['Subject ' obj.info.subject ': ' obj.mytraj.my_sts_type ' -- ' classstr], 'Interpreter', 'none');
            
            origin = (obj.mytraj.skel_mocap.joints.rtoe(1, :) + obj.mytraj.skel_mocap.joints.ltoe(1, :))/2;
            rtoe = obj.mytraj.skel_mocap.joints.rtoe(t, :) - origin;
            rankle = obj.mytraj.skel_mocap.joints.rankle(t, :) - origin;
            rknee = obj.mytraj.skel_mocap.joints.rknee(t, :) - origin;
            rhip = obj.mytraj.skel_mocap.joints.rhip(t, :) - origin;
            ltoe = obj.mytraj.skel_mocap.joints.ltoe(t, :) - origin;
            lankle = obj.mytraj.skel_mocap.joints.lankle(t, :) - origin;
            lknee = obj.mytraj.skel_mocap.joints.lknee(t, :) - origin;
            lhip = obj.mytraj.skel_mocap.joints.lhip(t, :) - origin;
            shoulders = obj.mytraj.skel_mocap.joints.shoulder(t, :) - origin;
            hip = (rhip + lhip)/2;
            
            obj.posehandles.XData = [rtoe(1, 1); rankle(1, 1); rknee(1, 1); hip(1, 1); shoulders(1, 1); hip(1, 1); lknee(1, 1); lankle(1, 1); ltoe(1, 1)];
            obj.posehandles.YData = [rtoe(1, 2); rankle(1, 2); rknee(1, 2); hip(1, 2); shoulders(1, 2); hip(1, 2); lknee(1, 2); lankle(1, 2); ltoe(1, 2)];
            obj.posehandles.Color = mycolor;
            
            if idx1 >= obj.mytraj.first_pert_idx && idx1 <= obj.mytraj.last_pert_idx
                if (obj.mytraj.lperturb.setpoint(idx1) - obj.mytraj.rperturb.setpoint(idx1)) >= 0
                    pertdir = 1;
                else
                    pertdir = -1;
                end
                    
               obj.perthandle.XData = hip(1, 1) + pertdir*0.1;
               obj.perthandle.YData = hip(1, 2) + 0.1;
               obj.perthandle.UData = pertdir*0.4;
               obj.perthandle.Visible = 'on';
            else
                obj.perthandle.Visible = 'off';
            end
            
        end
        
        function obj = updateSB(obj, plot_time)
            % updates the SB if any info has changed
            SBtimesback = 1 - obj.SB_data.options.times_vec;
            
            for plotRun=1:2
                % plot different projections
                if plotRun==1
                    projectedDimensions=[1 2];
                    myax = obj.ax2;
                elseif plotRun==2
                    projectedDimensions=[3 4];
                    myax = obj.ax3;
                end
                
                hold(myax, 'on');
                Z = project(obj.SB_data.options.R0, projectedDimensions);
                Zpts = polygon(Z)';
                obj.SBhandles{plotRun}.p10.XData = ones(size(Zpts, 1), 1)*SBtimesback(1);
                obj.SBhandles{plotRun}.p10.YData = Zpts(:, 1);
                obj.SBhandles{plotRun}.p10.ZData = Zpts(:, 2);
                for i = 1:obj.SBplotiter:length(obj.SB_data.Rcont)
                    for j = 1:length(obj.SB_data.Rcont{i})
                        Z = project(obj.SB_data.Rcont{i}{j}, projectedDimensions);
                        Zpts = polygon(Z)';
                        obj.SBhandles{plotRun}.p1(i).XData = ones(size(Zpts, 1), 1)*SBtimesback(i);
                        obj.SBhandles{plotRun}.p1(i).YData = Zpts(:, 1);
                        obj.SBhandles{plotRun}.p1(i).ZData = Zpts(:, 2);
                    end
                    obj.SBtrajhandles{plotRun}.p1pb.Visible = 'off';
                    obj.SBtrajhandles{plotRun}.p1eb.Visible = 'off';
                    obj.SBtrajhandles{plotRun}.p1fb.Visible = 'off';
                end
                
                set(obj.SBpthandles{plotRun}.p1, 'Visible', 'off');
            end
        end
        
        function obj = updateSBtraj(obj)
            % update the SB trajectory if nay info has changed
            switch obj.mytraj.classification
                case 'success'
                    mycolor = obj.success_color;
                case 'fail'
                    mycolor = obj.fail_color;
            end
            for plotRun = 1:2
                if plotRun==1
                    myax = obj.ax2;
                    mypos = 'p_x_com';
                    myvel = 'v_x_com';
                elseif plotRun==2
                    myax = obj.ax3;
                    mypos = 'p_y_com';
                    myvel = 'v_y_com';
                end
                % update trajectory
                obj.SBtrajhandles{plotRun}.p1.XData = obj.mytraj.times/obj.mytraj.times(end);
                obj.SBtrajhandles{plotRun}.p1.YData = obj.mytraj.(mypos);
                obj.SBtrajhandles{plotRun}.p1.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel);
                obj.SBtrajhandles{plotRun}.p1.Color = mycolor;
                % plot perturbed portions:
                if ~isnan(obj.mytraj.first_pert_idx)
                    idxs = obj.mytraj.first_pert_idx:min(length(obj.mytraj.times), obj.mytraj.last_pert_idx);
                    obj.SBtrajhandles{plotRun}.p1p.XData = obj.mytraj.times(idxs)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1p.YData = obj.mytraj.(mypos)(idxs);
                    obj.SBtrajhandles{plotRun}.p1p.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(idxs);
                    obj.SBtrajhandles{plotRun}.p1p.Color = mycolor;
                    obj.SBtrajhandles{plotRun}.p1p.Visible = 'on';
                    obj.SBtrajhandles{plotRun}.p1pb.XData = obj.mytraj.times(idxs)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1pb.YData = myax.YLim(1)*ones(length(idxs),1);
                    obj.SBtrajhandles{plotRun}.p1pb.ZData = myax.ZLim(1)*ones(length(idxs),1);
                    obj.SBtrajhandles{plotRun}.p1pb.Color = mycolor;
                    obj.SBtrajhandles{plotRun}.p1pb.Visible = 'on';
                else
                    idxs = 1:length(obj.mytraj.times);
                    obj.SBtrajhandles{plotRun}.p1p.XData = obj.mytraj.times(idxs)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1p.YData = obj.mytraj.(mypos)(idxs);
                    obj.SBtrajhandles{plotRun}.p1p.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(idxs);
                    obj.SBtrajhandles{plotRun}.p1p.Color = mycolor;
                    obj.SBtrajhandles{plotRun}.p1p.Visible = 'off';
                    obj.SBtrajhandles{plotRun}.p1pb.XData = obj.mytraj.times(idxs)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1pb.YData = obj.mytraj.(mypos)(idxs);
                    obj.SBtrajhandles{plotRun}.p1pb.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(idxs);
                    obj.SBtrajhandles{plotRun}.p1pb.Color = mycolor;
                    obj.SBtrajhandles{plotRun}.p1pb.Visible = 'off';
                end
                
                % plot exit markers:
                result_idx = find(strcmp(obj.results_data.total.subject, obj.info.subject) & strcmp(obj.results_data.total.sts_type, obj.mytraj.my_sts_type));
                if ~isnan(obj.results_data.total.firstexit_percent(result_idx))
                    [~, myidx] = min(abs(obj.mytraj.times/obj.mytraj.times(end) - obj.results_data.total.firstexit_percent(result_idx)));
                    obj.SBtrajhandles{plotRun}.p1e.XData = obj.mytraj.times(myidx)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1e.YData = obj.mytraj.(mypos)(myidx);
                    obj.SBtrajhandles{plotRun}.p1e.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(myidx);
                    obj.SBtrajhandles{plotRun}.p1e.Visible = 'on';
                    obj.SBtrajhandles{plotRun}.p1eb.XData = obj.mytraj.times(myidx)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1eb.YData = myax.YLim(1);
                    obj.SBtrajhandles{plotRun}.p1eb.ZData = myax.ZLim(1);
                    obj.SBtrajhandles{plotRun}.p1eb.Visible = 'on';
                else
                    idxs = 1;
                    obj.SBtrajhandles{plotRun}.p1e.XData = obj.mytraj.times(idxs)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1e.YData = obj.mytraj.(mypos)(idxs);
                    obj.SBtrajhandles{plotRun}.p1e.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(idxs);
                    obj.SBtrajhandles{plotRun}.p1e.Visible = 'off';
                    obj.SBtrajhandles{plotRun}.p1eb.XData = obj.mytraj.times(idxs)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1eb.YData = obj.mytraj.(mypos)(idxs);
                    obj.SBtrajhandles{plotRun}.p1eb.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(idxs);
                    obj.SBtrajhandles{plotRun}.p1eb.Visible = 'off';
                end
                
                % plot failure time and location
                if strcmp(obj.mytraj.classification, 'fail')
                    myidx = min(min(obj.mytraj.step_idx, obj.mytraj.sit_idx), length(obj.mytraj.times));
                    obj.SBtrajhandles{plotRun}.p1f.XData = obj.mytraj.times(myidx)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1f.YData = obj.mytraj.(mypos)(myidx);
                    obj.SBtrajhandles{plotRun}.p1f.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(myidx);
                    obj.SBtrajhandles{plotRun}.p1f.Visible = 'on';
                    obj.SBtrajhandles{plotRun}.p1fb.XData = obj.mytraj.times(myidx)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1fb.YData = myax.YLim(1);
                    obj.SBtrajhandles{plotRun}.p1fb.ZData = myax.ZLim(1);
                    obj.SBtrajhandles{plotRun}.p1fb.Visible = 'on';
                else
                    idxs = 1;
                    obj.SBtrajhandles{plotRun}.p1f.XData = obj.mytraj.times(idxs)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1f.YData = obj.mytraj.(mypos)(idxs);
                    obj.SBtrajhandles{plotRun}.p1f.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(idxs);
                    obj.SBtrajhandles{plotRun}.p1f.Visible = 'off';
                    obj.SBtrajhandles{plotRun}.p1fb.XData = obj.mytraj.times(idxs)/obj.mytraj.times(end);
                    obj.SBtrajhandles{plotRun}.p1fb.YData = obj.mytraj.(mypos)(idxs);
                    obj.SBtrajhandles{plotRun}.p1fb.ZData = obj.mytraj.times(end)*obj.mytraj.(myvel)(idxs);
                    obj.SBtrajhandles{plotRun}.p1fb.Visible = 'off';
                end
            end
        end
        
        function obj = updateSBpt(obj, plot_time)
            % updates the square representing time in SB plot
            [~, idx] = min(abs(obj.mytraj.times - plot_time));
            plot_percent = plot_time/obj.mytraj.times(end);

            x = [plot_percent]*ones(4, 1);
            y = [obj.ax2.YLim(1), obj.ax2.YLim(1), obj.ax2.YLim(2), obj.ax2.YLim(2)];
            z = [obj.ax2.ZLim(1), obj.ax2.ZLim(2), obj.ax2.ZLim(2), obj.ax2.ZLim(1)];
            set(obj.SBpthandles{1}.p1, 'XData', x, 'YData', y', 'ZData', z);
            set(obj.SBpthandles{1}.p1, 'Visible', 'on');
            
            y = [obj.ax3.YLim(1), obj.ax3.YLim(1), obj.ax3.YLim(2), obj.ax3.YLim(2)];
            z = [obj.ax3.ZLim(1), obj.ax3.ZLim(2), obj.ax3.ZLim(2), obj.ax3.ZLim(1)];
            set(obj.SBpthandles{2}.p1, 'XData', x, 'YData', y', 'ZData', z);
            set(obj.SBpthandles{2}.p1, 'Visible', 'on');
        end
        
        % unnecessary members:
        function [center, radius, yaw] = GetCenter(obj, t, x)
            center = [0;0;0];
            radius = 1;
            yaw = 0;
        end
        
        function x = GetData(obj, t)
            % no functionality for now
            x = [];
        end
        
    end
    
    events
       trialListChanged 
       trialChanged
    end
end
