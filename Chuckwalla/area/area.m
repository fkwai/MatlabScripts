% Contour area
% 
% This program calculates the area above a certain contour level value.
%
% I have included a test data set to demostrate how the program works. The test.txt
% file is a 13x13 matrix with some example data. The program should be able
% to handle any mxn matrix. 
%
%*NOTE* The data in the test.txt file must contain your axis data, since the program is expecting
% it. The axis data must be in row 1 (columns 2 to end) and column 1 (rows
% 2 to end). The first "cell" in test.txt is not used so I made it 0.
% Currently the data is read from a text file (test.txt), to read from an
% Excel file comment the 2 lines that read the txt file and uncomment the 2
% for the xls file.
%
% Run the program and enter the desired contour level above which you would like to calculate
% the area.
%
% When the program is executed three graphs are displayed, here is an
% explanation of each:
%
% subplot(3,1,1): Displays the single contour line, as calculated by Matlab,
% at the level you entered.
%
% subplot(3,1,2): Displays the contour line as I have been able to extract
% it from the contourc funciton. This plot is meant as a sanity check to see
% if the program is working correctly. The red dots show the locations of
% each data point relative to the coutour line. They were helpful in troubleshooting.
%
% subplot(3,1,3): Displays a contour plot of the input data in test.txt,
% much like in subplot(3,1,1), but this time with contour levels selected
% by Matlab.
%
% Author: Phillip Tamchina
clear;                                                      % clear the workspace before starting
clf;                                                        % clear graphics
clc;                                                        % clear command window
filename = 'test.txt';
datatable = load(filename);                                  % load the data, including axes
% filename = 'test.xls';                                     % use this if reading from an Excel file
% datatable = xlsread(filename);                             % use this if reading from an Excel file
data = datatable(2:end,2:end);                               % extract the data from the original table
axisx = datatable(1,2:end);                                  % load the X axis
axisy = datatable(2:end,1).';                                % load the Y axis and take transpose, this is needed for subsequent operations

xneg = axisx(1,1);          % find the negative x limit of the data
xpos = axisx(1,end);        % find the positive x limit of the data
yneg = axisy(1,end);        % find the negative y limit of the data
ypos = axisy(1,1);          % find the positive y limit of the data

rxneg = round(xneg);        % round xneg to nearest integer
rxpos = round(xpos);        % round xpos to nearest integer
ryneg = round(yneg);        % round yneg to nearest integer
rypos = round(ypos);        % round ypos to nearest integer

maxlev = max(max(data));                            % max value of input data   
minlev = min(min(data));                            % min value of input data   
a = 'Enter a contour level between ';
b = ' and ';
c = ':';
prmptext = [a num2str(minlev) b num2str(maxlev) c];
d = 1;

while d % an attempt at some error handling...
    % GUI for contour level input
    prompt = {prmptext};
    dlg_title = 'Contour area calculation';
    num_lines= 1;
    answer  = inputdlg(prompt,dlg_title,num_lines);
    % if the user input level is outside the range of values in the data
    % loop back to ask the user for a contour level...
    if (str2num(answer{1}) < minlev) || (str2num(answer{1}) > maxlev) 
    else
        d = 0;
    end
end

Contour_Levels1 = [str2num(answer{1}), str2num(answer{1})]; % set the contour level to be calculated equal to the one the user has input 
level = Contour_Levels1(1,2);                           % set the variable "level" equal to the desired contour level
datasize = size(data);                                  % Calculate the size of the data matrix
     
% calculate the contour line "matrix", see "controurc" in HELP for explanation of how the data is arranged
Contourlines = contourc(axisx,axisy,data,Contour_Levels1);
Contourlines = Contourlines.';      % take the transpose of the the contour line matrix

subplot(3,1,1);                     % Plot the contour line to see if it's the one you asked for
[C1,h1,CF1] = contourf(axisx,axisy,data,Contour_Levels1);
h1=clabel(C1,h1); 
set(get(gca,'XLabel'),'String','X');      % set the X axis title
set(get(gca,'YLabel'),'String','Y');      % set the Y axis title
dimr = datasize(1,1);               % equals # of rows in data matrix
dimc = datasize(1,2);               % equals # of columns in data matrix
Matrixdim = size(Contourlines);     % Calculate the size of the contour line matrix (row,col)
Endmat = Matrixdim(1,1);            % This variable will be used to tell where the end of the matrix is
row = 1;
column = 1;                         % this index will be used to locate the reorganized dataset

