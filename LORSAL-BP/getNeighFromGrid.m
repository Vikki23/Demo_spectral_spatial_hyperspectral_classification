%% This function returns the ID of each node in a given grid and
%% number and list of its neighbors 

function [numN, nList] = getNeighFromGrid(rows,cols)

% if cliques == 1
maxNumN = 4; %% maximum number of neighbors

nList = zeros(rows*cols,maxNumN);

for j = 1:cols,
  for i = 1:rows,
    
    curID = sub2ind([rows,cols],i,j);
         
    numN(curID) = 0;
    
    if (i-1)>0
      numN(curID) = numN(curID)+1;
      nList(curID,numN(curID)) = sub2ind([rows,cols],i-1,j);
    end
    if (j-1)>0
      numN(curID) = numN(curID)+1;
      nList(curID, numN(curID)) = sub2ind([rows,cols],i,j-1);
    end
    if (i+1)<=rows
      numN(curID) = numN(curID)+1;
      nList(curID, numN(curID)) = sub2ind([rows,cols],i+1,j);
    end
    if (j+1)<=cols
      numN(curID) = numN(curID)+1;
      nList(curID, numN(curID)) = sub2ind([rows,cols],i,j+1);
    end
  
  end
end
