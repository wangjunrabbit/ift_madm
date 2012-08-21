%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	IntuiniotistFuzzyMatrix
%	
%	Authors: Andre Pacheco and Andre Siviero
%	Orienters: Renato Krohling and Rodolfo Lourenzutti
%
%	This file contains the class Intuiniotist Fuzzy Matrix. Most of the definitions
%	comes from Chen & Li paper "Dynamic multi-attribute decision making model based on triangular
%	intuitionistic fuzzy numbers", published on Scientia Iranica and available through www.sciencedirect.com
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef IntuitionistFuzzyMatrix < handle % Handle proprierty assures that all copies of a object share the same data
	properties 
	        vector_cost_or_benefit
	        matrixD
	        vectorW

	                
	end % properties
	
	methods
        
        %Constructor
        function ifm = IntuitionistFuzzyMatrix(vector_cost_or_benefit,matrixD)
			if nargin == 0 
		            error('No input')			
            end
            ifm.vector_cost_or_benefit = vector_cost_or_benefit;
            ifm.matrixD = matrixD;
            order = size(matrixD);
            n = order(2);
            ifm.vectorW = zeros(1,n);
            
		end % Constructor  
        
        %finding the vector rj
        function vectorR = calculateVectorRj (matrixFuzzy)
            order = size(matrixFuzzy.matrixD);
            m = order(1);
            n = order (2);
            vectorR = [IntuitionistFuzzyNumber([0 0 0 0],0,1)]; %Initialization
                      
            for j=1:n
                sumRjs = IntuitionistFuzzyNumber([0 0 0 0],0,1); % Initialization and Reset sum Rjs            	
                for i=1:m
                    sumRjs = sumRjs + matrixFuzzy.matrixD(i,j);
                end % for
                vectorR(j) = (sumRjs)*(1/m);
            end % for            
        end % calculateRj
        
        %finding the matrix M and, consequently, the vectors Mj's
        function matrixM = calculateMatrixM (matrixFuzzy)
            vectorR = [IntuitionistFuzzyNumber([0 0 0 0],0,1)]; %Initialization
            vectorR = matrixFuzzy.calculateVectorRj;    
            order = size(matrixFuzzy.matrixD);
            m = order(1);
            n = order (2);
            matrixM = zeros(m,n);
                                 
            for j=1:n                
                for i=1:m
                    matrixM(i,j) = I4FN_fuzzyDistance(matrixFuzzy.matrixD(i,j),vectorR(j));
                end %for
            end% end
            % Above was calculated the matrix of distances. To make it
            % matrixM, we need to find the trapose matrix it
            matrixM = matrixM'; 
            % The line one of matrixM is equals to vector M1. And so on...
        end %calculateVectorMj
        
        function matrixP = normalizeMatrixM (matrixFuzzy)
           matrixM = matrixFuzzy.calculateMatrixM;
           order = size(matrixM);
           m = order(1);
           n = order (2);
           vectorM = zeros(1,n);
           matrixP = zeros (m,n);

           for i=1:m
               max = 0; % value max of the line
               for j=1:n
                    vectorM(j) = matrixM(i,j);                   
               end %for
               vectorM = sort(vectorM);
               max = vectorM(n);
               
               for j=1:n
                   matrixP(i,j) = (matrixM(i,j))/max;
               end %for               
           end %for  
           % The transpose matrix equals the matrixP
           matrixP = matrixP'            
        end %normalizeVectorMj        
        
        % find entropy
        function en = entropy (matrixFuzzy)
            matrixP = matrixFuzzy.normalizeMatrixM;
            order = size(matrixFuzzy.matrixD);
            m = order(1);
            n = order (2);
            en = zeros (1,n);
            P = zeros (1,n);
            aux1 = 0; %buffer p1/sum pi
            aux2 = 0;
            
            for j=1:n
                for i=1:m
                    P(i) = matrixP(i,j);
                end %for
                for i=1:m
                    aux1 = (P(i))/sum(P);
                    aux2 = aux2 + (aux1*(log(aux1)));
                end %for
                en(j) = (-1/log(m))*aux2;
                aux2 = 0;
            end %for      
        end %entropy       
       
        % finding the vector weights os the matrixD
        function weights(matrixFuzzy)
            en = matrixFuzzy.entropy;
            order = size(en);
            n = order(2);
            sum_ek = sum(en);
            for j=1:n
                matrixFuzzy.vectorW(j) = (1-en(j))/(n-sum_ek);
            end %for            
        end %weights       
        
        
        % Normalize Decision Matrix
        function normalizeDecisionMatrix(fuzzyMatrix)
            order = size(fuzzyMatrix.matrixD);
            m = order(1);
            n = order (2);
            
            for j = 1:n
            	d_values = zeros(m,1);
            	a_values = zeros(m,1);

		% Getting d and a values
            	for i=1:m
            		d_values(i) = fuzzyMatrix.matrixD(i,j).valuesSet(4);
			a_values(i) = fuzzyMatrix.matrixD(i,j).valuesSet(1);            		
            	end % for i
            vectorAuxD = sort(d_values);
            vectorAuxA = sort(a_values)
            max_d = vectorAuxD(m);
            min_a = vectorAuxA(1);


		% Normalization
		if fuzzyMatrix.vector_cost_or_benefit(j) == 1 % benefit
			for i = 1:m
				for k = 1:4 
					fuzzyMatrix.matrixD(i,j).valuesSet(k) = fuzzyMatrix.matrixD(i,j).valuesSet(k)/max_d;
				end % for k
			end % for i
		else % cost
			for i = 1:m
				buffer = fuzzyMatrix.matrixD(i,j).valuesSet; 
				for k = 1:4 

					fuzzyMatrix.matrixD(i,j).valuesSet(k) = min_a / buffer(5-k);

				end % for k
			end % for i
		
		end % if
            	
            end % for j
        
        end % Normalize Decision Matrix
        
    end %methods
    
end %classdef
    