% This while loop reorganizes the contour curves into separate columns and closes open curves
while row < Endmat
    length = Contourlines(row,2);                                               % length of dataset for current contour line being read
    datasheet(1:length+1,column:column+1) = Contourlines(row:row+length,:);     % write the current dataset into the datasheet matrix

    % check to see if the dataset forms a closed polygon (last point equals first point)
    if (datasheet(length+1,column) ~= datasheet(2,column)) || (datasheet(length+1,column+1) ~= datasheet(2,column+1));   
    % if the polygon is not closed we must close it... somehow... so here we go....
        if (round(datasheet(length+1,column)) == rxpos) && (round(datasheet(2,column+1)) == ryneg);
            datasheet(length+2,column:column+1) = [xpos, yneg];             % if the last point in the dataset in somewhere on the positive x limit line and the first point somewhere on the negative y limit line then add the corner point [xpos, yneg]
            datasheet(length+3,column:column+1) = datasheet(2,column:column+1); % set the last point in the dataset equal to the first point 
            
        elseif (round(datasheet(length+1,column+1)) == ryneg) && (round(datasheet(2,column)) == rxpos);
            datasheet(length+2,column:column+1) = [xpos, yneg];             % if the last point in the dataset in somewhere on the negative y limit line and the first point somewhere on the positive x limit line then add the corner point [xpos, yneg]
            datasheet(length+3,column:column+1) = datasheet(2,column:column+1); 
            
        elseif (round(datasheet(length+1,column)) == rxpos) && (round(datasheet(2,column+1)) == rypos);
            datasheet(length+2,column:column+1) = [xpos, ypos];             % if the last point in the dataset in somewhere on the positive x limit line and the first point somewhere on the positive y limit line then add the corner point [xpos, ypos]
            datasheet(length+3,column:column+1) = datasheet(2,column:column+1); % set the last point in the dataset equal to the first point
            
        elseif (round(datasheet(length+1,column+1)) == rypos) && (round(datasheet(2,column)) == rxpos);
            datasheet(length+2,column:column+1) = [xpos, ypos];             % if the last point in the dataset in somewhere on the positive y limit line and the first point somewhere on the positive x limit line then add the corner point [xpos, ypos]
            datasheet(length+3,column:column+1) = datasheet(2,column:column+1); 
            
        elseif (round(datasheet(length+1,column)) == rxneg) && (round(datasheet(2,column+1)) == rypos);
            datasheet(length+2,column:column+1) = [xneg, ypos];             % if the last point in the dataset in somewhere on the negative x limit line and the first point somewhere on the positive y limit line then add the corner point [xneg, ypos]
            datasheet(length+3,column:column+1) = datasheet(2,column:column+1); % set the last point in the dataset equal to the first point
             
        elseif (round(datasheet(length+1,column+1)) == rypos) && (round(datasheet(2,column)) == rxneg);
            datasheet(length+2,column:column+1) = [xneg, ypos];             % if the last point in the dataset in somewhere on the positive y limit line and the first point somewhere on the negative x limit line then add the corner point [xneg, ypos]
            datasheet(length+3,column:column+1) = datasheet(2,column:column+1); 
            
        elseif (round(datasheet(length+1,column)) == rxneg) && (round(datasheet(2,column+1)) == ryneg);
            datasheet(length+2,column:column+1) = [xneg, yneg];             % if the last point in the dataset in somewhere on the negative x limit line and the first point somewhere on the negative y limit line then add the corner point [xneg, yneg]
            datasheet(length+3,column:column+1) = datasheet(2,column:column+1); % set the last point in the dataset equal to the first point
            
        elseif (round(datasheet(length+1,column+1)) == ryneg) && (round(datasheet(2,column)) == rxneg);
            datasheet(length+2,column:column+1) = [xneg, yneg];             % if the last point in the dataset in somewhere on the negative y limit line and the first point somewhere on the negative x limit line then add the corner point [xneg, yneg]
            datasheet(length+3,column:column+1) = datasheet(2,column:column+1); 
                   
        elseif (round(datasheet(length+1,column)) == rxneg) && (round(datasheet(2,column)) == rxpos);
            datasheet(length+2,column:column+1) = [xneg, yneg];             % if the last point in the dataset in somewhere on the negative x limit line and the first point somewhere on the positive x limit line then add the points [xneg, yneg] & [xpos, yneg] to the dataset
            datasheet(length+3,column:column+1) = [xpos, yneg];
            datasheet(length+4,column:column+1) = datasheet(2,column:column+1); % set the last point in the dataset equal to the first point
                
        elseif (round(datasheet(length+1,column)) == rxpos) && (round(datasheet(2,column)) == rxneg);
            datasheet(length+2,column:column+1) = [xpos, yneg];             % if the last point in the dataset in somewhere on the positive x limit line and the first point somewhere on the negative x limit line then add the points [xpos, yneg] & [xneg, yneg] to the dataset
            datasheet(length+3,column:column+1) = [xneg, yneg];
            datasheet(length+4,column:column+1) = datasheet(2,column:column+1); % set the last point in the dataset equal to the first point
            
        elseif (round(datasheet(length+1,column+1)) == rypos) && (round(datasheet(2,column+1)) == ryneg);
            datasheet(length+2,column:column+1) = [xneg, ypos];             % if the last point in the dataset in somewhere on the positive y limit line and the first point somewhere on the negative y limit line then add the points [xneg, ypos] & [xneg, yneg] to the dataset
            datasheet(length+3,column:column+1) = [xneg, yneg];
            datasheet(length+4,column:column+1) = datasheet(2,column:column+1); % set the last point in the dataset equal to the first point
        
        elseif (round(datasheet(length+1,column+1)) == ryneg) && (round(datasheet(2,column+1)) == rypos);
            datasheet(length+2,column:column+1) = [xneg, yneg];             % if the last point in the dataset in somewhere on the negative y limit line and the first point somewhere on the positive y limit line then add the points [xneg, yneg] & [xneg, ypos] to the dataset
            datasheet(length+3,column:column+1) = [xneg, ypos];
            datasheet(length+4,column:column+1) = datasheet(2,column:column+1); % set the last point in the dataset equal to the first point
        
        elseif ((round(datasheet(2,column)) == rxpos) && (round(datasheet(length+1,column)) == rxpos)) | ((round(datasheet(2,column)) == rxneg) && (round(datasheet(length+1,column)) == rxneg)); % if the first and last points have the same x value on the positive or negative limit line then set last point equal to first point
            datasheet(length+2,column:column+1) = datasheet(2,column:column+1);
        
        elseif ((round(datasheet(2,column+1)) == ryneg) && (round(datasheet(length+1,column+1)) == ryneg)) | ((round(datasheet(2,column+1)) == rypos) && (round(datasheet(length+1,column+1)) == rypos)); % if the first and last points have the same y value on the positive or negative limit line then set last point equal to first point
            datasheet(length+2,column:column+1) = datasheet(2,column:column+1);
        end
    end
    column = column + 2;                      % increment the column index by two for the next dataset
    row = row + length + 1;                   % index of the row location (in the original data) where you are 
