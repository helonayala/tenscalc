function dist2=pdist2t(X,Y,method)
% dist2=pdist2t(X,Y)
%
% Returns the square of the Euclidean distances between points in
% two vectors:
%
% Inputs:
%   X - N x Nx matrix with Nx points in N-dimensional space
%   Y - N x Ny matrix with Ny points in N-dimensional space
%
% Outputs:
%   dist2 - NxM matrix with the square of the Euclidean distances
%   between the points X and Y
%
% Attention: this function is inpired by Matlab's pdist2, but
% differs from it in the following aways:
% 1) the input matrices X & Y are transposed
% 3) only works with squaredeuclidean (smooth)

if nargin<3
    method='euclidean';
end

[N,Nx]=size(X);
[n,Ny]=size(Y);

if ~isequal(N,n)
    error('mismatch between dimensions of X ([%s]) and Y ([%s])\n',...
          index2str(size(X)),index2str(size(Y)));
end

switch method
  case 'squaredeuclidean'
    relPos=repmat(reshape(X,[N,Nx,1]),[1,1,Ny])-repmat(reshape(Y,[N,1,Ny]),[1,Nx,1]);
    dist2=sum(sqr(relPos),1);
  otherwise
    fprintf('method ''%s'' not implemented for Tcalculus/pdist2t (use ''squaredeuclidean'')\n',...
            method);
end
