function [vect_TR_3,classes]= organizas_tr(vectTR)

classes = setdiff(unique(vectTR(:)),0)';
[nx ny]=size(vectTR);
% vect_TR_3=zeros(nx,ny,classes);
vect_TR_3=zeros(nx,ny,max(classes));
for valor=classes
    for i=1:nx
        for j=1:ny
            if vectTR(i,j)~=valor
                   vect_TR_3(i,j,valor)=0;
            else
                vect_TR_3(i,j,valor)=valor;
                
            end
        end
    end
end
