function y = interpolateSpec(dataList,x)
    % dataList: 2-d array containing: column1: x, column2: y
    % assume that this list was sorted by X (period)
    % if x is not located between the min and max range of the domain,NaN is returned.
    for i = 1: size(dataList)
        x2 = dataList(i,1);
        if (x2 >= x)
            break;
        end
    end
    y2 = dataList(i,2);
    if i == 1
        x1 = 0;
        y1 = 0;
    else
        x1 = dataList(i - 1,1);
        y1 = dataList(i - 1,2);
    end
    y = y1 + (y2 - y1) / (x2 - x1) * (x - x1);
end

