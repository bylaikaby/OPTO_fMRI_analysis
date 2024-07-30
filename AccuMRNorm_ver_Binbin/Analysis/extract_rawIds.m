% Define the file name and sheet (if applicable)
fileName = 'Copy_of_CM032.xlsx';
sheetName = 'Sheet1'; % Optional: specify the sheet name if needed

% Read the table from the Excel file
data = readtable(fileName, 'Sheet', sheetName);
%% 
columnName1 = 'RecoID'; % The name of the column you want to filter
columnName2 = 'task';
% Extract the specific column
columnData1 = data.(columnName1);
columnData2 =data.(columnName2);
%% 

% Define the filter criteria (e.g., values greater than 50)

% Apply the filter to the table
filteredData = data(columnData1 == 2 & strcmp(columnData2,'MSTIM'), 'ScanID');

% Display the filtered data
disp(filteredData);