end

% the following piece of code creates a dot at each grid point where a measurement was taken
n = 1;
subplot(3,1,2);
set(get(gca,'XLabel'),'String','X');      % set the X axis title
set(get(gca,'YLabel'),'String','Y');      % set the Y axis title
for yindex = 1:dimr;
    for xindex = 1:dimc;
        pos(n,1:2) = [axisx(1,xindex),axisy(1,yindex)];
        n=n+1;
        hold on;
    end
end

%Plot all the contour lines calculated for the given level
Areatotal = 0;              % zero the variable that will keep track of the total area higher than the level the user input
while column > 2            % delete all zeroes at the end of the dataset
    XY = datasheet(2:end,column-2:column-1);
    XYsize = size(XY);
    if ((datasheet(2,column-2)==0) && (datasheet(2,column-1)==0)) % if the first point is (0,0) the last point is also (0,0), so delete all (0,0) coords at the end of the dataset and then add one back
        while ((XY(XYsize(1,1),1)==0) && (XY(XYsize(1,1),2)==0)) % if both x and y values are zero at the end of the data set delete them
            XY(XYsize(1,1),:) = [];
            XYsize = size(XY);
        end
        XY(XYsize(1,1)+1,:) = [0, 0];   % add the last (0,0) coord back to the dataset
    else                                % else delete all (0,0) coords at the end of the dataset
        while ((XY(XYsize(1,1),1)==0) && (XY(XYsize(1,1),2)==0)) % if both x and y values are zero at the end of the data set delete them
            XY(XYsize(1,1),:) = [];
            XYsize = size(XY);
        end
    end
    
    X = XY(1:end,1);
    Y = XY(1:end,2);
    plot(X,Y);
    
    in = inpolygon(pos(1:end,1),pos(1:end,2),X,Y);      % find all points within the current polygon
    plot(pos(1:end,1),pos(1:end,2),'r.');               % plot a dot at each measurement point
    for i = 0:dimr-1;
        in2(i+1, 1:dimc) = in(i*dimc+1:i*dimc + dimc, 1);       %rearrange the "in" matrix to a square matrix
    end
   
    % filter the data for only those values within current polygon
    j=1;
    filtered = 0;
    for cindex = 1:dimc;
        for rindex = 1:dimr;
            test(rindex,cindex) =  data(rindex,cindex)*in2(rindex,cindex);
            if in2(rindex,cindex) == 1;
                filtered(j,1) = data(rindex,cindex);
                filtered(j,2) = axisx(1,cindex);    % attach the coords to each value
                filtered(j,3) = axisy(1,rindex);
                j = j + 1;
            end
        end
    end
    filteredmatrixsize = size(filtered);
    matrixlength = filteredmatrixsize(1,1); % this determines how many points fall within the current polygon

    flag = 0;                               % this variable keeps track of how many points within the polygon have a level below "level" selected by user
    
    for count = 1:matrixlength;
        if filtered(count,1) <= level;
           flag = flag + 1;     %increment the flag if the current point is lower than "level"
       end
    end
    
   axis([rxneg-2 rxpos+2 ryneg-2 rypos+2]); % set the limits of the axes to slightly larger than the actual data limits
    hold on;
    column = column - 2;        % decrement the column index by 2 to read the previous dataset, we are reading the datasets from last to first

    if flag == 0;               % no points within the current polygon are less than "level"
        Area = polyarea(X,Y)    % Calculate the area of the contour level in question 
    elseif flag == matrixlength;
        Area = -polyarea(X,Y)   % Calculate the area of the contour level in question and make it negative since all points within it are below "level"
    else                        % The points within the current polygon are neither all higher or lower than "level", find the distance to each point within the polygon and evaluate the value
        k = 1;
        o = 1;
        fltval = filteredmatrixsize(1,1);  % # of filtered points
        pntsply = XYsize(1,1);             % # points making up the current contour line
        while k <= pntsply;
           temp = [0,0,0,0,0,0];
           m = 1;
           while m <= fltval;  % find the distance to each point within the current polygon
               dist = sqrt(((filtered(m,2)-XY(k,1))^2 + (filtered(m,3)-XY(k,2))^2));
               temp(o,:) = [XY(k,1),XY(k,2),filtered(m,2),filtered(m,3),filtered(m,1),dist];
               m = m + 1;
               o = o + 1;
           end
           B = sortrows(temp,6); % sort data according to ascending "distance" from current point to all other points within the polygon
           Cdata(k,:) = B(1,:);  % write the closest point to the Cdata matrix
           k = k + 1;
           o = 1;
        end
        Vals = Cdata(:,5); % write the level of each closest point into Vals
        flag2 = 0;
        q = 1;
        while q <= pntsply;
            if Vals(q,1) <= level; % search Vals to see how many points are below "level"
                flag2 = flag2 + 1;
            end
            q = q + 1;
        end
       % the following if statement is the weakest part of the program... I still don't have a good way of deteremining whether an area should be positive or negative if there is another area with it
       if flag2/pntsply > 0.9; %ie. if most points adjacent to the interior are not higher than "level", then make the area negative, since the current polygon represents an area with a level less than "level" but an interior "island" with value higher than "level"
            Area = -polyarea(X,Y)
       else
            Area = polyarea(X,Y)
       end       
    end
    Areatotal = Areatotal + Area; % add the area of the current closed contour to the running total
    Area = 0;                     % reset the variable
end

TotalGridArea = (abs(xpos-xneg))*(abs(ypos-yneg)) % Calculate the total grid area based on the axes

if Areatotal < 0;               % if the total area is negative ie. all closed polygons represent regions lower than "level", then add "Areatotal" (a negative number) to "TotalGridArea" to find the area above "level"
    Areatotal = TotalGridArea + Areatotal 
else                            % else, the area is positive and hence the correct area we want
    Areatotal
end

title(['Area above contour level ', answer{1}, ' = ', num2str(Areatotal), ' units','^2']);   % display the area of the contour as the title of subplot (3,1,2)
%Contour_Levels2 = [-5, -4, -1, 2, 5, 8, 11, 14, 17];
%subplot(3,1,3); [C,h,CF] = contourf(axisx,axisy,data,Contour_Levels2);               % a graphic of the coutour plot
subplot(3,1,3); [C,h,CF] = contourf(axisx,axisy,data);
set(get(gca,'XLabel'),'String','X');      % set the X axis title
set(get(gca,'YLabel'),'String','Y');      % set the Y axis title
colormap(jet);
h=clabel(C,h);                                              
hold off;