classdef PairOfPoints < handle
    properties (Access = private)
        leftPoint (1,1) Point = Point(0,0)
        rightPoint (1,1) Point = Point(0,0)
    end

    properties (Dependent)
        LeftPoint
        RightPoint
    end

    methods
        function obj = PairOfPoints(leftPoint, rightPoint)
            obj.leftPoint = leftPoint;
            obj.rightPoint = rightPoint;
        end

        function set.LeftPoint(obj, leftPoint)
            obj.leftPoint = leftPoint;
        end
        function leftPoint = get.LeftPoint(obj)
            leftPoint = obj.leftPoint;
        end

        function set.RightPoint(obj, rightPoint)
            obj.rightPoint = rightPoint;
        end
        function rightPoint = get.RightPoint(obj)
            rightPoint = obj.rightPoint;
        end

    end

    methods (Access = private)
    end
end
