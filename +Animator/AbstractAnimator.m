classdef AbstractAnimator < handle
    properties(Access = private)
        tmr timer
    end
    
    properties (GetAccess = protected, SetAccess = immutable)
        fig
        axs
%         fig_close_listener
    end
    
    properties (Access = public)
        currentTime double
        speed double
        orig_speed double;
        aspectRatio = [1 1 1];
    end
    
    properties (Access = public)
        isLooping logical
%         pov Animator.AnimatorPointOfView
        
        startTime double
        endTime double
    end
    
    properties (GetAccess = public, SetAccess = immutable)
        TimerDelta double
    end
    
    properties (Dependent, Access = public)
        isPlaying logical
    end
    
    methods
        function obj = AbstractAnimator(f)
%         function obj = AbstractAnimator(axs)
            if exist('f', 'var')
                obj.fig = f;
                obj.axs = axs;
                pbaspect(obj.axs, obj.aspectRatio);
            else
%                 obj.fig = figure();
                %Patrick's edits:
%                 obj.fig = figure('Units', 'normalized', 'Color', [1 1 1], 'DeleteFcn', @obj.closeAnimator);
%                 obj.axs = axes(obj.fig);
%                 axis(obj.axs, 'equal');
%                 hold(obj.axs, 'on');
%                 obj.axs.ZGrid = 'off';
%                 obj.axs.YGrid = 'off';
%                 obj.axs.XGrid = 'off';
%                 obj.axs.Box = 'on';
%                 obj.axs.BoxStyle = 'back';
%                 obj.axs.View = [30, 40];
%                 obj.axs.ZTick = [];
%                 pbaspect(obj.axs, obj.aspectRatio);
            end
            
%             obj.fig_close_listener = addlistener(obj.fig, 'BeingDeleted', 'PostSet', @closeAnimator);
            
            obj.orig_speed = 0.5;
            obj.speed = obj.orig_speed;
            
%             obj.TimerDelta = round(1/30,3);
            obj.TimerDelta = round(1/15, 3);
%             obj.pov = Animator.AnimatorPointOfView.Free;
            
            obj.tmr = timer;
            obj.tmr.Period = obj.TimerDelta;
            obj.tmr.ExecutionMode = 'fixedRate';
            obj.tmr.TimerFcn = @(~, ~) obj.Animate();
        end
        
        function playing = get.isPlaying(obj)
            playing = strcmp(obj.tmr.Running, 'on');
        end
        
        function set.isPlaying(obj, play)
            if ~obj.isPlaying && play
                start(obj.tmr);
                notify(obj, 'playStateChanged');
            elseif obj.isPlaying && ~play
                stop(obj.tmr);
                notify(obj, 'playStateChanged');
            end
        end
        
        function set.currentTime(obj, time)
            obj.currentTime = time;
            
            if obj.currentTime > obj.endTime
                obj.currentTime = obj.endTime;
            elseif obj.currentTime < obj.startTime
                obj.currentTime = obj.startTime;
            end
        end
        
        function [] = closeAnimator(obj, ~, ~)
            obj.isPlaying = false;
            stop(obj.tmr);
            notify(obj, 'playStateChanged');
            notify(obj, 'animDeleting');
        end
    end
    
    methods (Sealed)
        function Animate(obj, Freeze)
            if ~exist('Freeze', 'var')
                Freeze = false;
            end
            
            if obj.currentTime >= obj.endTime
                obj.currentTime = obj.endTime;
                x = GetData(obj, obj.currentTime);
                
                notify(obj, 'newTimeStep', Animator.TimeStepData(obj.currentTime, x));
                
                obj.Draw(obj.currentTime, x);
                obj.HandleAxis(obj.currentTime, x);
                
                notify(obj, 'reachedEnd', Animator.TimeStepData(obj.currentTime, x));
                
                if obj.isLooping
                    if ~Freeze
                        obj.currentTime = obj.startTime;
                    end
                else
                    obj.isPlaying = false;
                end
            else
                x = GetData(obj, obj.currentTime);
                
                notify(obj, 'newTimeStep', Animator.TimeStepData(obj.currentTime, x));
                
                obj.Draw(obj.currentTime, x);
                obj.HandleAxis(obj.currentTime, x);
                
                if ~Freeze
                    obj.currentTime = obj.currentTime + obj.TimerDelta*obj.speed;
                end
            end
        end
    end
    
    methods
        function HandleAxis(obj, t, x)
            [center, radius, yaw] = GetCenter(obj, t, x);
            if length(radius) == 1
                axis(obj.axs, [center(1)-radius, center(1)+radius, center(2)-radius, center(2)+radius,center(3)-radius, center(3)+radius]);
            else
                axis(obj.axs, radius);
            end
            
            hAngle = 0;
            vAngle = 0;
            
%             switch(obj.pov)
%                 case Animator.AnimatorPointOfView.North
%                     hAngle = hAngle + 0;
%                 case Animator.AnimatorPointOfView.South
%                     hAngle = hAngle + 180;
%                 case Animator.AnimatorPointOfView.East
%                     hAngle = hAngle - 90;
%                 case Animator.AnimatorPointOfView.West
%                     hAngle = hAngle + 90;
%                 case Animator.AnimatorPointOfView.Front
%                     hAngle = hAngle + yaw;
%                 case Animator.AnimatorPointOfView.Back
%                     hAngle = hAngle + 180 + yaw;
%                 case Animator.AnimatorPointOfView.Left
%                     hAngle = hAngle - 90 + yaw;
%                 case Animator.AnimatorPointOfView.Right
%                     hAngle = hAngle + 90 + yaw;
%                 case Animator.AnimatorPointOfView.TopSouthEast
%                     hAngle = hAngle + 225;
%                     vAngle = vAngle + 45;
%                 case Animator.AnimatorPointOfView.TopFrontLeft
%                     hAngle = hAngle + 225 + yaw;
%                     vAngle = vAngle + 45;
%             end
%             
%             if obj.pov ~= Animator.AnimatorPointOfView.Free
%                 view(obj.axs, hAngle, vAngle);
%             end
        end
    end
    
    events
        newTimeStep
        playStateChanged
        reachedEnd
        animDeleting
    end
    
    methods (Abstract)
        x = GetData(obj, t);
        Draw(obj, t, x);
        [center, radius, yaw] = GetCenter(obj, t, x);
    end
end
