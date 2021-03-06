function grad=gradient(obj,var)
% grad=gardient(obj,var)
% 
% Computes the gradient of the expression 'obj', with respect to the 
% variable 'var'.
%
% Copyright 2012-2017 Joao Hespanha

% This file is part of Tencalc.
%
% TensCalc is free software: you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by the
% Free Software Foundation, either version 3 of the License, or (at your
% option) any later version.
%
% TensCalc is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with TensCalc.  If not, see <http://www.gnu.org/licenses/>.
    
    tprod_associate=false; % associativity often leads to tprods
                           % that have many arguments and need to
                           % be very much expanded
    
    if ~isequal(type(var),'variable')
        var
        error('Can only compute gradient with respect to variables (not %s)',type(var));
    end
    
    obj=toCalculus(obj);

    obj_derivatives_cache=derivatives_cache(obj); % [variable.TCindex,derivative.TCindex;...]
    
    k=find(obj_derivatives_cache(:,1)==var.TCindex);
    if length(k)==1
        %fprintf('.');
        grad=Tcalculus(obj_derivatives_cache(k,2));
        return
    elseif length(k)>1
        error('derivatives_cache has repeated entries\n');
    end
    
    obj_type=type(obj);
    obj_size=size(obj);
    var_size=size(var);
    
    gsize=[obj_size,var_size];
    ops=operands(obj);
    pars=parameters(obj);
    inds=op_parameters(obj);
    
    objs=cell(length(ops),1);
    grads=cell(length(ops),1);
    for i=1:length(ops)
        objs{i}=Tcalculus(ops(i));
        grads{i}=gradient(objs{i},var);
    end

    switch obj_type
      
      case {'zeros','ones','eye','constant'}
        grad=Tzeros(gsize);
      
      case 'variable'
        if strcmp(parameters(obj),parameters(var))
            grad=Teye(gsize);
        else
            grad=Tzeros(gsize);
        end
      
      case 'subsref'
        gsize1=size(grads{1});
        switch pars.type 
          case '()'
            for i=length(pars.subs)+1:length(gsize1)
                pars.subs{i}=':';
            end
            grad=subsref(grads{1},pars);
          otherwise
            error('subsref of type %s not implemented\n',pars.type);
        end

      case 'reshape'
        gsize1=size(grads{1});
        osize1=size(objs{1});
        osize=[obj_size,gsize1(length(osize1)+1:end)];
        grad=reshape(grads{1},osize);
        
      case 'full'
        grad=full(grads{1});
        
      case 'plus'
        if isempty(objs)
            error('taking gradient of plus() with no arguments\n');
        else
            for i=1:length(objs)
                if i==1
                    if inds{i}>0
                        grad=grads{i};
                    else
                        grad=-grads{i};
                    end
                else
                    if inds{i}>0
                        grad=grad+grads{i};
                    else
                        grad=grad-grads{i};
                    end
                end
            end
        end
        
      case 'tprod'
        if isempty(objs)
            error('taking gradient of prod() with no arguments\n');
        else
            for i=1:length(objs)
                ind1=[inds{i},(1:length(var_size))+length(obj_size)];
                x='tprod(grads{i},ind1';
                for j=1:length(objs)
                    if j~=i
                        x=sprintf('%s,objs{%d},inds{%d}',x,j,j);
                    end
                end
                if tprod_associate
                    if i==1
                        grad=eval([x,',''associate'')']);
                    else
                        grad=grad+eval([x,',''associate'')']);
                    end
                else
                    if i==1
                        grad=eval([x,')']);
                    else
                        grad=grad+eval([x,')']);
                    end
                end
            end
        end
        
      case {'ctranspose','transpose'}
        grad=gradient(tprod(objs{1},[2,1]),var);
        % associate may seem faster, but often leads to poor reuse
        % of computation. E.g., there would be no reuse between
        % A*x and (A*x)'  
        %grad=gradient(tprod(objs{1},[2,1],'associate'),var);
      
      case 'norm2'
        osize1=size(objs{1});
        grad=2*tprod(grads{1},...
                     [-1:-1:-length(osize1),1:length(var_size)],...
                     objs{1},-1:-1:-length(osize1));
      
      case 'norm1'
        osize1=size(objs{1});
        grad=tprod(grads{1},...
                     [-1:-1:-length(osize1),1:length(var_size)],...
                     abs(objs{1}),-1:-1:-length(osize1));
        error('Do not attemp to take derivative of norm1() as it is typically smooth at optimal value.')
        
      case 'compose'
        fun=parameters(obj);
        osize1=size(objs{1});
        fsize=size(fun{1}(0));
        % remove singletons at the end
        while ~isempty(fsize) && fsize(end)==1
            fsize(end)=[];
        end
        p=1:length(fsize)+length(osize1);
        q=[1:length(osize1),...
           length(fsize)+length(osize1)+(1:length(var_size))];
        grad=tprod(compose(objs{1},fun{2:end}),p,...
                   grads{1},q);
      
      case 'cat'
        grad=cat(pars,grads{:});

      case 'mrdivide'
        osize1=objs{1}.size;
        osize2=objs{2}.size;
        if isempty(osize2)
            % division by scalar
            if strcmp(type(grads{2}),'zeros')
                % denominator is a "constant"
                grad=grads{1}/objs{2};
            else
                grad=grads{1}/objs{2}...
                     -tprod(objs{1},1:length(osize1),...
                            grads{2},length(osize1)+1:length(osize1)+length(var_size))...
                     /(objs{2}*objs{2});
            end
        else
            error('error: grad_{%s}(%s)\n\t%s_{%s} incomplete\n',str(var),str(obj),obj_type,index2str(obj_size))
        end
        
      case 'rdivide'
        osize1=objs{1}.size;
        osize2=objs{2}.size;
        if isempty(osize2)
            % division by scalar
            if strcmp(type(grads{2}),'zeros')
                % denominator is a "constant"
                grad=grads{1}/objs{2};
            else
                grad=grads{1}/objs{2}...
                     -tprod(objs{1},1:length(osize1),...
                            grads{2},length(osize1)+1:length(osize1)+length(var_size))...
                     /(objs{2}*objs{2});
            end
        else
            error('error: grad_{%s}(%s)\n\t%s_{%s} incomplete\n',str(var),str(obj),obj_type,index2str(obj_size))
        end
        
      case 'interpolate'
        if strcmp(type(grads{2}),'zeros')
            objs{2}
            error('gradient(interpolate,var) incomplete: 2nd argument of interpolate cannot depend on var\n');
        end
        if strcmp(type(grads{3}),'zeros')
            objs{3}
            error('gradient(interpolate,var) incomplete: 3rd argument of interpolate cannot depend on var\n');
        end
        if strcmp(type(grads{4}),'zeros')
            objs{4}
            error('gradient(interpolate,var) incomplete: 4th argument of interpolate cannot depend on var\n');
        end
        grad=tprod(Ginterpolate(objs{1},objs{2},objs{3},objs{4},parameters(obj)),...
                   [1:length(obj_size),-(1:length(objs{1}.size))],...
                   grads{1},[-(1:length(objs{1}.size)),length(obj_size)+1:length(obj_size)+length(var_size)]);
        
        
      case 'Ginterpolate'
        if strcmp(type(grads{2}),'zeros')
            objs{2}
            error('gradient(Ginterpolate,var) incomplete: 2nd argument of interpolate cannot depend on var\n');
        end
        if strcmp(type(grads{3}),'zeros')
            objs{3}
            error('gradient(Ginterpolate,var) incomplete: 3rd argument of interpolate cannot depend on var\n');
        end
        if strcmp(type(grads{4}),'zeros')
            objs{4}
            error('gradient(Ginterpolate,var) incomplete: 4th argument of interpolate cannot depend on var\n');
        end
        grad=tprod(Hinterpolate(objs{1},objs{2},objs{3},objs{4},parameters(obj)),...
                   [1:length(obj_size),-(1:length(objs{1}.size))],...
                   grads{1},[-(1:length(objs{1}.size)),length(obj_size)+1:length(obj_size)+length(var_size)]);
            
      otherwise
        obj,objs{1}
        grad=Tcalculus('gradient',gsize,[],[obj.TCindex;var.TCindex],{},1);
        error('error in computing: grad_{%s}(%s)\n\tgradient of %s_{%s} not implemented\n',str(var),str(obj),obj_type,index2str(obj_size))
    end
    
    updateFile2table(grad,1);
    
    add2derivatives_cache(obj,var,grad);
    
    if ~isequal(size(grad),gsize)
        obj
        gsize
        grad
        error('gradient: unexpected size for the gradient\n');
    end
    %fprintf('D_{%s} (%s) = %s\n',str(var),str(obj),str(grad))
end

