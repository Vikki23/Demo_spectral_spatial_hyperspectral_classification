function [vectProbOrdered,order,ordervalue]=aux_ordenar_v4(vect_TR,vectProb,no_lines,no_col)


vect_clases=[];

%% Organizar las clases segun el numero de pixeles

[vect_TR_3,classes]= organizas_tr(vect_TR);
[x y b]=size(vect_TR_3);
vect_TR_3_2=reshape(vect_TR_3,x*y,b);
for i=classes
vect_clases=[vect_clases,sum((vect_TR_3_2(:,i)>0))];
end
[valor,p_tr]=sort(vect_clases,'descend');
%p_tr= orden de las clases

%% Leer el vector de probabilidad (valor, posicion) (21025*16)
[ns,p] = size(vectProb);

%% nuevas variables
M = [];
order =[];
ordervalue =[];

%% comparamos todas las clases (con el orden establecido) con los mapas de
%% abundancia
jset = 1:p;
for c=p_tr                % p_tr (vector de orden de las clases)
        
    
        pos = find(vect_TR==c);
        aux = [];
        
        for j=jset        % p (numero de mapas de probabilidades disponible)
           
            a = (vectProb(pos,j));    %seleccionamos los pixeles correspondiente a la clase
            
            
            average = prctile(a(:),50);
            aux = [aux,average];
                 
            
        end
%          plot (aux)      
       [v,pp] = max(aux);
        pp = jset(pp);
        order = [order,pp];
        jset = setdiff(jset,order);
        ordervalue = [ordervalue,v];
        
        fprintf(' training class # %3.0d -> map %3.0d prob. \n',c,pp)
        
end

[v,pp]=sort(p_tr);
order = order(pp);

% M = [M;[order,mean(ordervalue)]];
% [v,ppp]=max(M(:,end));
% v
% 
% order = M(ppp,1:end-1);
vectProbOrdered = vectProb(:,order);

% visualize results
mapTR = vect_TR;
mapProb = reshape(vectProb,no_lines,no_col,p);
temp = [];    

% % % Pintar mapas
% % for i=1:p
% %   %  temp = [temp;[mapTR==i,mapProb(:,:,order(i))]];
% % 
% %     imagesc([mapTR==i,mapProb(:,:,order(i))]);figure
% % end
% %     close

