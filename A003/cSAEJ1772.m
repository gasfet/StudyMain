classdef cSAEJ1772 < handle
    %CSAEJ1772 Summary of this class goes here
    %   Detailed explanation goes here

    properties(Access = private)
        hTimer
    end

    properties(Access = public)
        app
    end

    properties(Access = private)
        view
        model
        control
        el
    end

    methods
        function obj = cSAEJ1772()
            %CSAEJ1772 Construct an instance of this class
            %   Detailed explanation goes here
            if ~isdeployed(), delete(timerfindall); end  % Matlab환경에서 이전에 실행한 내용이 남아 있으면 삭제한다.

            obj.app = sae_j1772_app2();
            obj.control = cSAEJ1772C();
            obj.model = cSAEJ1772M();
            obj.view = cSAEJ1772V();

            % el1 = addlistener(obj.view, 'LogWrite',  @(src, evnt)notify(T.cMain, evList{1}, evnt));
            % el2 = addlistener(obj.view, 'LogRead',  @(src, evnt)notify(T.cMain,  evList{2}, evnt));
            % el3 = addlistener(obj.view, 'LogError',  @(src, evnt)notify(T.cMain,  evList{3}, evnt));
            % el4 = addlistener(obj.model, 'LogWrite',  @(src, evnt)notify(T.cMain, evList{1}, evnt));
            % el5 = addlistener(obj.model, 'LogRead',  @(src, evnt)notify(T.cMain,  evList{2}, evnt));
            % el6 = addlistener(obj.model, 'LogError',  @(src, evnt)notify(T.cMain,  evList{3}, evnt));
            % el7 = addlistener(obj.control, 'LogWrite',  @(src, evnt)notify(T.cMain, evList{1}, evnt));
            % el8 = addlistener(obj.control, 'LogRead',  @(src, evnt)notify(T.cMain,  evList{2}, evnt));
            % el9 = addlistener(obj.control, 'LogError',  @(src, evnt)notify(T.cMain,  evList{3}, evnt));
            % el10 = addlistener(obj.app, 'evLogView',  @(s,e)logviewVisible(obj.logger));
            % el11 = addlistener(obj.app, 'evStop',  @(s,e)obj.appStop(s, e));
            % obj.el = [el1, el2, el3, el4, el5, el6, el7, el8, el9, el10, el11];

            obj.hTimer = timer(...
                "StartFcn",@(s,e)obj.TimerStartFnc(s,e), ...
                "TimerFcn",@(s,e)obj.TimerMainFnc(s,e), ...
                "ErrorFcn",@(s,e)obj.TimerErrorFnc(s,e), ...
                "StopFcn",@(s,e)obj.TimerStopFnc(s,e));
            start(obj.hTimer);
            drawnow limitrate;
        end


        function delete(obj)
            obj.finish();
            if isdeployed(), delete(gcp("nocreate")); end

            if ~isempty(obj.el)
                for idx=1:length(obj.el)
                    obj.el(idx).Enabled = 0;
                end
                delete(obj.el);obj.el=[];
            end

        end

    end

    methods(Access = private) % app initiliaing functions

        function init(obj)
            obj.app.init(obj.view, obj.model, obj.control);
            obj.view.init(obj.app, obj.control, obj.model);
            obj.model.init(obj.app, obj.view, obj.control);
            obj.control.init(obj.app, obj.view, obj.model);

            % update 순서 : model -> control -> view
            obj.model.update();
            obj.control.update();
            obj.view.update();
        end

        function body(obj)
            obj.view.update();
        end

        function finish(obj)
            delete(obj.control);obj.control = [];
            delete(obj.model);obj.model = [];
            delete(obj.view);obj.view = [];
            delete(obj.app);obj.app=[];
        end

    end



    methods(Access = private) % timer functions

        function TimerStartFnc(obj, src, ev)
            obj.init();
            drawnow limitrate;
        end

        function TimerMainFnc(obj, src, ev)
            obj.body();
            drawnow limitrate;
        end

        function TimerErrorFnc(obj, src, ev)

        end

        function TimerStopFnc(obj, src, ev)

        end

    end


end
